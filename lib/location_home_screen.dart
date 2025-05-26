import 'package:flutter/material.dart';
import 'package:location/location.dart';

class LocationHomeScreen extends StatefulWidget {
  const LocationHomeScreen({super.key});

  @override
  State<LocationHomeScreen> createState() => _LocationHomeScreenState();
}

class _LocationHomeScreenState extends State<LocationHomeScreen> {
  LocationData? currentLocation;

  Future<void> _getCurrentLocation() async {
    // //TODO: Check if the app has permission to access the location
    // bool isLocationEnable = await _isLocationPermissionEnable();
    // if (isLocationEnable) {
    //   //TODO: Check if the GPS service on/off
    //   bool isGpsServiceEnable = await Location.instance.serviceEnabled();
    //   if (isGpsServiceEnable) {
    //     //TODO: Get current location
    //     Location.instance.changeSettings(accuracy: LocationAccuracy.high);
    //     LocationData locationData = await Location.instance.getLocation();
    //     print(locationData);
    //     currentLocation = locationData;
    //     setState(() {});
    //   } else {
    //     //TODO: if not, then move to gps service settings
    //     Location.instance.requestService();
    //   }
    // } else {
    //   //TODO: If not then request the permission
    //   bool isPermissionGranted = await _requestPermission();
    //   if (isPermissionGranted) {
    //     _getCurrentLocation();
    //   }
    // }

    _onLocationPermissionAndServiceEnable(() async {
      LocationData locationData = await Location.instance.getLocation();
      print(locationData);
      currentLocation = locationData;
      setState(() {});
    });
  }

  Future<void> _listenCurrentLocation() async {
    // //TODO: Check if the app has permission to access the location
    // bool isLocationEnable = await _isLocationPermissionEnable();
    // if (isLocationEnable) {
    //   //TODO: Check if the GPS service on/off
    //   bool isGpsServiceEnable = await Location.instance.serviceEnabled();
    //   if (isGpsServiceEnable) {
    //     //TODO: Get current location
    //     Location.instance.changeSettings( accuracy: LocationAccuracy.high, interval: 1000, distanceFilter: 3);
    //     Location.instance.onLocationChanged.listen((LocationData location){
    //        print(location);
    //      });
    //   } else {
    //     //TODO: if not, then move to gps service settings
    //     Location.instance.requestService();
    //   }
    // } else {
    //   //TODO: If not then request the permission
    //   bool isPermissionGranted = await _requestPermission();
    //   if (isPermissionGranted) {
    //     _listenCurrentLocation();
    //   }
    // }

    _onLocationPermissionAndServiceEnable(() {
      Location.instance.changeSettings(
        accuracy: LocationAccuracy.high,
        interval: 1000,
        distanceFilter: 3,
      );
      Location.instance.onLocationChanged.listen((LocationData location) {
        print(location);
      });
    });
  }

  Future<void> _onLocationPermissionAndServiceEnable(
    VoidCallback onSuccess,
  ) async {
    //TODO: Check if the app has permission to access the location
    bool isLocationEnable = await _isLocationPermissionEnable();
    if (isLocationEnable) {
      //TODO: Check if the GPS service on/off
      bool isGpsServiceEnable = await Location.instance.serviceEnabled();
      if (isGpsServiceEnable) {
        //TODO: What user want
        onSuccess();
      } else {
        //TODO: if not, then move to gps service settings
        Location.instance.requestService();
      }
    } else {
      //TODO: If not then request the permission
      bool isPermissionGranted = await _requestPermission();
      if (isPermissionGranted) {
        _listenCurrentLocation();
      }
    }
  }

  Future<bool> _isLocationPermissionEnable() async {
    PermissionStatus locationPermission =
        await Location.instance.hasPermission();
    if (locationPermission == PermissionStatus.granted ||
        locationPermission == PermissionStatus.grantedLimited) {
      return true;
    } else {
      return false;
    }
  }

  Future<bool> _requestPermission() async {
    PermissionStatus locationPermission =
        await Location.instance.requestPermission();
    if (locationPermission == PermissionStatus.granted ||
        locationPermission == PermissionStatus.grantedLimited) {
      return true;
    } else {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("GPS Service Home")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Current Location ${currentLocation?.latitude},${currentLocation?.longitude}',
            ),
            TextButton(
              onPressed: () {
                _getCurrentLocation();
              },
              child: Text('Get Current Location'),
            ),

            TextButton(
              onPressed: () {
                _listenCurrentLocation();
              },
              child: Text('Listen Current Location'),
            ),
          ],
        ),
      ),
    );
  }
}
