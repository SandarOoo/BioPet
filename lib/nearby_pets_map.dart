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
  bool _isLoading = true;
  String _selectedFilter = 'all';

  static const LatLng _yangon = LatLng(16.8661, 96.1951);

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    setState(() => _isLoading = true);
    await _getUserLocation();
    await _fetchPlaces();
    setState(() => _isLoading = false);
  }

  Future<void> _getUserLocation() async {
    try {
      LocationPermission perm = await Geolocator.checkPermission();
      if (perm == LocationPermission.denied) {
        perm = await Geolocator.requestPermission();
      }
      if (perm == LocationPermission.whileInUse ||
          perm == LocationPermission.always) {
        _userPosition = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high,
        );
      }
    } catch (e) {
      debugPrint('Location error: $e');
    }
  }

  Future<void> _fetchPlaces() async {
    final center = _userPosition != null
        ? LatLng(_userPosition!.latitude, _userPosition!.longitude)
        : _yangon;

    _markers.clear();

    if (_userPosition != null) {
      _markers.add(Marker(
        markerId: const MarkerId('user'),
        position: center,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: '📍 Your Location'),
      ));
    }

    String amenityFilter = '';
    if (_selectedFilter == 'all') {
      amenityFilter = '["amenity"~"veterinary|pet_shop"]';
    } else if (_selectedFilter == 'vet') {
      amenityFilter = '["amenity"="veterinary"]';
    } else {
      amenityFilter = '["amenity"="pet_shop"]';
    }

    final double lat = center.latitude;
    final double lng = center.longitude;

    final query = '''
[out:json];
(
  node$amenityFilter(around:5000,$lat,$lng);
  way$amenityFilter(around:5000,$lat,$lng);
);
out center;
''';

    try {
      final response = await http.post(
        Uri.parse('https://overpass-api.de/api/interpreter'),
        body: query,
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final elements = data['elements'] as List;

        for (final el in elements) {
          final tags = el['tags'] ?? {};
          final name = tags['name:en'] ??
              tags['name'] ??
              'Unknown';
          final amenity = tags['amenity'] ?? '';
          final phone = tags['phone'] ?? tags['contact:phone'] ?? '';
          final street = tags['addr:street'] ?? tags['addr:full'] ?? '';

          double? pLat, pLng;
          if (el['type'] == 'node') {
            pLat = el['lat']?.toDouble();
            pLng = el['lon']?.toDouble();
          } else if (el['center'] != null) {
            pLat = el['center']['lat']?.toDouble();
            pLng = el['center']['lon']?.toDouble();
          }

          if (pLat == null || pLng == null) continue;

          final isVet = amenity == 'veterinary';
          final color = isVet
              ? BitmapDescriptor.hueRed
              : BitmapDescriptor.hueGreen;
          final emoji = isVet ? '🏥' : '🐾';

          _markers.add(Marker(
            markerId: MarkerId(el['id'].toString()),
            position: LatLng(pLat, pLng),
            icon: BitmapDescriptor.defaultMarkerWithHue(color),
            infoWindow: InfoWindow(
              title: '$emoji $name',
              snippet: [
                if (street.isNotEmpty) street,
                if (phone.isNotEmpty) '📞 $phone',
              ].join(' · '),
            ),
          ));
        }

        setState(() {});
        _mapController?.animateCamera(
          CameraUpdate.newLatLngZoom(center, 13),
        );
      }
    } catch (e) {
      debugPrint('Places error: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    final center = _userPosition != null
        ? LatLng(_userPosition!.latitude, _userPosition!.longitude)
        : _yangon;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Nearby Pet Shops & Clinics'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _init,
            tooltip: 'Refresh',
          ),
        ],
      ),
      body: Column(
        children: [
          Container(
            color: Colors.teal.shade50,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              children: [
                _chip('All', 'all'),
                const SizedBox(width: 8),
                _chip('🐾 Pet Shop', 'pet'),
                const SizedBox(width: 8),
                _chip('🏥 Vet Clinic', 'vet'),
              ],
            ),
          ),
          Container(
            color: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            child: Row(
              children: const [
                Icon(Icons.location_on, color: Colors.green, size: 16),
                Text(' Pet Shop   ', style: TextStyle(fontSize: 12)),
                Icon(Icons.location_on, color: Colors.red, size: 16),
                Text(' Vet Clinic   ', style: TextStyle(fontSize: 12)),
                Icon(Icons.location_on, color: Colors.blue, size: 16),
                Text(' You', style: TextStyle(fontSize: 12)),
              ],
            ),
          ),
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: center,
                    zoom: 13,
                  ),
                  markers: _markers,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  zoomControlsEnabled: true,
                  onMapCreated: (c) => _mapController = c,
                ),
                if (_isLoading)
                  Container(
                    color: Colors.black26,
                    child: const Center(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircularProgressIndicator(color: Colors.teal),
                          SizedBox(height: 12),
                          Text(
                            'Searching nearby places...',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                if (!_isLoading && _markers.length <= 1)
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(color: Colors.black26, blurRadius: 4)
                        ],
                      ),
                      child: const Text(
                        '⚠️ No pet shops or clinics found nearby.',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 13),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _chip(String label, String value) {
    final selected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(label, style: const TextStyle(fontSize: 12)),
      selected: selected,
      selectedColor: Colors.teal,
      labelStyle: TextStyle(
        color: selected ? Colors.white : Colors.black87,
      ),
      onSelected: (_) {
        setState(() => _selectedFilter = value);
        _fetchPlaces();
      },
    );
  }
}