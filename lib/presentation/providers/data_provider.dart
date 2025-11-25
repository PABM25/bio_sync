import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/workout_model.dart';
import '../../data/models/diet_model.dart';

class DataProvider with ChangeNotifier {
  // Datos del Usuario
  String userName = "Atleta";
  String userGoal = "Mantenerme Activo";
  String userLevel = "Intermedio";
  int userAge = 30; // Nuevo campo Edad

  // Progreso
  int currentDay = 1;

  // Datos cargados
  List<RutinaDia> _rutinaCompleta = [];
  List<PlanDiario> _planNutricional = [];
  bool isLoading = true;

  RutinaDia? get rutinaHoy {
    if (_rutinaCompleta.isEmpty) return null;
    return _rutinaCompleta.firstWhere(
      (r) => r.dia == currentDay,
      orElse: () => _rutinaCompleta.first,
    );
  }

  PlanDiario? get dietaHoy {
    if (_planNutricional.isEmpty) return null;
    int indexDiaSemana = (currentDay - 1) % 7;
    if (indexDiaSemana < _planNutricional.length) {
      return _planNutricional[indexDiaSemana];
    }
    return _planNutricional.first;
  }

  // Calcula la clave para el JSON: "20s", "30s" o "40s_mas"
  String get grupoEdadUsuario {
    if (userAge < 30) return "20s";
    if (userAge < 40) return "30s";
    return "40s_mas";
  }

  Future<void> loadData() async {
    await _loadPreferences(); // Cargar datos guardados del usuario

    try {
      // Cargar JSONs
      final workoutString = await rootBundle.loadString(
        'assets/data/reto45.json',
      );
      final workoutJson = json.decode(workoutString);
      _rutinaCompleta = (workoutJson['rutina'] as List)
          .map((x) => RutinaDia.fromJson(x))
          .toList();

      final dietString = await rootBundle.loadString(
        'assets/data/plan-nutri.json',
      );
      final dietJson = json.decode(dietString);
      _planNutricional = (dietJson['menu_semanal'] as List)
          .map((x) => PlanDiario.fromJson(x))
          .toList();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      print("❌ Error cargando datos: $e");
      isLoading = false;
      notifyListeners();
    }
  }

  // --- PERSISTENCIA ---

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    userName = prefs.getString('userName') ?? "Atleta";
    userGoal = prefs.getString('userGoal') ?? "Mantenerme Activo";
    userLevel = prefs.getString('userLevel') ?? "Intermedio";
    userAge = prefs.getInt('userAge') ?? 30;
    currentDay = prefs.getInt('currentDay') ?? 1;
    notifyListeners();
  }

  Future<void> setUserData(
    String name,
    String goal,
    String level,
    int age,
  ) async {
    userName = name;
    userGoal = goal;
    userLevel = level;
    userAge = age;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    await prefs.setString('userGoal', goal);
    await prefs.setString('userLevel', level);
    await prefs.setInt('userAge', age);

    notifyListeners();
  }

  Future<void> completeDay() async {
    if (currentDay < 45) {
      currentDay++;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('currentDay', currentDay);
      notifyListeners();
    }
  }

  // Para reiniciar progreso (útil para pruebas)
  Future<void> resetProgress() async {
    currentDay = 1;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentDay', 1);
    notifyListeners();
  }
}
