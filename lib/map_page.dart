import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import 'apis.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final Location _locationController = Location();
  final Completer<GoogleMapController> _mapController = Completer();

  static const LatLng _sourceLocation = LatLng(23.936893150188673, 90.29883247535163);
  static const LatLng _destinationLocation = LatLng(23.917671803229684, 90.31342369167808);
  LatLng? _currentPosition;

  final Map<PolylineId, Polyline> _polylines = {};

  @override
  void initState() {
    super.initState();
    _initLocationAndPolyline();
  }

  Future<void> _initLocationAndPolyline() async {
    await _getLocationUpdates();
    final points = await _getPolylinePoints();
    _generatePolylineFromPoints(points);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Real-Time Location Tracker'),
      ),
      body: _currentPosition == null
          ? const Center(child: Text('Loading...'))
          : GoogleMap(
        onMapCreated: (controller) => _mapController.complete(controller),
        initialCameraPosition: const CameraPosition(
          target: _sourceLocation,
          zoom: 13,
        ),
        markers: _buildMarkers(),
        polylines: Set<Polyline>.of(_polylines.values),
      ),
    );
  }

  Set<Marker> _buildMarkers() {
    return {
      Marker(
        markerId: const MarkerId("_currentLocation"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        position: _currentPosition!,
        infoWindow: InfoWindow(
          title: "My Current Location",
          snippet: "Lat: ${_currentPosition!.latitude.toStringAsFixed(5)}, "
              "Lng: ${_currentPosition!.longitude.toStringAsFixed(5)}",
        ),
      ),
      Marker(
        markerId: const MarkerId("_sourceLocation"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
        position: _sourceLocation,
        draggable: true,
        onDragEnd: (LatLng endLatLng) {
          print("Source dragged to $endLatLng");
        },
        infoWindow: InfoWindow(
          title: "Destination Location",
          snippet: "Lat: ${_sourceLocation.latitude.toStringAsFixed(5)}, "
              "Lng: ${_sourceLocation.longitude.toStringAsFixed(5)}",
        ),
      ),
      Marker(
        markerId: const MarkerId("_destinationLocation"),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        position: _destinationLocation,
        infoWindow: InfoWindow(
          title: "Source Location",
          snippet: "Lat: ${_destinationLocation.latitude.toStringAsFixed(5)}, "
              "Lng: ${_destinationLocation.longitude.toStringAsFixed(5)}",
        ),
      ),
    };
  }

  Future<void> _moveCameraToPosition(LatLng pos) async {
    final controller = await _mapController.future;
    final cameraPosition = CameraPosition(target: pos, zoom: 13);
    await controller.animateCamera(CameraUpdate.newCameraPosition(cameraPosition));
  }

  Future<void> _getLocationUpdates() async {
    bool serviceEnabled = await _locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await _locationController.requestService();
      if (!serviceEnabled) return;
    }

    PermissionStatus permissionGranted = await _locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await _locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) return;
    }

    _locationController.onLocationChanged.listen((LocationData currentLocation) {
      if (currentLocation.latitude != null && currentLocation.longitude != null) {
        final position = LatLng(currentLocation.latitude!, currentLocation.longitude!);
        if (mounted) {
          setState(() => _currentPosition = position);
          _moveCameraToPosition(position);
        }
      }
    });
  }

  Future<List<LatLng>> _getPolylinePoints() async {
    List<LatLng> polylineCoordinates = [];
    final polylinePoints = PolylinePoints();

    final result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: GOOGLE_MAPS_API_KEY,
      request: PolylineRequest(
        origin: PointLatLng(_sourceLocation.latitude, _sourceLocation.longitude),
        destination: PointLatLng(_destinationLocation.latitude, _destinationLocation.longitude),
        mode: TravelMode.driving,
      ),
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    } else {
      debugPrint('Error fetching polyline: ${result.errorMessage}');
    }

    return polylineCoordinates;
  }

  void _generatePolylineFromPoints(List<LatLng> coordinates) {
    const polylineId = PolylineId("route");
    final polyline = Polyline(
      width: 10,
      color: Colors.blue,
      visible: true,
      endCap: Cap.roundCap,
      startCap: Cap.roundCap,
      polylineId: polylineId,
      points: coordinates,
    );
    setState(() {
      _polylines[polylineId] = polyline;
    });
  }
}
