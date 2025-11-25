import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

class WeightChart extends StatelessWidget {
  final List<double> weightHistory; // Ej: [75.0, 74.5, 74.0, ...]

  const WeightChart({super.key, required this.weightHistory});

  @override
  Widget build(BuildContext context) {
    if (weightHistory.isEmpty) return const SizedBox.shrink();

    // Cálculos para ajustar el gráfico automáticamente
    double minWeight = weightHistory.reduce((a, b) => a < b ? a : b) - 2;
    double maxWeight = weightHistory.reduce((a, b) => a > b ? a : b) + 2;

    return AspectRatio(
      aspectRatio: 1.70,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(18)),
          gradient: LinearGradient(
            colors: [
              const Color(0xFF8B5CF6).withOpacity(0.2),
              const Color(0xFF8B5CF6).withOpacity(0.0),
            ],
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.only(
            right: 18,
            left: 12,
            top: 24,
            bottom: 12,
          ),
          child: LineChart(
            LineChartData(
              gridData: FlGridData(
                show: true,
                drawVerticalLine: false,
                getDrawingHorizontalLine: (value) {
                  return const FlLine(color: Colors.white12, strokeWidth: 1);
                },
              ),
              titlesData: FlTitlesData(
                show: true,
                rightTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                topTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                bottomTitles: const AxisTitles(
                  sideTitles: SideTitles(showTitles: false),
                ),
                leftTitles: AxisTitles(
                  sideTitles: SideTitles(
                    showTitles: true,
                    interval: 1, // Mostrar cada 1kg
                    getTitlesWidget: (value, meta) {
                      // Solo mostrar etiquetas enteras para limpieza
                      if (value % 2 == 0) {
                        return Text(
                          value.toInt().toString(),
                          style: const TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.bold,
                            fontSize: 10,
                          ),
                        );
                      }
                      return Container();
                    },
                    reservedSize: 30,
                  ),
                ),
              ),
              borderData: FlBorderData(show: false),
              minX: 0,
              maxX: (weightHistory.length - 1).toDouble(),
              minY: minWeight,
              maxY: maxWeight,
              lineBarsData: [
                LineChartBarData(
                  spots: weightHistory.asMap().entries.map((e) {
                    return FlSpot(e.key.toDouble(), e.value);
                  }).toList(),
                  isCurved: true,
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFFC4B5FD)],
                  ),
                  barWidth: 4,
                  isStrokeCapRound: true,
                  dotData: const FlDotData(show: true),
                  belowBarData: BarAreaData(
                    show: true,
                    gradient: LinearGradient(
                      colors: [
                        const Color(0xFF8B5CF6).withOpacity(0.3),
                        const Color(0xFF8B5CF6).withOpacity(0.0),
                      ],
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
