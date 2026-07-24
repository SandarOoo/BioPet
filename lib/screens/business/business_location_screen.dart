import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

import '../../services/business_service.dart';
import '../../services/api_service.dart';

class BusinessLocationScreen extends StatefulWidget {
  const BusinessLocationScreen({super.key});

  @override
  State<BusinessLocationScreen> createState() =>
      _BusinessLocationScreenState();
}

class _BusinessLocationScreenState extends State<BusinessLocationScreen> {

  GoogleMapController? _mapController;

  LatLng? selectedLocation;

  final BusinessService service = BusinessService();

  @override
  void initState() {
    super.initState();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      getCurrentLocation();
    });
  }

  Future<void> getCurrentLocation() async {

    bool serviceEnabled =
    await Geolocator.isLocationServiceEnabled();

    if (!serviceEnabled) {

      await Geolocator.openLocationSettings();

      return;
    }

    LocationPermission permission =
    await Geolocator.checkPermission();

    if (permission == LocationPermission.denied) {

      permission =
      await Geolocator.requestPermission();
    }

    if (permission == LocationPermission.deniedForever) {

      ScaffoldMessenger.of(context).showSnackBar(

        const SnackBar(

          content: Text(
              "Location permission permanently denied"),

        ),

      );

      return;
    }

    final position =
    await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final current =
    LatLng(position.latitude, position.longitude);

    setState(() {

      selectedLocation = current;

    });

    _mapController?.animateCamera(

      CameraUpdate.newCameraPosition(

        CameraPosition(

          target: current,

          zoom: 17,

        ),

      ),

    );
  }

  void selectLocation(LatLng position) {

    setState(() {

      selectedLocation = position;

    });

  }

  Future<void> saveLocation() async {

    if (selectedLocation == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Please select shop location"),
        ),
      );
      return;
    }
    final token = await ApiService.getToken();
    if (token == null) return;
    final success = await service.updateLocation(
      token,
      selectedLocation!.latitude,
      selectedLocation!.longitude,
    );

    if(!mounted) return;

    if (success) {
      Navigator.pushReplacementNamed(
        context,
        "/business-submit",
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Location save failed"))
      );
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(

        title: const Text("Pick Shop Location"),

      ),

      body: Stack(

        children: [

          GoogleMap(

            onMapCreated: (controller) {

              _mapController = controller;

            },

            initialCameraPosition: const CameraPosition(

              target: LatLng(16.8661, 96.1951),

              zoom: 14,

            ),

            myLocationEnabled: true,

            myLocationButtonEnabled: true,

            zoomControlsEnabled: true,

            compassEnabled: true,

            onTap: selectLocation,

            markers: selectedLocation == null
                ? {}
                : {
              Marker(
                markerId:
                const MarkerId("shop"),
                position: selectedLocation!,
              ),
            },
          ),

          Positioned(

            bottom: 25,

            left: 20,

            right: 20,

            child: ElevatedButton(

              onPressed: saveLocation,

              child: const Text(
                "Save Location",
              ),

            ),

          ),

        ],

      ),

    );
  }
}