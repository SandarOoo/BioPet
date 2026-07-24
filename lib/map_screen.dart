import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

/// Simple data holder for a nearby place (vet clinic or pet shop).
class _Place {
  final String id;
  final String name;
  final String amenity; // 'veterinary' | 'pet_shop'
  final String phone;
  final String street;
  final LatLng position;
  final double distanceMeters;

  _Place({
    required this.id,
    required this.name,
    required this.amenity,
    required this.phone,
    required this.street,
    required this.position,
    required this.distanceMeters,
  });

  bool get isVet => amenity == 'veterinary';

  String get distanceLabel {
    if (distanceMeters < 1000) {
      return '${distanceMeters.toStringAsFixed(0)} m';
    }
    return '${(distanceMeters / 1000).toStringAsFixed(2)} km';
  }
}

class _MapScreenState extends State<MapScreen> {
  LatLng? currentPosition;
  GoogleMapController? mapController;
  final Set<Marker> _markers = {};
  final Set<Polyline> _polylines = {};
  List<_Place> _places = [];
  bool _isLoadingPlaces = false;
  String _filter = 'all'; // all | vet | pet

  @override
  void initState() {
    super.initState();
    getUserLocation();
  }

  Future<void> getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    debugPrint('=== serviceEnabled: $serviceEnabled');
    if (!serviceEnabled) {
      setState(() {
        currentPosition = const LatLng(16.8661, 96.1951); // Yangon fallback
      });
      _fetchNearbyPlaces();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    debugPrint('=== permission: $permission');
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      debugPrint('=== permission after request: $permission');
      if (permission == LocationPermission.denied) {
        setState(() {
          currentPosition = const LatLng(16.8661, 96.1951); // Default
        });
        _fetchNearbyPlaces();
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        currentPosition = const LatLng(16.8661, 96.1951); // Default
      });
      _fetchNearbyPlaces();
      return;
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 10));

      setState(() {
        currentPosition = LatLng(position.latitude, position.longitude);
      });
      debugPrint('=== Got position: ${position.latitude}, ${position.longitude}');
    } catch (e) {
      debugPrint('=== getCurrentPosition error: $e');
      setState(() {
        currentPosition = const LatLng(16.8661, 96.1951); // Default fallback
      });
    }

    _fetchNearbyPlaces();
  }

  Future<void> _fetchNearbyPlaces() async {
    if (currentPosition == null) {
      debugPrint('=== currentPosition is NULL, exiting');
      return;
    }
    setState(() => _isLoadingPlaces = true);

    String amenityFilter;
    if (_filter == 'vet') {
      amenityFilter = '["amenity"="veterinary"]';
    } else if (_filter == 'pet') {
      amenityFilter = '["amenity"="pet_shop"]';
    } else {
      amenityFilter = '["amenity"~"veterinary|pet_shop"]';
    }

    final lat = currentPosition!.latitude;
    final lng = currentPosition!.longitude;

    // Radius in meters covering a whole city (e.g. Yangon ~40km across).
    const radiusMeters = 40000;

    final query = '''
[out:json][timeout:25];
(
  node$amenityFilter(around:$radiusMeters,$lat,$lng);
  way$amenityFilter(around:$radiusMeters,$lat,$lng);
);
out center;
''';

    try {
      // IMPORTANT: send as form body (Map), not raw String, or Overpass
      // returns 406 Not Acceptable.
      final response = await http
          .post(
        Uri.parse('https://overpass-api.de/api/interpreter'),
        headers: {
          'Content-Type': 'application/x-www-form-urlencoded',
          'Accept': '*/*',
          'User-Agent': 'BioPetApp/1.0 (Flutter)',
        },
        body: {'data': query},
      )
          .timeout(const Duration(seconds: 30));

      debugPrint('=== Overpass status: ${response.statusCode}');

      final newMarkers = <Marker>{};
      final newPlaces = <_Place>[];

      // User location marker
      newMarkers.add(Marker(
        markerId: const MarkerId('user'),
        position: currentPosition!,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueAzure),
        infoWindow: const InfoWindow(title: 'Your Location'),
      ));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final elements = data['elements'] as List;
        debugPrint('=== Elements returned: ${elements.length}');

        for (final el in elements) {
          final tags = el['tags'] ?? {};
          final name = tags['name'] ?? tags['name:en'] ?? 'Unknown';
          final amenity = tags['amenity'] ?? '';
          final phone = tags['phone'] ?? tags['contact:phone'] ?? '';
          final street = tags['addr:street'] ?? '';

          double? pLat, pLng;
          if (el['type'] == 'node') {
            pLat = el['lat']?.toDouble();
            pLng = el['lon']?.toDouble();
          } else if (el['center'] != null) {
            pLat = el['center']['lat']?.toDouble();
            pLng = el['center']['lon']?.toDouble();
          }
          if (pLat == null || pLng == null) continue;

          final placePos = LatLng(pLat, pLng);
          final distance = Geolocator.distanceBetween(
            currentPosition!.latitude,
            currentPosition!.longitude,
            pLat,
            pLng,
          );

          final place = _Place(
            id: el['id'].toString(),
            name: name,
            amenity: amenity,
            phone: phone,
            street: street,
            position: placePos,
            distanceMeters: distance,
          );
          newPlaces.add(place);

          final isVet = place.isVet;
          newMarkers.add(Marker(
            markerId: MarkerId(place.id),
            position: placePos,
            icon: BitmapDescriptor.defaultMarkerWithHue(
              isVet ? BitmapDescriptor.hueRed : BitmapDescriptor.hueGreen,
            ),
            infoWindow: InfoWindow(
              title: '${isVet ? "🏥" : "🐾"} $name',
              snippet: [
                place.distanceLabel,
                if (street.isNotEmpty) street,
                if (phone.isNotEmpty) '📞 $phone',
              ].join(' · '),
            ),
            onTap: () => _showPlaceSheet(place),
          ));
        }
      } else {
        debugPrint('=== Overpass error body: ${response.body}');
      }

      // Sort places by distance ascending (nearest first)
      newPlaces.sort((a, b) => a.distanceMeters.compareTo(b.distanceMeters));

      setState(() {
        _markers
          ..clear()
          ..addAll(newMarkers);
        _places = newPlaces;
        _isLoadingPlaces = false;
      });
      debugPrint('=== Final marker count: ${_markers.length}, places: ${_places.length}');
    } catch (e) {
      setState(() => _isLoadingPlaces = false);
      debugPrint('=== Overpass exception: $e');
    }
  }

  /// Bottom sheet showing place details + distance, with a button to
  /// focus the map camera on that place.
  void _showPlaceSheet(_Place place) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '${place.isVet ? "🏥" : "🐾"} ${place.name}',
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Icon(Icons.directions_walk, size: 18, color: Colors.grey),
                  const SizedBox(width: 6),
                  Text('${place.distanceLabel} from your location'),
                ],
              ),
              if (place.street.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.location_on_outlined,
                        size: 18, color: Colors.grey),
                    const SizedBox(width: 6),
                    Expanded(child: Text(place.street)),
                  ],
                ),
              ],
              if (place.phone.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    const Icon(Icons.phone_outlined,
                        size: 18, color: Colors.grey),
                    const SizedBox(width: 6),
                    Text(place.phone),
                  ],
                ),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    _focusOnPlace(place);
                  },
                  child: const Text('Show on map'),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // TODO: move this to a safer place (e.g. --dart-define) for production.
  static const String _googleMapsApiKey = 'AIzaSyC4uNvcXlhJHKKMHRqS0G9IP__BLyT0krI';

  /// Animates the map camera to the given place, fetches the real road
  /// route from Google Directions API, draws it on the map, and fits
  /// both points in view.
  Future<void> _focusOnPlace(_Place place) async {
    if (currentPosition == null) return;

    // Fit camera to both points immediately (route line may take a moment).
    _fitBounds(currentPosition!, place.position);

    try {
      final origin = '${currentPosition!.latitude},${currentPosition!.longitude}';
      final destination = '${place.position.latitude},${place.position.longitude}';

      final url = Uri.parse(
        'https://maps.googleapis.com/maps/api/directions/json'
            '?origin=$origin&destination=$destination&mode=driving&key=$_googleMapsApiKey',
      );

      final response = await http.get(url).timeout(const Duration(seconds: 15));
      debugPrint('=== Directions status: ${response.statusCode}');

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        debugPrint('=== Directions API status field: ${data['status']}');

        if (data['status'] == 'OK') {
          final route = data['routes'][0];
          final polylinePoints = route['overview_polyline']['points'] as String;
          final points = _decodePolyline(polylinePoints);

          setState(() {
            _polylines
              ..clear()
              ..add(Polyline(
                polylineId: const PolylineId('route'),
                points: points,
                color: const Color(0xFF2E7D32),
                width: 5,
              ));
          });

          // Fit camera to the actual route bounds.
          if (points.isNotEmpty) {
            double minLat = points.first.latitude, maxLat = points.first.latitude;
            double minLng = points.first.longitude, maxLng = points.first.longitude;
            for (final p in points) {
              if (p.latitude < minLat) minLat = p.latitude;
              if (p.latitude > maxLat) maxLat = p.latitude;
              if (p.longitude < minLng) minLng = p.longitude;
              if (p.longitude > maxLng) maxLng = p.longitude;
            }
            mapController?.animateCamera(
              CameraUpdate.newLatLngBounds(
                LatLngBounds(
                  southwest: LatLng(minLat, minLng),
                  northeast: LatLng(maxLat, maxLng),
                ),
                80,
              ),
            );
          }
          return;
        }
      }

      // Fallback: straight dashed line if Directions API fails.
      _drawStraightLine(place);
    } catch (e) {
      debugPrint('=== Directions exception: $e');
      _drawStraightLine(place);
    }
  }

  /// Draws a simple straight dashed line as a fallback when the
  /// Directions API is unavailable.
  void _drawStraightLine(_Place place) {
    if (currentPosition == null) return;
    setState(() {
      _polylines
        ..clear()
        ..add(Polyline(
          polylineId: const PolylineId('route_fallback'),
          points: [currentPosition!, place.position],
          color: Colors.grey,
          width: 4,
          patterns: [PatternItem.dash(12), PatternItem.gap(8)],
        ));
    });
  }

  /// Fits the camera to show both [a] and [b].
  void _fitBounds(LatLng a, LatLng b) {
    final bounds = LatLngBounds(
      southwest: LatLng(
        a.latitude < b.latitude ? a.latitude : b.latitude,
        a.longitude < b.longitude ? a.longitude : b.longitude,
      ),
      northeast: LatLng(
        a.latitude > b.latitude ? a.latitude : b.latitude,
        a.longitude > b.longitude ? a.longitude : b.longitude,
      ),
    );
    mapController?.animateCamera(CameraUpdate.newLatLngBounds(bounds, 80));
  }

  /// Decodes an encoded Google polyline string into a list of LatLng points.
  List<LatLng> _decodePolyline(String encoded) {
    final List<LatLng> points = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlat = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      final dlng = (result & 1) != 0 ? ~(result >> 1) : (result >> 1);
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }
    return points;
  }

  Widget _chip(String label, String value) {
    final selected = _filter == value;
    return ChoiceChip(
      label: Text(label),
      selected: selected,
      onSelected: (_) {
        setState(() => _filter = value);
        _fetchNearbyPlaces();
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Nearby Pet Shops & Vet Clinics"),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchNearbyPlaces,
          ),
        ],
      ),
      body: currentPosition == null
          ? const Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
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
          // ── Map ─────────────────────────────────────────
          SizedBox(
            height: 300,
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: currentPosition!,
                    zoom: 14,
                  ),
                  markers: _markers,
                  polylines: _polylines,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  onMapCreated: (c) => mapController = c,
                ),
                if (_isLoadingPlaces)
                  const Positioned(
                    top: 12,
                    left: 0,
                    right: 0,
                    child: Center(
                      child: CircularProgressIndicator(),
                    ),
                  ),
              ],
            ),
          ),
          const Divider(height: 1),
          // ── List of nearby places, sorted by distance ───
          Expanded(
            child: _places.isEmpty
                ? Center(
              child: _isLoadingPlaces
                  ? const CircularProgressIndicator()
                  : const Text('No places found nearby.'),
            )
                : ListView.separated(
              itemCount: _places.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (context, index) {
                final place = _places[index];
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                    place.isVet ? Colors.red[50] : Colors.green[50],
                    child: Text(place.isVet ? '🏥' : '🐾'),
                  ),
                  title: Text(place.name),
                  subtitle: place.street.isNotEmpty
                      ? Text(place.street)
                      : null,
                  trailing: Text(
                    place.distanceLabel,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, color: Colors.green),
                  ),
                  onTap: () => _showPlaceSheet(place),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}