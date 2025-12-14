import 'dart:math';

import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:sensors_plus/sensors_plus.dart';
import 'package:flutter_compass/flutter_compass.dart';

import '../models/accel_point.dart';
import '../widgets/accel_chart.dart';
import 'user_info_page.dart';

class GeoSensorsPage extends StatefulWidget {
  const GeoSensorsPage({super.key});

  @override
  State<GeoSensorsPage> createState() => _GeoSensorsPageState();
}

class _GeoSensorsPageState extends State<GeoSensorsPage> {
  Position? _position;
  String _address = '–';

  double? _compass;
  List<double>? _accelerometerValues;
  List<double>? _gyroscopeValues;

  final List<AccelPoint> _accelHistory = [];
  double _time = 0;

  static const int maxPoints = 50;
  static const double accelThreshold = 15;
  static const double gyroThreshold = 4;

  Future<void> _getLocation() async {
    if (!await Geolocator.isLocationServiceEnabled()) return;

    final permission = await Geolocator.requestPermission();
    if (permission == LocationPermission.denied) return;

    final pos = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    final placemarks = await placemarkFromCoordinates(
      pos.latitude,
      pos.longitude,
    );

    setState(() {
      _position = pos;
      _address =
          '${placemarks.first.locality ?? ''}, ${placemarks.first.street ?? ''}';
    });
  }

  void _showAlert(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  void _checkAlerts() {
    if (_accelerometerValues != null) {
      final mag = sqrt(
        _accelerometerValues!.map((e) => e * e).reduce((a, b) => a + b),
      );
      if (mag > accelThreshold) {
        _showAlert('⚠ Резкое ускорение!');
      }
    }

    if (_gyroscopeValues != null) {
      final gyroMag = _gyroscopeValues!
          .map((e) => e.abs())
          .reduce((a, b) => a + b);
      if (gyroMag > gyroThreshold) {
        _showAlert('⚠ Резкий поворот!');
      }
    }
  }

  @override
  void initState() {
    super.initState();

    accelerometerEvents.listen((event) {
      setState(() {
        _accelerometerValues = [event.x, event.y, event.z];
        _time += 0.1;
        _accelHistory.add(AccelPoint(_time, event.x));
        if (_accelHistory.length > maxPoints) {
          _accelHistory.removeAt(0);
        }
      });
      _checkAlerts();
    });

    gyroscopeEvents.listen((event) {
      setState(() => _gyroscopeValues = [event.x, event.y, event.z]);
      _checkAlerts();
    });

    FlutterCompass.events?.listen((event) {
      setState(() => _compass = event.heading);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Geo & Sensors Demo'),
        actions: [
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      UserInfoPage(position: _position, compass: _compass),
                ),
              );
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: ListView(
          children: [
            ElevatedButton(
              onPressed: _getLocation,
              child: const Text('Определить местоположение'),
            ),
            const SizedBox(height: 12),
            Text(
              _position != null
                  ? 'Координаты: ${_position!.latitude}, ${_position!.longitude}'
                  : 'Координаты: –',
            ),
            Text('Адрес: $_address'),
            const Divider(height: 30),
            Text('Компас: ${_compass?.toStringAsFixed(1) ?? '–'}°'),
            const Divider(height: 30),
            Text(
              'Акселерометр: ${_accelerometerValues?.map((e) => e.toStringAsFixed(2)).join(', ') ?? '–'}',
            ),
            Text(
              'Гироскоп: ${_gyroscopeValues?.map((e) => e.toStringAsFixed(2)).join(', ') ?? '–'}',
            ),
            const Divider(height: 30),
            const Text('График ускорения'),
            AccelChart(points: _accelHistory),
          ],
        ),
      ),
    );
  }
}
