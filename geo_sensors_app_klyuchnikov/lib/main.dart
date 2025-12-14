import 'package:flutter/material.dart';
import 'pages/geo_sensors_page.dart';

void main() {
  runApp(const GeoSensorsApp());
}

class GeoSensorsApp extends StatelessWidget {
  const GeoSensorsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Geo & Sensors',
      theme: ThemeData(useMaterial3: true),
      home: const GeoSensorsPage(),
    );
  }
}
