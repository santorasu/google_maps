import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps/src/feature/screen/home_screen/riverpod/map_providers.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';



class GoogleMapPage extends ConsumerStatefulWidget {
  const GoogleMapPage({super.key});

  @override
  ConsumerState<GoogleMapPage> createState() => _GoogleMapPageState();
}

class _GoogleMapPageState extends ConsumerState<GoogleMapPage> {
  // hold the subscription created by listenManual
  late ProviderSubscription<AsyncValue<LatLng?>> _sub;

  @override
  void initState() {
    super.initState();

    // listen outside build using listenManual
    _sub = ref.listenManual<AsyncValue<LatLng?>>(
      currentPositionStreamProvider,
          (prev, next) async {
        final controller = ref.read(mapControllerProvider);
        final pos = next.valueOrNull;
        if (controller != null && pos != null) {
          await controller.animateCamera(
            CameraUpdate.newCameraPosition(
              CameraPosition(target: pos, zoom: 13),
            ),
          );
        }
      },
      // trigger once with the current value if available
      fireImmediately: true,
    );
  }

  @override
  void dispose() {
    _sub.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ready = ref.watch(locationReadyProvider);
    final markers = ref.watch(markersProvider);
    final routePolyline = ref.watch(routePolylineProvider);
    final initialCamera = ref.watch(initialCameraProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Real-Time Location Tracker')),
      body: ready.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, st) => Center(
          child: Text('Location not available: $err'),
        ),
        data: (ok) {
          if (!ok) {
            return const Center(
              child: Text('Enable location services to continue.'),
            );
          }

          final polylines = <Polyline>{};
          routePolyline.when(
            data: (poly) => polylines.add(poly),
            loading: () {}, // keep layout stable
            error: (_, __) {}, // ignore silently or show a snackbar
          );

          return GoogleMap(
            initialCameraPosition: initialCamera,
            markers: markers,
            polylines: polylines,
            myLocationEnabled: true,
            myLocationButtonEnabled: true,
            onMapCreated: (controller) {
              ref.read(mapControllerProvider.notifier).state = controller;
            },
          );
        },
      ),
    );
  }
}
