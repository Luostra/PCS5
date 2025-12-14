import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/accel_point.dart';

class AccelChart extends StatelessWidget {
  final List<AccelPoint> points;

  const AccelChart({super.key, required this.points});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: LineChart(
        LineChartData(
          minY: -20,
          maxY: 20,
          titlesData: FlTitlesData(show: false),
          gridData: FlGridData(show: true),
          borderData: FlBorderData(show: true),
          lineBarsData: [
            LineChartBarData(
              spots: points.map((e) => FlSpot(e.time, e.value)).toList(),
              isCurved: true,
              barWidth: 3,
              dotData: FlDotData(show: false),
            ),
          ],
        ),
      ),
    );
  }
}
