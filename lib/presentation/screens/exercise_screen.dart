import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/workout_model.dart';
import '../providers/data_provider.dart';

class ExerciseScreen extends StatelessWidget {
  const ExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<DataProvider>(context);
    final rutina = data.rutinaHoy;

    if (data.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final destacados = rutina?.ejercicios.take(2).toList() ?? [];
    final restoEjercicios = rutina?.ejercicios.skip(2).toList() ?? [];

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "Entrenamiento de Hoy",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              if (destacados.isNotEmpty)
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                    crossAxisSpacing: 16,
                    mainAxisSpacing: 16,
                    childAspectRatio: 0.85,
                  ),
                  itemCount: destacados.length,
                  itemBuilder: (context, index) {
                    final ejercicio = destacados[index];
                    return _buildWorkoutCard(
                      ejercicio.nombre,
                      ejercicio.detalle,
                      index,
                    );
                  },
                ),
              const SizedBox(height: 30),
              const Text(
                "Rutina Completa",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              if (restoEjercicios.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: restoEjercicios.length,
                  itemBuilder: (context, index) {
                    return _buildExerciseListItem(
                      restoEjercicios[index],
                      index,
                    );
                  },
                ),
              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildWorkoutCard(String title, String subtitle, int index) {
    final bgColor = index % 2 == 0
        ? const Color(0xFFEADDFF)
        : const Color(0xFFD0BCFF);
    final textColor = index % 2 == 0
        ? const Color(0xFF21005D)
        : const Color(0xFF381E72);
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: TextStyle(fontWeight: FontWeight.bold, color: textColor),
              maxLines: 2,
            ),
            Text(subtitle, style: TextStyle(color: textColor.withOpacity(0.7))),
          ],
        ),
      ),
    );
  }

  Widget _buildExerciseListItem(Ejercicio ejercicio, int index) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        height: 50,
        width: 50,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Icon(Icons.fitness_center, color: Color(0xFF8B5CF6)),
      ),
      title: Text(
        ejercicio.nombre,
        style: TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(ejercicio.detalle),
      trailing: Icon(Icons.play_circle_fill, color: Color(0xFF8B5CF6)),
    );
  }
}
