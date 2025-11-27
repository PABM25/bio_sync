import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../widgets/daily_summary_card.dart';
import '../../data/datasources/health_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});
  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final HealthService _healthService = HealthService();
  int _steps = 0;
  double _calories = 0;

  @override
  void initState() {
    super.initState();
    _syncHealthData();
  }

  Future<void> _syncHealthData() async {
    final steps = await _healthService.getTodaySteps();
    final cals = await _healthService.getTodayCalories();
    if (mounted) {
      setState(() {
        _steps = steps;
        _calories = cals;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<DataProvider>(context);
    final rutina = data.rutinaRetoHoy;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: data.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  Text(
                    "Hola, ${data.userName} 👋",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Container(
                    padding: const EdgeInsets.all(15),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF2C2C2C) : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        _buildHealthItem(
                          Icons.directions_walk,
                          "$_steps",
                          "Pasos",
                          Colors.blue,
                        ),
                        Container(
                          width: 1,
                          height: 40,
                          color: Colors.grey.withValues(alpha: 0.3),
                        ),
                        _buildHealthItem(
                          Icons.local_fire_department,
                          "${_calories.toInt()}",
                          "Kcal Activas",
                          Colors.orange,
                        ),
                        IconButton(
                          icon: const Icon(
                            Icons.sync,
                            color: Color(0xFF8B5CF6),
                          ),
                          onPressed: _syncHealthData,
                          tooltip: "Sincronizar Salud",
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  DailySummaryCard(
                    enfoque: rutina?.enfoque ?? "Descanso",
                    cantidadEjercicios: rutina?.ejercicios.length ?? 0,
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildHealthItem(
    IconData icon,
    String value,
    String label,
    Color color,
  ) {
    return Column(
      children: [
        Icon(icon, color: color, size: 28),
        const SizedBox(height: 4),
        Text(
          value,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
      ],
    );
  }
}
