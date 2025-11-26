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
  final String descanso; // ej: "30" (solo números preferiblemente)
  final String? nota;
  final String? imageUrl; // NUEVO: URL de GIF o imagen
  final bool esPorTiempo; // NUEVO: Para saber si usar cronómetro
  final int duracionSegundos; // NUEVO

  // Mapas por edad (los mantenemos)
  final Map<String, dynamic>? repeticionesPorEdad;
  final Map<String, dynamic>? duracionPorEdad;

  Ejercicio({
    required this.nombre,
    required this.descanso,
    this.nota,
    this.imageUrl,
    this.esPorTiempo = false,
    this.duracionSegundos = 0,
    this.repeticionesPorEdad,
    this.duracionPorEdad,
  });

  factory Ejercicio.fromJson(Map<String, dynamic> json) {
    // Lógica simple para detectar si es por tiempo
    bool porTiempo = json.containsKey('duracion') || json['tipo'] == 'tiempo';

    return Ejercicio(
      nombre: json['nombre'] ?? "Ejercicio",
      descanso:
          json['descanso']?.toString().replaceAll(RegExp(r'[^0-9]'), '') ??
          "30",
      nota: json['nota'],
      imageUrl:
          json['gif_url'], // Asegúrate de agregar esto a tu JSON o usar placeholders
      esPorTiempo: porTiempo,
      duracionSegundos: 60, // Valor por defecto o parsear del JSON
      repeticionesPorEdad: json['repeticiones'] is Map
          ? json['repeticiones']
          : null,
      duracionPorEdad: json['duracion'] is Map ? json['duracion'] : null,
    );
  }

  String getDetalleParaUsuario(String grupoEdad) {
    if (esPorTiempo) {
      var val = duracionPorEdad?[grupoEdad] ?? "60s";
      return val.toString();
    }
    var val = repeticionesPorEdad?[grupoEdad] ?? "12";
    return "$val reps";
  }
}
