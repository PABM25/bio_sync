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
  // Guardaremos repeticiones como String para simplificar ("20", "1 min")
  // En una versión avanzada, haríamos lógica por edad.
  final String detalle;

  Ejercicio({
    required this.nombre,
    required this.descanso,
    this.nota,
    required this.detalle,
  });

  factory Ejercicio.fromJson(Map<String, dynamic> json) {
    // Lógica simple: Tomamos el valor '30s' por defecto para mostrar algo en UI rápido
    // Si es por tiempo, tomamos 'duracion', si es reps, tomamos 'repeticiones'
    String det = "";
    if (json.containsKey('duracion')) {
      var d = json['duracion'];
      det = d is Map ? d['30s'] ?? "Tiempo" : "Tiempo";
    } else if (json.containsKey('repeticiones')) {
      var r = json['repeticiones'];
      det = r is Map ? "${r['30s']} reps" : "Reps";
    }

    return Ejercicio(
      nombre: json['nombre'],
      descanso: json['descanso'],
      nota: json['nota'],
      detalle: det,
    );
  }
}
