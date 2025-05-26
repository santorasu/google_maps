
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late final GoogleMapController _mapController;

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
      appBar: AppBar(title: const Text("Real Time Location Tracker")),
      body: GoogleMap(
        mapType: MapType.terrain,
        initialCameraPosition: const CameraPosition(
          zoom: 17,
          target: LatLng(23.880815840607823, 90.32470045429187),
        ),
        zoomControlsEnabled: true,
        compassEnabled: true,
        myLocationEnabled: true,
        myLocationButtonEnabled: true,
        onMapCreated: (GoogleMapController controller) {
          _mapController = controller;
        },
        onTap: (LatLng latLng) {
          print(latLng);
        },
        onLongPress: (LatLng latLng) {
          print("Long presses at $latLng");
        },
        markers: {
          Marker(
            markerId: MarkerId("my-location"),
            position: const LatLng(23.880815840607823, 90.32470045429187),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueGreen,
            ),
            onTap: () {
              print("Marker tapped");
            },
            visible: true,
            infoWindow: InfoWindow(
              title: "My Location",
              snippet: "This is my location",
              onTap: () {
                print("Info window tapped");
              },
            ),
          ),
          Marker(
            markerId: MarkerId("your-location"),
            position: const LatLng(23.881333012776306, 90.3256718069315),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueYellow,
            ),
            onTap: () {
              print("Marker tapped");
            },
            visible: true,
            infoWindow: InfoWindow(
              title: "My Location",
              snippet: "This is my location",
              onTap: () {
                print("Info window tapped");
              },
            ),
          ),
          Marker(
            markerId: MarkerId("drag-location"),
            position: const LatLng(23.881768957089953, 90.32454125583172),
            icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueYellow,
            ),
            onTap: () {
              print("Marker tapped");
            },
            visible: true,
            draggable: true,
            onDrag: (LatLng latLng) {},
            onDragStart: (LatLng startedLatLng) {},
            onDragEnd: (LatLng endLatLng) {
              print("Drag ended at $endLatLng");
            },
            infoWindow: InfoWindow(
              title: "My Location",
              snippet: "This is my location",
              onTap: () {
                print("Info window tapped");
              },
            ),
          ),
        },
        polylines: {
          Polyline(
            polylineId: PolylineId("StraightLine"),
            width: 10,
            color: Colors.blue,
            endCap: Cap.roundCap,
            startCap: Cap.roundCap,
            points: [
              const LatLng(23.88351363935813, 90.3247045353055),
              const LatLng(23.88357709862825, 90.3232229501009),
              const LatLng(23.884978406270267, 90.32297015190125),
            ],
            jointType: JointType.round,
          ),
        },
        circles: {
          Circle(
            circleId: CircleId("Virus"),
            center: const LatLng(23.876370747077576, 90.32083243131638),
            radius: 200,
            strokeWidth: 3,
            strokeColor: Colors.red,
            fillColor: Colors.red.withOpacity(0.2),
          ),
        },
        polygons: {
          Polygon(
            polygonId: PolygonId('random polygon'),
            fillColor: Colors.blue.withOpacity(0.2),
            strokeWidth: 4,
            strokeColor: Colors.blue,
            points: [
              LatLng(23.876950188630012, 90.32042741775513),
              LatLng(23.87693547268618, 90.32128170132637),
              LatLng(23.875829012867303, 90.32123275101185),
              LatLng(23.87585905817433, 90.32031308859587),
            ],
          ),
        },
      ),
      floatingActionButton: FloatingActionButton(
        child: Icon(Icons.train),
        onPressed: () {
          // _mapController.moveCamera(
          //   CameraUpdate.newCameraPosition(
          //     CameraPosition(
          //       target: LatLng(23.87500828275231, 90.32535698264837),
          //     ),
          //   ),
          // );

          _mapController.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(
                zoom: 17,
                target: LatLng(23.87500828275231, 90.32535698264837),
              ),
            ),
          );
        },
      ),
    );
  }

  @override
  void dispose() {
    _mapController.dispose();
    super.dispose();
  }
}