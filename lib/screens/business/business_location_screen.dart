import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

import '../../services/api_service.dart';
import '../../services/business_service.dart';

class BusinessLocationScreen extends StatefulWidget {
  const BusinessLocationScreen({super.key});

  @override
  State<BusinessLocationScreen> createState() =>
      _BusinessLocationScreenState();
}

class _BusinessLocationScreenState extends State<BusinessLocationScreen> {
  static const Color _emerald = Color(0xFF065F46);
  static const Color _mint = Color(0xFFA7F3D0);
  static const Color _cream = Color(0xFFFFF8E7);
  static const Color _ink = Color(0xFF102A24);
  static const Color _page = Color(0xFFF7FAF6);

  GoogleMapController? _mapController;
  LatLng? selectedLocation;
  bool locating = false;
  bool saving = false;

  final BusinessService service = BusinessService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => getCurrentLocation());
  }

  Future<void> getCurrentLocation() async {
    if (locating) return;
    setState(() => locating = true);

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();

      if (!serviceEnabled) {
        if (mounted) {
          _showMessage('Please turn on location services.');
        }
        await Geolocator.openLocationSettings();
        return;
      }

      var permission = await Geolocator.checkPermission();

      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        if (mounted) {
          _showMessage(
            permission == LocationPermission.deniedForever
                ? 'Location permission is permanently denied. Enable it in app settings.'
                : 'Location permission is required to select your shop.',
          );
        }
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      final current = LatLng(position.latitude, position.longitude);

      if (!mounted) return;
      setState(() => selectedLocation = current);

      await _mapController?.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(target: current, zoom: 17),
        ),
      );
    } catch (error) {
      if (mounted) _showMessage('Unable to get current location: $error');
    } finally {
      if (mounted) setState(() => locating = false);
    }
  }

  void selectLocation(LatLng position) {
    setState(() => selectedLocation = position);
  }

  Future<void> saveLocation() async {
    if (selectedLocation == null) {
      _showMessage('Tap the map to select your shop location.');
      return;
    }

    if (saving) return;
    setState(() => saving = true);

    try {
      final token = await ApiService.getToken();
      if (token == null) {
        if (mounted) {
          _showMessage('Your session has expired. Please sign in again.');
        }
        return;
      }

      final success = await service.updateLocation(
        token,
        selectedLocation!.latitude,
        selectedLocation!.longitude,
      );

      if (!mounted) return;

      if (success) {
        Navigator.pushReplacementNamed(context, '/business-submit');
      } else {
        _showMessage('Location could not be saved. Please try again.');
      }
    } catch (error) {
      if (mounted) _showMessage('Unable to save location: $error');
    } finally {
      if (mounted) setState(() => saving = false);
    }
  }

  void _showMessage(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        backgroundColor: _ink,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final coordinateText = selectedLocation == null
        ? 'No location selected'
        : '${selectedLocation!.latitude.toStringAsFixed(6)}, '
            '${selectedLocation!.longitude.toStringAsFixed(6)}';

    return Scaffold(
      backgroundColor: _page,
      appBar: AppBar(
        backgroundColor: _page,
        surfaceTintColor: _page,
        elevation: 0,
        title: const Text(
          'Shop Location',
          style: TextStyle(color: _ink, fontWeight: FontWeight.w800),
        ),
      ),
      body: SafeArea(
        child: Stack(
          children: [
            Positioned.fill(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(28),
                ),
                child: GoogleMap(
                  onMapCreated: (controller) => _mapController = controller,
                  initialCameraPosition: const CameraPosition(
                    target: LatLng(16.8661, 96.1951),
                    zoom: 14,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  compassEnabled: true,
                  onTap: selectLocation,
                  markers: selectedLocation == null
                      ? <Marker>{}
                      : {
                          Marker(
                            markerId: const MarkerId('shop'),
                            position: selectedLocation!,
                            icon: BitmapDescriptor.defaultMarkerWithHue(
                              BitmapDescriptor.hueGreen,
                            ),
                            infoWindow: const InfoWindow(title: 'My shop'),
                          ),
                        },
                ),
              ),
            ),
            Positioned(
              top: 14,
              left: 16,
              right: 16,
              child: Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.96),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.08),
                      blurRadius: 18,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: const Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _LocationInfoIcon(),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Pin your real shop location',
                            style: TextStyle(
                              color: _ink,
                              fontWeight: FontWeight.w800,
                              fontSize: 16,
                            ),
                          ),
                          SizedBox(height: 4),
                          Text(
                            'Tap anywhere on the map or use your current location.',
                            style: TextStyle(
                              color: Color(0xFF60736E),
                              height: 1.35,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            Positioned(
              right: 16,
              top: 126,
              child: FloatingActionButton.small(
                heroTag: 'current_location',
                onPressed: locating ? null : getCurrentLocation,
                backgroundColor: Colors.white,
                foregroundColor: _emerald,
                elevation: 5,
                child: locating
                    ? const SizedBox(
                        width: 19,
                        height: 19,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: _emerald,
                        ),
                      )
                    : const Icon(Icons.my_location_rounded),
              ),
            ),
            Positioned(
              left: 16,
              right: 16,
              bottom: 16,
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.10),
                      blurRadius: 24,
                      offset: const Offset(0, 12),
                    ),
                  ],
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 42,
                          height: 42,
                          decoration: BoxDecoration(
                            color: selectedLocation == null
                                ? _cream
                                : _mint.withOpacity(0.50),
                            borderRadius: BorderRadius.circular(14),
                          ),
                          child: Icon(
                            selectedLocation == null
                                ? Icons.location_searching_rounded
                                : Icons.location_on_rounded,
                            color: _emerald,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                selectedLocation == null
                                    ? 'Choose a location'
                                    : 'Location selected',
                                style: const TextStyle(
                                  color: _ink,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                coordinateText,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                  color: Color(0xFF60736E),
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 14),
                    SizedBox(
                      width: double.infinity,
                      height: 52,
                      child: ElevatedButton.icon(
                        onPressed: saving ? null : saveLocation,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: _emerald,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: _emerald.withOpacity(0.42),
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(17),
                          ),
                        ),
                        icon: saving
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.check_rounded),
                        label: Text(
                          saving ? 'Saving...' : 'Save Location',
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _LocationInfoIcon extends StatelessWidget {
  const _LocationInfoIcon();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 42,
      height: 42,
      decoration: BoxDecoration(
        color: const Color(0xFFA7F3D0).withOpacity(0.45),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Icon(
        Icons.store_mall_directory_outlined,
        color: Color(0xFF065F46),
      ),
    );
  }
}
