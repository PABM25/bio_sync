import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class MacroChart extends StatelessWidget {
  final double carbs, protein, fat;
  const MacroChart({
    super.key,
    required this.carbs,
    required this.protein,
    required this.fat,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.center,
      children: [
        PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 40,
            sections: [
              PieChartSectionData(
                color: Colors.greenAccent,
                value: carbs,
                radius: 15,
                showTitle: false,
              ),
              PieChartSectionData(
                color: Colors.blueAccent,
                value: protein,
                radius: 15,
                showTitle: false,
              ),
              PieChartSectionData(
                color: Colors.orangeAccent,
                value: fat,
                radius: 15,
                showTitle: false,
              ),
            ],
          ),
        ),
        const Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              "MACROS",
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 10),
            ),
          ],
        ),
      ],
    );
  }
}
