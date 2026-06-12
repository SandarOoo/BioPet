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

class _MapScreenState extends State<MapScreen> {
  LatLng? currentPosition;
  GoogleMapController? mapController;
  final Set<Marker> _markers = {};
  bool _isLoadingPlaces = false;
  String _filter = 'all'; // all | vet | pet

  @override
  void initState() {
    super.initState();
    getUserLocation();
  }

  Future<void> getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {

      setState(() {
        currentPosition = const LatLng(16.8661, 96.1951); // Yangon
      });
      _fetchNearbyPlaces();
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          currentPosition = const LatLng(16.8661, 96.1951); // Default
        });
        _fetchNearbyPlaces();
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      ).timeout(const Duration(seconds: 10));

      setState(() {
        currentPosition = LatLng(position.latitude, position.longitude);
      });
    } catch (e) {
      setState(() {
        currentPosition = const LatLng(16.8661, 96.1951); // Default fallback
      });
    }

    _fetchNearbyPlaces();
  }

  Future<void> _fetchNearbyPlaces() async {
    if (currentPosition == null) return;
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

    final query = '''
[out:json];
(
  node$amenityFilter(around:5000,$lat,$lng);
  way$amenityFilter(around:5000,$lat,$lng);
);
out center;
''';

    try {
      final response = await http
          .post(
        Uri.parse('https://overpass-api.de/api/interpreter'),
        body: query,
      )
          .timeout(const Duration(seconds: 15));

      final newMarkers = <Marker>{};

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

          final isVet = amenity == 'veterinary';
          newMarkers.add(Marker(
            markerId: MarkerId(el['id'].toString()),
            position: LatLng(pLat, pLng),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              isVet ? BitmapDescriptor.hueRed : BitmapDescriptor.hueGreen,
            ),
            infoWindow: InfoWindow(
              title: '${isVet ? "🏥" : "🐾"} $name',
              snippet: [
                if (street.isNotEmpty) street,
                if (phone.isNotEmpty) '📞 $phone',
              ].join(' · '),
            ),
          ));
        }
      }

      setState(() {
        _markers
          ..clear()
          ..addAll(newMarkers);
        _isLoadingPlaces = false;
      });
    } catch (e) {
      setState(() => _isLoadingPlaces = false);
      debugPrint('Overpass error: $e');
    }
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
          Expanded(
            child: Stack(
              children: [
                GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: currentPosition!,
                    zoom: 14,
                  ),
                  markers: _markers,
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
        ],
      ),
    );
  }
}