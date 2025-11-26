import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';
// Reutilizamos el widget checkbox que ya tenías, o lo definimos aquí si prefieres.
// Asumiré que lo copias o lo importas. Para simplicidad, lo incluyo abajo.

class ChallengeScreen extends StatelessWidget {
  const ChallengeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<DataProvider>(context);
    final rutina = data.rutinaRetoHoy; // Usamos el getter del RETO
    final grupoEdad = data.grupoEdadUsuario;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    if (data.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "RETO 45 DÍAS",
                        style: TextStyle(
                          fontSize: 14,
                          color: Color(0xFF8B5CF6),
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        "Día ${data.currentDay}",
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: textColor,
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.refresh, color: Colors.grey),
                    onPressed: () {
                      data.resetProgress();
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("Progreso reiniciado")),
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 20),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF8B5CF6), Color(0xFF7C3AED)],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF8B5CF6).withOpacity(0.4),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Enfoque de hoy:",
                      style: TextStyle(color: Colors.white70, fontSize: 14),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      rutina?.enfoque ?? "Descanso",
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),
              Text(
                "Rutina del Reto",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: textColor,
                ),
              ),
              const SizedBox(height: 16),

              if (rutina != null && rutina.ejercicios.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: rutina.ejercicios.length,
                  itemBuilder: (context, index) {
                    final ex = rutina.ejercicios[index];
                    return ExerciseCheckboxItem(
                      nombre: ex.nombre,
                      detalle: ex.getDetalleParaUsuario(grupoEdad),
                      descanso: ex.descanso,
                    );
                  },
                )
              else
                Center(
                  child: Text(
                    "No hay ejercicios hoy",
                    style: TextStyle(color: textColor),
                  ),
                ),

              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: () {
                    data.completeDay();
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("¡Día del reto completado! 💪"),
                        backgroundColor: Colors.green,
                      ),
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? const Color(0xFF8B5CF6)
                        : Colors.black87,
                    foregroundColor: Colors.white,
                    elevation: 4,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "¡Completar Día!",
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
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

// Widget Checkbox (igual que antes)
class ExerciseCheckboxItem extends StatefulWidget {
  final String nombre;
  final String detalle;
  final String descanso;
  const ExerciseCheckboxItem({
    super.key,
    required this.nombre,
    required this.detalle,
    required this.descanso,
  });
  @override
  State<ExerciseCheckboxItem> createState() => _ExerciseCheckboxItemState();
}

class _ExerciseCheckboxItemState extends State<ExerciseCheckboxItem> {
  bool _isDone = false;
  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: _isDone ? Colors.green.withOpacity(0.1) : cardColor,
        borderRadius: BorderRadius.circular(16),
        border: _isDone
            ? Border.all(color: Colors.green.withOpacity(0.5))
            : null,
        boxShadow: [
          if (!isDark)
            BoxShadow(
              color: Colors.grey.withOpacity(0.05),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
        ],
      ),
      child: ListTile(
        onTap: () => setState(() => _isDone = !_isDone),
        leading: Container(
          height: 40,
          width: 40,
          decoration: BoxDecoration(
            color: _isDone
                ? Colors.green
                : const Color(0xFF8B5CF6).withOpacity(0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            _isDone ? Icons.check : Icons.fitness_center,
            color: _isDone ? Colors.white : const Color(0xFF8B5CF6),
            size: 20,
          ),
        ),
        title: Text(
          widget.nombre,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 15,
            decoration: _isDone ? TextDecoration.lineThrough : null,
            color: _isDone ? Colors.grey : textColor,
          ),
        ),
        subtitle: Text(
          "Descanso: ${widget.descanso}",
          style: TextStyle(color: Colors.grey, fontSize: 12),
        ),
        trailing: Text(
          widget.detalle,
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: _isDone ? Colors.green : textColor,
            fontSize: 12,
          ),
        ),
      ),
    );
  }
}
