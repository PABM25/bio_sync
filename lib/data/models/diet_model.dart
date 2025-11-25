class PlanDiario {
  final String dia;
  final ComidasDia comidas;

  PlanDiario({required this.dia, required this.comidas});

  factory PlanDiario.fromJson(Map<String, dynamic> json) {
    return PlanDiario(
      dia: json['dia'],
      comidas: ComidasDia.fromJson(json['comidas']),
    );
  }
}

class ComidasDia {
  final String desayuno;
  final String almuerzo;
  final String cena;
  final String colacion;

  ComidasDia({
    required this.desayuno,
    required this.almuerzo,
    required this.cena,
    required this.colacion,
  });

  factory ComidasDia.fromJson(Map<String, dynamic> json) {
    return ComidasDia(
      desayuno: json['desayuno'],
      almuerzo: json['almuerzo'],
      cena: json['cena'],
      colacion: json['colacion'],
    );
  }
}
