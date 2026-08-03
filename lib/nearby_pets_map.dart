import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

const String kGoogleApiKey = 'AIzaSyC4uNvcXlhJHKKMHRqS0G9IP__BLyT0krI';

class NearbyPetsMap extends StatefulWidget {
  const NearbyPetsMap({super.key});

  @override
  State<NearbyPetsMap> createState() => _NearbyPetsMapState();
}

class _NearbyPetsMapState extends State<NearbyPetsMap> {
  GoogleMapController? _mapController;

  Position? _userPosition;

  final Set<Marker> _markers = {};


  final List<NearbyPlace> _places = [];

  bool _isLoading = true;

  String _selectedFilter = 'all';

  String _locationMessage = '';

  // Yangon fallback
  static const LatLng _yangon = LatLng(
    16.8661,
    96.1951,
  );

  // Search radius = 20 KM
  static const int _searchRadius = 100000;

  // Multiple Overpass servers
  final List<String> _overpassServers = [
    'https://overpass-api.de/api/interpreter',
    'https://overpass.kumi.systems/api/interpreter',
    'https://overpass.private.coffee/api/interpreter',
  ];

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      _init();
    });
  }

  // ============================================================
  // INITIALIZE
  // ============================================================

  Future<void> _init() async {
    if (!mounted) return;

    setState(() {
      _isLoading = true;
      _locationMessage = '';
      _places.clear();
      _markers.clear();
    });

    // 1. Get current GPS location
    final locationSuccess = await _getUserLocation();

    if (!locationSuccess) {
      if (!mounted) return;

      setState(() {
        _isLoading = false;
      });

      return;
    }

    // 2. Move map to current location
    await _moveToCurrentLocation();

    // 3. Search nearby places
    await _fetchPlaces();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  // ============================================================
  // GET CURRENT LOCATION
  // ============================================================

  Future<bool> _getUserLocation() async {
    try {
      print('================================');
      print('📍 GETTING CURRENT LOCATION');
      print('================================');

      // Check location service
      bool serviceEnabled =
      await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        print('❌ Location service is disabled');

        if (mounted) {
          setState(() {
            _locationMessage =
            'Please turn on your phone location service.';
          });
        }

        return false;
      }

      // Check permission
      LocationPermission permission =
      await Geolocator.checkPermission();

      print('📍 Permission: $permission');

      // Request permission
      if (permission == LocationPermission.denied) {
        permission =
        await Geolocator.requestPermission();

        print(
          '📍 Requested permission: $permission',
        );
      }

      // Permission denied
      if (permission == LocationPermission.denied) {
        print('❌ Location permission denied');

        if (mounted) {
          setState(() {
            _locationMessage =
            'Location permission is required.';
          });
        }

        return false;
      }

      // Permission permanently denied
      if (permission ==
          LocationPermission.deniedForever) {
        print(
          '❌ Location permission permanently denied',
        );

        if (mounted) {
          setState(() {
            _locationMessage =
            'Location permission is permanently denied. '
                'Please enable it from Settings.';
          });
        }

        return false;
      }

      // Get current position
      Position position =
      await Geolocator.getCurrentPosition(
        locationSettings:
        const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );

      _userPosition = position;

      print(
        '📍 CURRENT LOCATION: '
            '${position.latitude}, '
            '${position.longitude}',
      );

      return true;
    } catch (e) {
      print(
        '❌ Location error: $e',
      );

      if (mounted) {
        setState(() {
          _locationMessage =
          'Could not get your current location.';
        });
      }

      return false;
    }
  }

  // ============================================================
  // MOVE MAP TO CURRENT LOCATION
  // ============================================================

  Future<void> _moveToCurrentLocation() async {
    if (_userPosition == null) {
      return;
    }

    final LatLng currentLocation =
    LatLng(
      _userPosition!.latitude,
      _userPosition!.longitude,
    );

    print(
      '🗺️ Moving map to: '
          '${currentLocation.latitude}, '
          '${currentLocation.longitude}',
    );

    // Remove old user marker
    _markers.removeWhere(
          (marker) =>
      marker.markerId.value == 'user',
    );

    // Add current location marker
    _markers.add(
      Marker(
        markerId:
        const MarkerId('user'),
        position:
        currentLocation,
        icon: BitmapDescriptor
            .defaultMarkerWithHue(
          BitmapDescriptor.hueAzure,
        ),
        infoWindow:
        const InfoWindow(
          title:
          '📍 Your Location',
        ),
      ),
    );

    if (mounted) {
      setState(() {});
    }

    // Move camera
    if (_mapController != null) {
      await _mapController!
          .animateCamera(
        CameraUpdate.newLatLngZoom(
          currentLocation,
          14,
        ),
      );
    }
  }

  // ============================================================
  // BUILD OVERPASS QUERY
  // ============================================================

  String _buildOverpassQuery(
      double lat,
      double lng,
      ) {
    if (_selectedFilter == 'all') {
      return '''
[out:json][timeout:30];

(
  node["amenity"="veterinary"](around:$_searchRadius,$lat,$lng);
  way["amenity"="veterinary"](around:$_searchRadius,$lat,$lng);
  relation["amenity"="veterinary"](around:$_searchRadius,$lat,$lng);

  node["shop"="pet"](around:$_searchRadius,$lat,$lng);
  way["shop"="pet"](around:$_searchRadius,$lat,$lng);
  relation["shop"="pet"](around:$_searchRadius,$lat,$lng);
);

out center;
''';
    }

    if (_selectedFilter == 'vet') {
      return '''
[out:json][timeout:30];

(
  node["amenity"="veterinary"](around:$_searchRadius,$lat,$lng);
  way["amenity"="veterinary"](around:$_searchRadius,$lat,$lng);
  relation["amenity"="veterinary"](around:$_searchRadius,$lat,$lng);
);

out center;
''';
    }

    return '''
[out:json][timeout:30];

(
  node["shop"="pet"](around:$_searchRadius,$lat,$lng);
  way["shop"="pet"](around:$_searchRadius,$lat,$lng);
  relation["shop"="pet"](around:$_searchRadius,$lat,$lng);
);

out center;
''';
  }

  // ============================================================
  // FETCH NEARBY PLACES
  // ============================================================

  Future<void> _fetchPlaces() async {
    if (_userPosition == null) {
      print(
        '❌ Cannot search: Current location is null',
      );
      return;
    }

    final double lat =
        _userPosition!.latitude;

    final double lng =
        _userPosition!.longitude;

    print('================================');
    print('🔍 SEARCHING NEARBY PLACES');
    print('================================');

    print(
      '📍 Search center: $lat, $lng',
    );

    print(
      '🔎 Filter: $_selectedFilter',
    );

    print(
      '📏 Radius: $_searchRadius meters',
    );

    // Clear old places
    _places.clear();

    // Keep user marker only
    _markers.removeWhere(
          (marker) =>
      marker.markerId.value != 'user',
    );

    final query =
    _buildOverpassQuery(
      lat,
      lng,
    );

    print(
      '📝 Overpass Query:',
    );

    print(query);

    bool success = false;

    // Try multiple servers
    for (final server
    in _overpassServers) {
      try {
        print(
          '🌐 Trying Overpass server: $server',
        );

        final uri =
        Uri.parse(server).replace(
          queryParameters: {
            'data': query,
          },
        );

        final response =
        await http.get(
          uri,
          headers: {
            'Accept':
            'application/json',
            'User-Agent':
            'BioPet/1.0 Flutter App',
          },
        ).timeout(
          const Duration(
            seconds: 40,
          ),
        );

        print(
          '📡 Status: '
              '${response.statusCode}',
        );

        if (response.statusCode == 200) {
          print(
            '✅ Overpass API SUCCESS',
          );

          final data =
          json.decode(
            response.body,
          );

          final elements =
              data['elements']
              as List? ??
                  [];

          print(
            '📍 Places found: '
                '${elements.length}',
          );

          for (final el
          in elements) {
            _addPlace(
              el,
            );
          }

          success = true;

          break;
        } else {
          print(
            '❌ Server failed: '
                '${response.statusCode}',
          );
        }
      } catch (e) {
        print(
          '❌ Server error: $e',
        );
      }
    }

    if (!success) {
      print(
        '❌ ALL OVERPASS SERVERS FAILED',
      );
    }

    // Sort nearest first
    _sortPlaces();

    // Create markers
    _rebuildMarkers();

    if (!mounted) return;

    setState(() {});

    // Move map to user
    await _moveToCurrentLocation();
  }

  // ============================================================
  // ADD PLACE
  // ============================================================

  void _addPlace(
      dynamic el,
      ) {
    try {
      final tags =
          el['tags'] ?? {};

      final String name =
          tags['name'] ??
              tags['name:en'] ??
              tags['name:my'] ??
              'Unknown Place';

      final String amenity =
          tags['amenity'] ?? '';

      final String shop =
          tags['shop'] ?? '';

      final String phone =
          tags['phone'] ??
              tags['contact:phone'] ??
              '';

      final String street =
          tags['addr:street'] ??
              tags['addr:full'] ??
              '';

      double? pLat;
      double? pLng;

      // Node
      if (el['type'] == 'node') {
        pLat =
            (el['lat'] as num?)
                ?.toDouble();

        pLng =
            (el['lon'] as num?)
                ?.toDouble();
      }

      // Way / Relation
      else if (el['center'] != null) {
        pLat =
            (el['center']['lat']
            as num?)
                ?.toDouble();

        pLng =
            (el['center']['lon']
            as num?)
                ?.toDouble();
      }

      if (pLat == null ||
          pLng == null) {
        return;
      }

      // Determine type
      final bool isVet =
          amenity ==
              'veterinary';

      final bool isPetShop =
          shop == 'pet';

      // Calculate distance
      double distance =
      Geolocator.distanceBetween(
        _userPosition!.latitude,
        _userPosition!.longitude,
        pLat,
        pLng,
      );

      // Convert meters to km
      double distanceKm =
          distance / 1000;

      final String markerId =
          '${el['type']}_${el['id']}';

      final NearbyPlace place =
      NearbyPlace(
        id: markerId,
        name: name,
        latitude: pLat,
        longitude: pLng,
        isVet: isVet,
        isPetShop: isPetShop,
        distanceKm: distanceKm,
        phone: phone,
        address: street,
      );

      _places.add(place);

      print(
        '📍 Added: $name '
            '(${distanceKm.toStringAsFixed(2)} km)',
      );
    } catch (e) {
      print(
        '❌ Place error: $e',
      );
    }
  }

  // ============================================================
  // SORT BY MINIMUM DISTANCE
  // ============================================================

  void _sortPlaces() {
    _places.sort(
          (a, b) =>
          a.distanceKm
              .compareTo(
            b.distanceKm,
          ),
    );
  }

  void _rebuildMarkers() {

    _markers.removeWhere(
          (marker) =>
      marker.markerId.value !=
          'user',
    );

    for (final place
    in _places) {
      final double markerColor =
      place.isVet
          ? BitmapDescriptor
          .hueRed
          : BitmapDescriptor
          .hueGreen;

      final String emoji =
      place.isVet
          ? '🏥'
          : '🐾';

      final String typeText =
      place.isVet
          ? 'Vet Clinic'
          : 'Pet Shop';

      String snippet =
          '$typeText · '
          '${place.distanceKm.toStringAsFixed(2)} km';

      if (place.address
          .isNotEmpty) {
        snippet +=
        ' · ${place.address}';
      }

      _markers.add(
        Marker(
          markerId:
          MarkerId(
            place.id,
          ),
          position:
          LatLng(
            place.latitude,
            place.longitude,
          ),
          icon: BitmapDescriptor
              .defaultMarkerWithHue(
            markerColor,
          ),
          infoWindow:
          InfoWindow(
            title:
            '$emoji ${place.name}',
            snippet:
            snippet,
          ),
          onTap: () {
            _focusPlace(
              place,
            );
          },
        ),
      );
    }
  }

  // ============================================================
  // MOVE MAP TO PLACE
  // ============================================================

  Future<void> _focusPlace(
      NearbyPlace place,
      ) async {
    final LatLng location =
    LatLng(
      place.latitude,
      place.longitude,
    );

    print(
      '🗺️ Moving to: '
          '${place.name}',
    );

    if (_mapController != null) {
      await _mapController!
          .animateCamera(
        CameraUpdate.newLatLngZoom(
          location,
          17,
        ),
      );
    }
  }

  // ============================================================
  // MAP CREATED
  // ============================================================

  void _onMapCreated(
      GoogleMapController controller,
      ) async {
    _mapController =
        controller;

    print(
      '🗺️ Google Map created',
    );

    if (_userPosition != null) {
      await _moveToCurrentLocation();
    }
  }

  // ============================================================
  // FILTER CHANGE
  // ============================================================

  Future<void> _changeFilter(
      String value,
      ) async {
    if (_selectedFilter ==
        value) {
      return;
    }

    setState(() {
      _selectedFilter =
          value;

      _isLoading = true;

      _places.clear();
    });

    await _fetchPlaces();

    if (!mounted) return;

    setState(() {
      _isLoading = false;
    });
  }

  // ============================================================
  // BUILD
  // ============================================================

  @override
  Widget build(
      BuildContext context,
      ) {
    final LatLng center =
    _userPosition != null
        ? LatLng(
      _userPosition!
          .latitude,
      _userPosition!
          .longitude,
    )
        : _yangon;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Nearby Pet Shops & Clinics',
        ),
        backgroundColor:
        Colors.teal,
        foregroundColor:
        Colors.white,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.my_location,
            ),
            tooltip:
            'My Location',
            onPressed:
            _moveToCurrentLocation,
          ),
          IconButton(
            icon: const Icon(
              Icons.refresh,
            ),
            tooltip:
            'Refresh',
            onPressed:
            _init,
          ),
        ],
      ),

      body: Column(
        children: [

          // ==================================================
          // FILTER BUTTONS
          // ==================================================

          Container(
            color:
            Colors.teal.shade50,
            padding:
            const EdgeInsets
                .symmetric(
              horizontal: 12,
              vertical: 8,
            ),
            child:
            SingleChildScrollView(
              scrollDirection:
              Axis.horizontal,
              child: Row(
                children: [
                  _chip(
                    'All',
                    'all',
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  _chip(
                    '🐾 Pet Shop',
                    'pet',
                  ),

                  const SizedBox(
                    width: 8,
                  ),

                  _chip(
                    '🏥 Vet Clinic',
                    'vet',
                  ),
                ],
              ),
            ),
          ),

          // ==================================================
          // MAP
          // ==================================================

          SizedBox(
            height: 400,
            child: Stack(
              children: [

                GoogleMap(
                  initialCameraPosition:
                  CameraPosition(
                    target:
                    center,
                    zoom:
                    14,
                  ),

                  markers:
                  _markers,

                  myLocationEnabled:
                  true,

                  myLocationButtonEnabled:
                  false,

                  zoomControlsEnabled:
                  true,

                  compassEnabled:
                  true,

                  mapToolbarEnabled:
                  true,

                  onMapCreated:
                  _onMapCreated,
                ),

                // Loading
                if (_isLoading)
                  Container(
                    color:
                    Colors.black26,
                    child:
                    const Center(
                      child:
                      Card(
                        child:
                        Padding(
                          padding:
                          EdgeInsets.all(
                            20,
                          ),
                          child:
                          Column(
                            mainAxisSize:
                            MainAxisSize.min,
                            children: [
                              CircularProgressIndicator(
                                color:
                                Colors.teal,
                              ),
                              SizedBox(
                                height:
                                12,
                              ),
                              Text(
                                'Finding nearby places...',
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),

                // Count
                if (!_isLoading &&
                    _places.isNotEmpty)
                  Positioned(
                    top:
                    12,
                    left:
                    12,
                    child:
                    Container(
                      padding:
                      const EdgeInsets
                          .symmetric(
                        horizontal:
                        12,
                        vertical:
                        8,
                      ),
                      decoration:
                      BoxDecoration(
                        color:
                        Colors.white,
                        borderRadius:
                        BorderRadius
                            .circular(
                          20,
                        ),
                        boxShadow: const [
                          BoxShadow(
                            color:
                            Colors.black26,
                            blurRadius:
                            4,
                          ),
                        ],
                      ),
                      child:
                      Text(
                        '📍 ${_places.length} places found',
                        style:
                        const TextStyle(
                          fontWeight:
                          FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // ==================================================
          // LIST HEADER
          // ==================================================

          Container(
            width:
            double.infinity,
            padding:
            const EdgeInsets
                .symmetric(
              horizontal: 16,
              vertical: 12,
            ),
            color:
            Colors.grey.shade100,
            child:
            Row(
              mainAxisAlignment:
              MainAxisAlignment
                  .spaceBetween,
              children: [
                const Text(
                  'Nearby Places',
                  style:
                  TextStyle(
                    fontSize:
                    18,
                    fontWeight:
                    FontWeight.bold,
                  ),
                ),

                if (_places
                    .isNotEmpty)
                  Text(
                    'Nearest first',
                    style:
                    TextStyle(
                      color:
                      Colors.grey.shade600,
                      fontSize:
                      12,
                    ),
                  ),
              ],
            ),
          ),

          // ==================================================
          // PLACE LIST
          // ==================================================

          Expanded(
            child:
            _buildPlaceList(),
          ),
        ],
      ),
    );
  }

  // ============================================================
  // PLACE LIST
  // ============================================================

  Widget _buildPlaceList() {
    if (_isLoading) {
      return const Center(
        child:
        CircularProgressIndicator(
          color:
          Colors.teal,
        ),
      );
    }

    if (_locationMessage
        .isNotEmpty) {
      return Center(
        child:
        Padding(
          padding:
          const EdgeInsets.all(
            20,
          ),
          child:
          Text(
            '⚠️ $_locationMessage',
            textAlign:
            TextAlign.center,
          ),
        ),
      );
    }

    if (_places.isEmpty) {
      return Center(
        child:
        Padding(
          padding:
          const EdgeInsets.all(
            20,
          ),
          child:
          Text(
            _selectedFilter ==
                'pet'
                ? '⚠️ No pet shops found nearby.'
                : _selectedFilter ==
                'vet'
                ? '⚠️ No vet clinics found nearby.'
                : '⚠️ No pet shops or clinics found nearby.',
            textAlign:
            TextAlign.center,
          ),
        ),
      );
    }

    return ListView
        .separated(
      padding:
      const EdgeInsets.all(
        12,
      ),
      itemCount:
      _places.length,
      separatorBuilder:
          (_, __) =>
      const SizedBox(
        height:
        8,
      ),
      itemBuilder:
          (context, index) {
        final place =
        _places[index];

        return _placeCard(
          place,
          index,
        );
      },
    );
  }

  // ============================================================
  // PLACE CARD
  // ============================================================

  Widget _placeCard(
      NearbyPlace place,
      int index,
      ) {
    final bool isVet =
        place.isVet;

    return Card(
      elevation:
      2,
      shape:
      RoundedRectangleBorder(
        borderRadius:
        BorderRadius
            .circular(
          12,
        ),
      ),
      child:
      InkWell(
        borderRadius:
        BorderRadius
            .circular(
          12,
        ),
        onTap: () {
          _focusPlace(
            place,
          );
        },
        child:
        Padding(
          padding:
          const EdgeInsets.all(
            12,
          ),
          child:
          Row(
            children: [

              // Number
              CircleAvatar(
                backgroundColor:
                isVet
                    ? Colors.red
                    .shade50
                    : Colors.green
                    .shade50,
                child:
                Text(
                  '${index + 1}',
                  style:
                  TextStyle(
                    fontWeight:
                    FontWeight.bold,
                    color:
                    isVet
                        ? Colors.red
                        : Colors.green,
                  ),
                ),
              ),

              const SizedBox(
                width:
                12,
              ),

              // Icon
              Container(
                width:
                48,
                height:
                48,
                decoration:
                BoxDecoration(
                  color:
                  isVet
                      ? Colors.red
                      .shade50
                      : Colors.green
                      .shade50,
                  borderRadius:
                  BorderRadius
                      .circular(
                    10,
                  ),
                ),
                child:
                Icon(
                  isVet
                      ? Icons
                      .local_hospital
                      : Icons
                      .pets,
                  color:
                  isVet
                      ? Colors.red
                      : Colors.green,
                ),
              ),

              const SizedBox(
                width:
                12,
              ),

              // Information
              Expanded(
                child:
                Column(
                  crossAxisAlignment:
                  CrossAxisAlignment
                      .start,
                  children: [

                    Text(
                      place.name,
                      maxLines:
                      2,
                      overflow:
                      TextOverflow
                          .ellipsis,
                      style:
                      const TextStyle(
                        fontSize:
                        16,
                        fontWeight:
                        FontWeight.bold,
                      ),
                    ),

                    const SizedBox(
                      height:
                      4,
                    ),

                    Text(
                      isVet
                          ? '🏥 Vet Clinic'
                          : '🐾 Pet Shop',
                      style:
                      TextStyle(
                        color:
                        isVet
                            ? Colors.red
                            : Colors.green,
                        fontSize:
                        13,
                        fontWeight:
                        FontWeight.w500,
                      ),
                    ),

                    const SizedBox(
                      height:
                      4,
                    ),

                    // Distance
                    Row(
                      children: [
                        const Icon(
                          Icons
                              .location_on,
                          size:
                          16,
                          color:
                          Colors.teal,
                        ),

                        const SizedBox(
                          width:
                          4,
                        ),

                        Text(
                          _formatDistance(
                            place.distanceKm,
                          ),
                          style:
                          const TextStyle(
                            fontWeight:
                            FontWeight.bold,
                            color:
                            Colors.teal,
                          ),
                        ),
                      ],
                    ),

                    if (place.address
                        .isNotEmpty)
                      Padding(
                        padding:
                        const EdgeInsets
                            .only(
                          top:
                          4,
                        ),
                        child:
                        Text(
                          place.address,
                          maxLines:
                          1,
                          overflow:
                          TextOverflow
                              .ellipsis,
                          style:
                          TextStyle(
                            fontSize:
                            12,
                            color:
                            Colors.grey
                                .shade600,
                          ),
                        ),
                      ),

                    if (place.phone
                        .isNotEmpty)
                      Padding(
                        padding:
                        const EdgeInsets
                            .only(
                          top:
                          4,
                        ),
                        child:
                        Text(
                          '📞 ${place.phone}',
                          style:
                          const TextStyle(
                            fontSize:
                            12,
                          ),
                        ),
                      ),
                  ],
                ),
              ),

              // Map button
              IconButton(
                icon:
                const Icon(
                  Icons
                      .map_outlined,
                  color:
                  Colors.teal,
                ),
                tooltip:
                'Show on map',
                onPressed:
                    () {
                  _focusPlace(
                    place,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ============================================================
  // FORMAT DISTANCE
  // ============================================================

  String _formatDistance(
      double distanceKm,
      ) {
    if (distanceKm <
        1) {
      final int meters =
      (distanceKm *
          1000)
          .round();

      return '$meters m away';
    }

    return '${distanceKm.toStringAsFixed(2)} km away';
  }

  // ============================================================
  // FILTER CHIP
  // ============================================================

  Widget _chip(
      String label,
      String value,
      ) {
    final bool selected =
        _selectedFilter ==
            value;

    return ChoiceChip(
      label:
      Text(
        label,
        style:
        const TextStyle(
          fontSize:
          12,
        ),
      ),
      selected:
      selected,
      selectedColor:
      Colors.teal,
      labelStyle:
      TextStyle(
        color:
        selected
            ? Colors.white
            : Colors.black87,
      ),
      onSelected:
          (_) {
        _changeFilter(
          value,
        );
      },
    );
  }
}

// ============================================================
// NEARBY PLACE MODEL
// ============================================================

class NearbyPlace {
  final String id;

  final String name;

  final double latitude;

  final double longitude;

  final bool isVet;

  final bool isPetShop;

  final double distanceKm;

  final String phone;

  final String address;

  NearbyPlace({
    required this.id,
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.isVet,
    required this.isPetShop,
    required this.distanceKm,
    required this.phone,
    required this.address,
  });
}