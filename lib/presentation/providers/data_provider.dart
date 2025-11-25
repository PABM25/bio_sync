import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import '../../data/models/workout_model.dart';
import '../../data/models/diet_model.dart';

class DataProvider with ChangeNotifier {
  // Estado del Usuario
  String userName = "Atleta";
  String userGoal = "Mantenerme Activo";
  String userLevel = "Intermedio";
  int currentDay = 1; // Día actual del reto (1 a 45)

  // Datos cargados
  List<RutinaDia> _rutinaCompleta = [];
  List<PlanDiario> _planNutricional = [];
  bool isLoading = true;

  // Getters para la UI
  RutinaDia? get rutinaHoy {
    if (_rutinaCompleta.isEmpty) return null;
    // Buscamos la rutina que coincida con el día actual
    return _rutinaCompleta.firstWhere(
      (r) => r.dia == currentDay,
      orElse: () => _rutinaCompleta.first,
    );
  }

  PlanDiario? get dietaHoy {
    if (_planNutricional.isEmpty) return null;
    // Lógica simple: Ciclo de 7 días. Día 1 = Lunes, Día 8 = Lunes...
    int indexDiaSemana = (currentDay - 1) % 7;
    if (indexDiaSemana < _planNutricional.length) {
      return _planNutricional[indexDiaSemana];
    }
    return _planNutricional.first;
  }

  Future<void> loadData() async {
    try {
      // 1. Cargar JSON de Ejercicios
      final String workoutString = await rootBundle.loadString(
        'assets/data/reto45.json',
      );
      final workoutJson = json.decode(workoutString);
      var listRutinas = workoutJson['rutina'] as List;
      _rutinaCompleta = listRutinas.map((x) => RutinaDia.fromJson(x)).toList();

      // 2. Cargar JSON de Nutrición
      final String dietString = await rootBundle.loadString(
        'assets/data/plan-nutri.json',
      );
      final dietJson = json.decode(dietString);
      var listDietas = dietJson['menu_semanal'] as List;
      _planNutricional = listDietas.map((x) => PlanDiario.fromJson(x)).toList();

      isLoading = false;
      notifyListeners();
      print("✅ Datos de JSON cargados correctamente en DataProvider");
    } catch (e) {
      print("❌ Error cargando datos locales: $e");
      isLoading = false;
      notifyListeners();
    }
  }

  // Guardar datos del Onboarding
  void setUserData(String name, String goal, String level) {
    userName = name;
    userGoal = goal;
    userLevel = level;
    notifyListeners();
  }

  // Avanzar de día (simulación)
  void completeDay() {
    if (currentDay < 45) {
      currentDay++;
      notifyListeners();
    }
  }
}
