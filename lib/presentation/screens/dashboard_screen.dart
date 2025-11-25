import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart'; // Importamos el cerebro de datos

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // 1. Obtenemos los datos del Provider
    final data = Provider.of<DataProvider>(context);
    final rutina = data.rutinaHoy; // La rutina específica del día actual

    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      body: data.isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            ) // Si está cargando, muestra círculo
          : SingleChildScrollView(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 40),

                  // 2. Saludo Personalizado con el nombre real
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

                  // 3. Tarjeta Principal: Muestra el enfoque de hoy (ej: "Cardio y Pierna")
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
                          "Hoy te toca:",
                          style: TextStyle(color: Colors.white70, fontSize: 14),
                        ),
                        const SizedBox(height: 5),
                        // Aquí mostramos el "enfoque" del JSON
                        Text(
                          rutina?.enfoque ?? "Descanso / Fin del Reto",
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
                    "Rutina de Hoy",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 15),

                  // 4. Lista Dinámica: Genera una tarjeta por cada ejercicio en el JSON
                  if (rutina != null)
                    ...rutina.ejercicios.map(
                      (ejercicio) => _buildExerciseItem(
                        ejercicio.nombre,
                        ejercicio.descanso,
                        ejercicio.detalle, // "20 reps" o "1 min"
                      ),
                    )
                  else
                    const Center(
                      child: Text("¡Felicidades! Has completado el reto."),
                    ),

                  const SizedBox(height: 30),

                  // 5. Botón para avanzar al siguiente día
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        // Llama a la lógica para sumar un día
                        data.completeDay();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "¡Día completado! Mañana más fuerte 💪",
                            ),
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.black87,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      child: const Text("¡Completar Día!"),
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
    );
  }

  // Widget auxiliar para dibujar cada fila de ejercicio
  Widget _buildExerciseItem(String name, String descanso, String detalle) {
    return Card(
      elevation: 0,
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(color: Colors.grey.shade200),
      ),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: const Color(0xFF8B5CF6).withOpacity(0.1),
          child: const Icon(
            Icons.fitness_center,
            color: Color(0xFF8B5CF6),
            size: 20,
          ),
        ),
        title: Text(
          name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        subtitle: Text(
          "Descanso: $descanso",
          style: TextStyle(color: Colors.grey[600], fontSize: 12),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            detalle,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          ),
        ),
      ),
    );
  }
}
