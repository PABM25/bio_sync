import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // Consumimos los datos reales
    final data = Provider.of<DataProvider>(context);
    final rutina = data.rutinaHoy;

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: data.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),
                  // Saludo Personalizado
                  Text(
                    "Hola, ${data.userName} 👋",
                    style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    "Día ${data.currentDay} del Reto 45",
                    style: const TextStyle(
                      fontSize: 16,
                      color: Color(0xFF8B5CF6),
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Tarjeta Principal de Hoy
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                      ),
                      borderRadius: BorderRadius.circular(20),
                      boxShadow: [
                        BoxShadow(
                          color: const Color(0xFF8B5CF6).withOpacity(0.3),
                          blurRadius: 10,
                          offset: const Offset(0, 5),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          "Entrenamiento de Hoy",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          rutina?.enfoque ?? "Descanso",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Row(
                          children: [
                            const Icon(
                              Icons.timer,
                              color: Colors.white,
                              size: 18,
                            ),
                            const SizedBox(width: 5),
                            Text(
                              "${rutina?.ejercicios.length ?? 0} Ejercicios",
                              style: const TextStyle(color: Colors.white),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),
                  const Text(
                    "Rutina Detallada",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),

                  // LISTA DINÁMICA DE EJERCICIOS (Desde JSON)
                  if (rutina != null)
                    ...rutina.ejercicios.map(
                      (ejercicio) => _buildExerciseItem(
                        ejercicio.nombre,
                        ejercicio.descanso,
                        ejercicio.detalle,
                        false, // Aquí podrías conectar un estado de completado
                      ),
                    ),

                  const SizedBox(height: 30),
                  // Botón para completar día
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => data.completeDay(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text("¡Completar Día!"),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildExerciseItem(
    String name,
    String descanso,
    String detalle,
    bool completed,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFF8B5CF6).withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.fitness_center, color: Color(0xFF8B5CF6)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      detalle,
                      style: const TextStyle(
                        color: Colors.black87,
                        fontWeight: FontWeight.w500,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Icon(Icons.access_time, size: 12, color: Colors.grey[400]),
                    Text(
                      " Descanso: $descanso",
                      style: TextStyle(color: Colors.grey[400], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Checkbox(
            value: completed,
            onChanged: (v) {},
            activeColor: const Color(0xFF8B5CF6),
          ),
        ],
      ),
    );
  }
}
