import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import '../widgets/daily_summary_card.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<DataProvider>(context);
    final rutina = data.rutinaHoy;

    // Detectamos el modo oscuro para ajustar textos
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;
    final subTextColor = isDark ? Colors.grey[400] : Colors.grey[600];

    // Cálculo del porcentaje
    double progress = (data.currentDay / 45).clamp(0.0, 1.0);

    return Scaffold(
      // CORRECCIÓN: Usamos el color del tema, no uno fijo
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
                      color: textColor, // Color dinámico
                    ),
                  ),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "Día ${data.currentDay} del Reto 45",
                        style: const TextStyle(
                          fontSize: 16,
                          color: Color(0xFF8B5CF6),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "${(progress * 100).toStringAsFixed(0)}%",
                        style: TextStyle(
                          color: subTextColor, // Color dinámico
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 8),

                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 12,
                      // Fondo de la barra más oscuro en modo dark
                      backgroundColor: isDark
                          ? Colors.grey[800]
                          : Colors.grey[300],
                      color: const Color(0xFF8B5CF6),
                    ),
                  ),

                  const SizedBox(height: 25),

                  DailySummaryCard(
                    enfoque: rutina?.enfoque ?? "Descanso / Fin del Reto",
                    cantidadEjercicios: rutina?.ejercicios.length ?? 0,
                  ),

                  const SizedBox(height: 25),
                  Text(
                    "Rutina de Hoy",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: textColor,
                    ),
                  ),
                  const SizedBox(height: 15),

                  if (rutina != null)
                    ...rutina.ejercicios.map(
                      (ejercicio) => _buildExerciseItem(
                        context, // Pasamos contexto para temas
                        ejercicio.nombre,
                        ejercicio.descanso,
                        ejercicio.getDetalleParaUsuario(data.grupoEdadUsuario),
                      ),
                    )
                  else
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Text(
                          "¡Felicidades! Has completado el reto.",
                          style: TextStyle(color: textColor),
                        ),
                      ),
                    ),

                  const SizedBox(height: 20),

                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        data.completeDay();
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text(
                              "¡Día completado! Progreso guardado ☁️",
                            ),
                            backgroundColor: Colors.green,
                          ),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        // Botón se adapta ligeramente
                        backgroundColor: isDark
                            ? const Color(0xFF8B5CF6)
                            : Colors.black87,
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

  Widget _buildExerciseItem(
    BuildContext context,
    String name,
    String descanso,
    String detalle,
  ) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Card(
      elevation: 0,
      color: cardColor, // Color de tarjeta dinámico
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isDark ? Colors.transparent : Colors.grey.shade200,
        ),
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
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            color: textColor,
          ),
        ),
        subtitle: Text(
          "Descanso: $descanso",
          style: TextStyle(
            color: isDark ? Colors.grey[400] : Colors.grey[600],
            fontSize: 12,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Text(
            detalle,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 12,
              color: textColor,
            ),
          ),
        ),
      ),
    );
  }
}
