import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/models/workout_model.dart';
import '../../data/models/diet_model.dart';

class DataProvider with ChangeNotifier {
  // Datos del Usuario
  String userName = "Atleta";
  String userGoal = "Perder Peso";
  String userLevel = "Intermedio";
  String userGender = "Hombre"; // <--- NUEVO
  int userAge = 30;

  // Progreso Reto
  int currentDay = 1;
  int waterGlasses = 0;

  List<RutinaDia> _rutinaCompleta = [];
  List<PlanDiario> _planNutricional = [];
  bool isLoading = true;

  // Rutina del Reto (Challenge)
  RutinaDia? get rutinaRetoHoy {
    if (_rutinaCompleta.isEmpty) return null;
    return _rutinaCompleta.firstWhere(
      (r) => r.dia == currentDay,
      orElse: () => _rutinaCompleta.first,
    );
  }

  // --- NUEVO: Lógica de Rutina Personalizada ---
  RutinaDia get rutinaPersonalizada {
    String enfoque = "Entrenamiento Personal";
    List<Ejercicio> ejercicios = [];

    // Generar rutina basada en el OBJETIVO (Lógica simple)
    if (userGoal == "Ganar Músculo") {
      enfoque = "Hipertrofia & Fuerza";
      ejercicios = [
        Ejercicio(
          nombre: "Push-ups (Lagartijas)",
          descanso: "60 seg",
          repeticionesPorEdad: {"20s": 15, "30s": 12, "40s_mas": 10},
        ),
        Ejercicio(
          nombre: "Sentadillas Profundas",
          descanso: "60 seg",
          repeticionesPorEdad: {"20s": 20, "30s": 15, "40s_mas": 12},
        ),
        Ejercicio(
          nombre: "Fondos en silla",
          descanso: "45 seg",
          repeticionesPorEdad: {"20s": 15, "30s": 12, "40s_mas": 10},
        ),
        Ejercicio(
          nombre: "Desplantes (Lunges)",
          descanso: "45 seg",
          repeticionesPorEdad: {"20s": 20, "30s": 16, "40s_mas": 12},
        ),
        Ejercicio(
          nombre: "Plancha Abdominal",
          descanso: "60 seg",
          duracionPorEdad: {"20s": "45s", "30s": "30s", "40s_mas": "20s"},
        ),
      ];
    } else if (userGoal == "Perder Peso") {
      enfoque = "Cardio & Quema Grasa";
      ejercicios = [
        Ejercicio(
          nombre: "Jumping Jacks",
          descanso: "30 seg",
          repeticionesPorEdad: {"20s": 50, "30s": 40, "40s_mas": 30},
        ),
        Ejercicio(
          nombre: "Burpees",
          descanso: "45 seg",
          repeticionesPorEdad: {"20s": 15, "30s": 12, "40s_mas": 8},
        ),
        Ejercicio(
          nombre: "Mountain Climbers",
          descanso: "30 seg",
          duracionPorEdad: {"20s": "40s", "30s": "30s", "40s_mas": "20s"},
        ),
        Ejercicio(
          nombre: "High Knees",
          descanso: "30 seg",
          duracionPorEdad: {"20s": "40s", "30s": "30s", "40s_mas": "20s"},
        ),
        Ejercicio(
          nombre: "Sentadillas con Salto",
          descanso: "45 seg",
          repeticionesPorEdad: {"20s": 20, "30s": 15, "40s_mas": 10},
        ),
      ];
    } else {
      // Mantenerme
      enfoque = "Mantenimiento Full Body";
      ejercicios = [
        Ejercicio(
          nombre: "Jumping Jacks",
          descanso: "30 seg",
          repeticionesPorEdad: {"20s": 40, "30s": 30, "40s_mas": 20},
        ),
        Ejercicio(
          nombre: "Sentadillas",
          descanso: "30 seg",
          repeticionesPorEdad: {"20s": 20, "30s": 15, "40s_mas": 12},
        ),
        Ejercicio(
          nombre: "Push-ups (rodillas opcionales)",
          descanso: "45 seg",
          repeticionesPorEdad: {"20s": 12, "30s": 10, "40s_mas": 8},
        ),
        Ejercicio(
          nombre: "Plancha",
          descanso: "45 seg",
          duracionPorEdad: {"20s": "30s", "30s": "25s", "40s_mas": "20s"},
        ),
      ];
    }

    return RutinaDia(dia: 0, enfoque: enfoque, ejercicios: ejercicios);
  }

