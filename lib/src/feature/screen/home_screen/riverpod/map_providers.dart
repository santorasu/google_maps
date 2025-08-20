import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';

import '../../../../../apis.dart';

// --- constants (keep here or move to a config file) ---
const LatLng kSourceLocation = LatLng(23.936893150188673, 90.29883247535163);
const LatLng kDestinationLocation = LatLng(23.917671803229684, 90.31342369167808);

// --- raw Location instance ---
final locationProvider = Provider<Location>((ref) => Location());

// --- request service + permission upfront (await this in UI if you want) ---
final locationReadyProvider = FutureProvider<bool>((ref) async {
  final location = ref.read(locationProvider);

  bool serviceEnabled = await location.serviceEnabled();
  if (!serviceEnabled) {
    serviceEnabled = await location.requestService();
    if (!serviceEnabled) return false;
  }

  PermissionStatus permissionGranted = await location.hasPermission();
  if (permissionGranted == PermissionStatus.denied) {
    permissionGranted = await location.requestPermission();
    if (permissionGranted != PermissionStatus.granted) return false;
  }

  return true;
});

// --- live location as a stream ---
final currentPositionStreamProvider = StreamProvider<LatLng?>((ref) async* {
  final location = ref.read(locationProvider);

  // small helper to convert LocationData -> LatLng?
  LatLng? toLatLng(LocationData d) {
    final lat = d.latitude;
    final lng = d.longitude;
    if (lat == null || lng == null) return null;
    return LatLng(lat, lng);
  }

  // emit initial position (if available)
  final initial = await location.getLocation();
  yield toLatLng(initial);

  // then stream updates
  yield* location.onLocationChanged.map(toLatLng);
});

// --- GoogleMapController holder ---
final mapControllerProvider = StateProvider<GoogleMapController?>((ref) => null);

// --- polyline points repository (wrap the plugin call) ---
class PolylineRepo {
  final PolylinePoints _poly = PolylinePoints();

  Future<List<LatLng>> getRoute({
    required LatLng origin,
    required LatLng destination,
    TravelMode mode = TravelMode.driving,
  }) async {
    final res = await _poly.getRouteBetweenCoordinates(
      googleApiKey: GOOGLE_MAPS_API_KEY,
      request: PolylineRequest(
        origin: PointLatLng(origin.latitude, origin.longitude),
        destination: PointLatLng(destination.latitude, destination.longitude),
        mode: mode,
      ),
    );

    if (res.points.isEmpty) {
      debugPrint('Error fetching polyline: ${res.errorMessage}');
      return <LatLng>[];
    }
    return res.points.map((p) => LatLng(p.latitude, p.longitude)).toList();
  }
}

final polylineRepoProvider = Provider<PolylineRepo>((ref) => PolylineRepo());

// --- route polyline (Future) ---
final routePolylineProvider = FutureProvider<Polyline>((ref) async {
  final repo = ref.read(polylineRepoProvider);
  final coords = await repo.getRoute(
    origin: kSourceLocation,
    destination: kDestinationLocation,
    mode: TravelMode.driving,
  );

  return Polyline(
    polylineId: const PolylineId('route'),
    points: coords,
    width: 10,
    color: Colors.blue, // you can theme this later
    visible: true,
    startCap: Cap.roundCap,
    endCap: Cap.roundCap,
  );
});

// --- markers derived provider ---
final markersProvider = Provider<Set<Marker>>((ref) {
  final current = ref.watch(currentPositionStreamProvider).valueOrNull;

  final markers = <Marker>{
    Marker(
      markerId: const MarkerId('_sourceLocation'),
      position: kSourceLocation,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      infoWindow: InfoWindow(
        title: 'Destination Location',
        snippet: 'Lat: ${kSourceLocation.latitude.toStringAsFixed(5)}, '
            'Lng: ${kSourceLocation.longitude.toStringAsFixed(5)}',
      ),
    ),
    Marker(
      markerId: const MarkerId('_destinationLocation'),
      position: kDestinationLocation,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      infoWindow: InfoWindow(
        title: 'Source Location',
        snippet: 'Lat: ${kDestinationLocation.latitude.toStringAsFixed(5)}, '
            'Lng: ${kDestinationLocation.longitude.toStringAsFixed(5)}',
      ),
    ),
  };

  if (current != null) {
    markers.add(
      Marker(
        markerId: const MarkerId('_currentLocation'),
        position: current,
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
        infoWindow: InfoWindow(
          title: 'My Current Location',
          snippet:
          'Lat: ${current.latitude.toStringAsFixed(5)}, Lng: ${current.longitude.toStringAsFixed(5)}',
        ),
      ),
    );
  }

  return markers;
});

// --- initial camera position ---
final initialCameraProvider = Provider<CameraPosition>((ref) {
  return const CameraPosition(target: kSourceLocation, zoom: 13);
});
