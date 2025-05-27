import 'package:flutter/material.dart';
import 'package:google_maps/gps_home_screen.dart';

import 'home_screen.dart';
import 'location_home_screen.dart';
import 'map_page.dart';

void main() {
  runApp(const GoogleMapsApp());
}

class GoogleMapsApp extends StatelessWidget {
  const GoogleMapsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: MapPage(),
    );
  }
}
