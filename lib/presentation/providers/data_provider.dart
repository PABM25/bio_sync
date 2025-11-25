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
  String userGoal = "Mantenerme Activo";
  String userLevel = "Intermedio";
  int userAge = 30;

  // Progreso
  int currentDay = 1;

  // --- NUEVO: HIDRATACIÓN ---
  int waterGlasses = 0; // Meta de 8 vasos diarios

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

    // Sincronización con Firestore
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
        }
      } catch (e) {
        print("Error sync Firebase: $e");
      }
    }

    // Carga local
    userName = prefs.getString('userName') ?? userName;
    userAge = prefs.getInt('userAge') ?? userAge;
    currentDay = prefs.getInt('currentDay') ?? currentDay;

    // Cargar agua (reseteo diario simple: si cambia el día, se puede reiniciar manualmente o con lógica de fecha)
    // Por simplicidad, no guardamos fecha hoy, pero en una app real guardarías 'lastWaterDate'.
    waterGlasses = prefs.getInt('waterGlasses') ?? 0;

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

  // --- LÓGICA DE AGUA ---
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
  // ----------------------

  Future<void> completeDay() async {
    if (currentDay < 45) {
      currentDay++;

      // Resetear agua al cambiar de día (opcional)
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
}
