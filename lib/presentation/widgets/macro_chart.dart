import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MacroChart extends StatelessWidget {
  final double carbs;
  final double protein;
  final double fat;

  const MacroChart({
    super.key,
    required this.carbs,
    required this.protein,
    required this.fat,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 200,
      child: Stack(
        children: [
          PieChart(
            PieChartData(
              sectionsSpace: 2,
              centerSpaceRadius: 60,
              sections: [
                PieChartSectionData(
                  color: Colors.greenAccent,
                  value: carbs,
                  title: '${carbs.toInt()}%',
                  radius: 25,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
                PieChartSectionData(
                  color: Colors.blueAccent,
                  value: protein,
                  title: '${protein.toInt()}%',
                  radius: 25,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                PieChartSectionData(
                  color: Colors.orangeAccent,
                  value: fat,
                  title: '${fat.toInt()}%',
                  radius: 25,
                  titleStyle: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ],
            ),
          ),
          const Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  "MACROS",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.grey,
                  ),
                ),
                Text(
                  "Diarios",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