  PlanDiario? get dietaHoy {
    if (_planNutricional.isEmpty) return null;
    int indexDiaSemana = (currentDay - 1) % 7;
    if (indexDiaSemana < _planNutricional.length) {
      return _planNutricional[indexDiaSemana];
    }
    return _planNutricional.first;
  }

  String get grupoEdadUsuario {
    if (userAge < 30) return "20s";
    if (userAge < 40) return "30s";
    return "40s_mas";
  }

  Future<void> loadData() async {
    await _loadPreferences();
    try {
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

  Future<void> _loadPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        if (doc.exists && doc.data() != null) {
          final data = doc.data()!;
          if (data.containsKey('currentDay')) {
            currentDay = data['currentDay'];
            await prefs.setInt('currentDay', currentDay);
          }
          if (data.containsKey('name')) userName = data['name'];
          if (data.containsKey('age')) userAge = data['age'];
          if (data.containsKey('goal')) userGoal = data['goal']; // Cargar Meta
          if (data.containsKey('gender'))
            userGender = data['gender']; // Cargar Genero
        }
      } catch (e) {
        print("Error sync Firebase: $e");
      }
    }

    userName = prefs.getString('userName') ?? userName;
    userAge = prefs.getInt('userAge') ?? userAge;
    userGoal = prefs.getString('userGoal') ?? userGoal;
    userLevel = prefs.getString('userLevel') ?? userLevel;
    userGender = prefs.getString('userGender') ?? userGender; // Cargar local
    currentDay = prefs.getInt('currentDay') ?? currentDay;
    waterGlasses = prefs.getInt('waterGlasses') ?? 0;

    notifyListeners();
  }

  Future<void> setUserData(
    String name,
    String goal,
    String level,
    int age,
    String gender,
  ) async {
    userName = name;
    userGoal = goal;
    userLevel = level;
    userAge = age;
    userGender = gender;

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', name);
    await prefs.setString('userGoal', goal);
    await prefs.setString('userLevel', level);
    await prefs.setInt('userAge', age);
    await prefs.setString('userGender', gender);

    notifyListeners();
  }

  void drinkWater() async {
    if (waterGlasses < 8) {
      waterGlasses++;
      notifyListeners();
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('waterGlasses', waterGlasses);
    }
  }

  void resetWater() async {
    waterGlasses = 0;
    notifyListeners();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('waterGlasses', 0);
  }

  Future<void> completeDay() async {
    if (currentDay < 45) {
      currentDay++;
      waterGlasses = 0;
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('currentDay', currentDay);
      await prefs.setInt('waterGlasses', 0);
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        FirebaseFirestore.instance.collection('users').doc(user.uid).update({
          'currentDay': currentDay,
        });
      }
      notifyListeners();
    }
  }

  Future<void> resetProgress() async {
    currentDay = 1;
    waterGlasses = 0;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('currentDay', 1);
    await prefs.setInt('waterGlasses', 0);
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      FirebaseFirestore.instance.collection('users').doc(user.uid).update({
        'currentDay': 1,
      });
    }
    notifyListeners();
  }

  Future<void> clearLocalData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    userName = "Atleta";
    userGoal = "Mantenerme Activo";
    userLevel = "Intermedio";
    userGender = "Hombre";
    userAge = 30;
    currentDay = 1;
    waterGlasses = 0;
    notifyListeners();
  }
}
