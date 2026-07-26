import 'package:google_maps_flutter/google_maps_flutter.dart';

class NearbyPlace {
  final String id;
  final String name;
  final String type;
  final double latitude;
  final double longitude;
  final String phone;
  final String address;
  final double distanceKm;

  NearbyPlace({
    required this.id,
    required this.name,
    required this.type,
    required this.latitude,
    required this.longitude,
    required this.phone,
    required this.address,
    required this.distanceKm,
  });

  LatLng get position => LatLng(latitude, longitude);
}