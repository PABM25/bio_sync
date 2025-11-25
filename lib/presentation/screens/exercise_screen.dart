import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/workout_model.dart'; // Importamos el modelo Ejercicio
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

    // Obtenemos las listas de objetos 'Ejercicio'
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
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Buenos días,",
                        style: TextStyle(color: Colors.grey[600]),
                      ),
                      const Text(
                        "Atleta BioSync",
                        style: TextStyle(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 24,
                    backgroundColor: Color(0xFF8B5CF6),
                    child: Icon(Icons.person, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(height: 24),

              // Search Bar
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.search, color: Colors.grey),
                    hintText: 'Buscar entrenamiento...',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Destacados (Grid)
              const Text(
                "Destacados de Hoy",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

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
                    // CORRECCIÓN: Usamos las propiedades del objeto en lugar de split()
                    return _buildWorkoutCard(
                      ejercicio.nombre,
                      ejercicio.detalle, // Ej: "20 reps" o "30 seg"
                      index,
                    );
                  },
                )
              else
                const Text("No hay rutina destacada para hoy."),

              const SizedBox(height: 30),

              // Lista Vertical
              const Text(
                "Tu Plan Completo",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),

              if (restoEjercicios.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: restoEjercicios.length,
                  itemBuilder: (context, index) {
                    // CORRECCIÓN: Pasamos el objeto Ejercicio completo
                    return _buildExerciseListItem(
                      restoEjercicios[index],
                      index,
                    );
                  },
                )
              else
                const Text(
                  "No hay más ejercicios hoy.",
                  style: TextStyle(color: Colors.grey),
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
      child: Stack(
        children: [
          Positioned(
            right: -20,
            bottom: -20,
            child: Icon(
              Icons.fitness_center,
              size: 100,
              color: Colors.white.withOpacity(0.3),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: textColor,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                Row(
                  children: [
                    Icon(
                      Icons.timer_outlined,
                      size: 16,
                      color: textColor.withOpacity(0.7),
                    ),
                    const SizedBox(width: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        color: textColor.withOpacity(0.7),
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // CORRECCIÓN: Ahora recibe un objeto 'Ejercicio' en lugar de 'String'
  Widget _buildExerciseListItem(Ejercicio ejercicio, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            height: 60,
            width: 60,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(
              Icons.sports_gymnastics,
              color: const Color(0xFF8B5CF6).withOpacity(0.5),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  ejercicio.nombre,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                Text(
                  "Descanso: ${ejercicio.descanso} • ${ejercicio.detalle}",
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: Colors.grey.shade300),
            ),
            child: const Icon(
              Icons.play_arrow_rounded,
              color: Color(0xFF8B5CF6),
            ),
          ),
        ],
      ),
    );
  }
}
