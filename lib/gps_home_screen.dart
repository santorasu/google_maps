import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class GpsHomeScreen extends StatefulWidget {
  const GpsHomeScreen({super.key});

  @override
  State<GpsHomeScreen> createState() => _GpsHomeScreenState();
}

class _GpsHomeScreenState extends State<GpsHomeScreen> {
  Future<void> _getCurrentLocation() async {
    //TODO: Check if the app has permission to access the location
    bool isLocationEnable = await _isLocationPermissionEnable();
    if (isLocationEnable) {
      //TODO: Check if the GPS service on/off
      bool isGpsServiceEnable = await Geolocator.isLocationServiceEnabled();
      if (isGpsServiceEnable) {
        //TODO: Get current location
        Position position = await Geolocator.getCurrentPosition();
        print(position);
      } else {
        //TODO: if not, then move to gps service settings
        Geolocator.openLocationSettings();
      }
    } else {
      //TODO: If not then request the permission
      bool isPermissionGranted = await _requestPermission();
      if (isPermissionGranted) {
        _getCurrentLocation();
      }
    }
  }

  Future<bool> _isLocationPermissionEnable() async {
    LocationPermission locationPermission = await Geolocator.checkPermission();
    if (locationPermission == LocationPermission.whileInUse ||
        locationPermission == LocationPermission.always) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _requestPermission() async {
    LocationPermission locationPermission =
        await Geolocator.requestPermission();
    if (locationPermission == LocationPermission.whileInUse ||
        locationPermission == LocationPermission.always) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("GPS Service Home")),
      body: Column(
        children: [
          Text('Current Location'),
          TextButton(
            onPressed: () {
              _getCurrentLocation();
            },
            child: Text('Get Current Location'),
          ),
        ],
      ),
    );
  }
}
