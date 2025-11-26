import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
import 'challenge_screen.dart'; // Reutilizamos el widget ExerciseCheckboxItem

class ExerciseScreen extends StatelessWidget {
  const ExerciseScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<DataProvider>(context);
    final rutinaPersonal = data.rutinaPersonalizada; // <--- Getter NUEVO
    final grupoEdad = data.grupoEdadUsuario;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              const Text(
                "TU PLAN PERSONAL",
                style: TextStyle(
                  fontSize: 14,
                  color: Color(0xFF8B5CF6),
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                data.userGoal.toUpperCase(),
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),

              const SizedBox(height: 20),

              // Tarjeta de Resumen Personal
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF8B5CF6).withOpacity(0.3),
                  ),
                ),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: const Color(0xFF8B5CF6).withOpacity(0.1),
                      child: const Icon(Icons.person, color: Color(0xFF8B5CF6)),
                    ),
                    const SizedBox(width: 15),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Nivel: ${data.userLevel}",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: textColor,
                          ),
                        ),
                        Text(
                          "Objetivo: ${data.userGoal}",
                          style: const TextStyle(
                            color: Colors.grey,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              Text(
                "Rutina Sugerida de Hoy",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),

              // Lista de Ejercicios Personalizados
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: rutinaPersonal.ejercicios.length,
                itemBuilder: (context, index) {
                  final ex = rutinaPersonal.ejercicios[index];
                  return ExerciseCheckboxItem(
                    nombre: ex.nombre,
                    detalle: ex.getDetalleParaUsuario(grupoEdad),
                    descanso: ex.descanso,
                  );
                },
              ),

              const SizedBox(height: 20),
              Center(
                child: Text(
                  "Esta rutina está adaptada a tu objetivo de ${data.userGoal}.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: Colors.grey[600],
                    fontSize: 12,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
