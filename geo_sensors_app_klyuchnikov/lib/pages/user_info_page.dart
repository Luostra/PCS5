import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';

class UserInfoPage extends StatelessWidget {
  final Position? position;
  final double? compass;

  const UserInfoPage({
    super.key,
    required this.position,
    required this.compass,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('О пользователе')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Скорость: ${position?.speed.toStringAsFixed(2) ?? '–'} м/с'),
            const SizedBox(height: 8),
            Text('Высота: ${position?.altitude.toStringAsFixed(2) ?? '–'} м'),
            const SizedBox(height: 8),
            Text('Направление: ${compass?.toStringAsFixed(1) ?? '–'}°'),
          ],
        ),
      ),
    );
  }
}
