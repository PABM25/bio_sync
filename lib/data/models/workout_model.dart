class RutinaDia {
  final int dia;
  final String enfoque;
  final List<Ejercicio> ejercicios;

  RutinaDia({
    required this.dia,
    required this.enfoque,
    required this.ejercicios,
  });

  factory RutinaDia.fromJson(Map<String, dynamic> json) {
    var list = json['ejercicios'] as List;
    List<Ejercicio> ejerciciosList = list
        .map((i) => Ejercicio.fromJson(i))
        .toList();

    return RutinaDia(
      dia: json['dia'],
      enfoque: json['enfoque'],
      ejercicios: ejerciciosList,
    );
  }
}

class Ejercicio {
  final String nombre;
  final String descanso;
  final String? nota;

  // Nuevas variables para manejar lógica por edad
  final Map<String, dynamic>? repeticionesPorEdad;
  final Map<String, dynamic>? duracionPorEdad;

  Ejercicio({
    required this.nombre,
    required this.descanso,
    this.nota,
    this.repeticionesPorEdad,
    this.duracionPorEdad,
  });

  factory Ejercicio.fromJson(Map<String, dynamic> json) {
    return Ejercicio(
      nombre: json['nombre'] ?? "Ejercicio",
      descanso: json['descanso'] ?? "30 seg",
      nota: json['nota'],
      // Guardamos los mapas completos en lugar de un string fijo
      repeticionesPorEdad: json['repeticiones'] is Map
          ? json['repeticiones']
          : null,
      duracionPorEdad: json['duracion'] is Map ? json['duracion'] : null,
    );
  }

  // Este es el método que reemplaza a ".detalle"
  String getDetalleParaUsuario(String grupoEdad) {
    // grupoEdad viene del DataProvider (ej: "20s", "30s", "40s_mas")

    // 1. Prioridad: Duración (tiempo)
    if (duracionPorEdad != null) {
      var val = duracionPorEdad![grupoEdad] ?? duracionPorEdad!.values.first;
      return val.toString();
    }

    // 2. Prioridad: Repeticiones
    if (repeticionesPorEdad != null) {
      var val =
          repeticionesPorEdad![grupoEdad] ?? repeticionesPorEdad!.values.first;
      return "$val reps";
    }

    return "Libre";
  }
}
