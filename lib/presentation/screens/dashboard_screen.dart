import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text("Resumen Diario"),
        automaticallyImplyLeading: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                _statCard(
                  "Quemadas",
                  "520",
                  "kcal",
                  Colors.orange,
                  Icons.local_fire_department,
                ),
                const SizedBox(width: 10),
                _statCard(
                  "Agua",
                  "1.8 L",
                  "Meta 2.5",
                  Colors.blue,
                  Icons.water_drop,
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              "Actividad Semanal",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            Container(
              height: 200,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
              ),
              child: BarChart(
                BarChartData(
                  gridData: const FlGridData(show: false),
                  titlesData: const FlTitlesData(show: false),
                  borderData: FlBorderData(show: false),
                  barGroups: [
                    _bar(0, 5),
                    _bar(1, 3),
                    _bar(2, 6),
                    _bar(3, 2),
                    _bar(4, 7),
                    _bar(5, 4),
                    _bar(6, 5),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _statCard(
    String title,
    String value,
    String sub,
    Color color,
    IconData icon,
  ) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Icon(icon, color: color, size: 30),
            const SizedBox(height: 10),
            Text(
              value,
              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            Text(sub, style: const TextStyle(color: Colors.grey)),
          ],
        ),
      ),
    );
  }

  BarChartGroupData _bar(int x, double y) {
    return BarChartGroupData(
      x: x,
      barRods: [
        BarChartRodData(
          toY: y,
          color: const Color(0xFF8B5CF6),
          width: 15,
          borderRadius: BorderRadius.circular(4),
        ),
      ],
    );
  }
}
