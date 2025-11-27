import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para rootBundle
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/models/workout_model.dart';
import '../../data/models/diet_model.dart';
import '../../data/models/user.model.dart';
import '../../data/datasources/gemini_service.dart';

class DataProvider with ChangeNotifier {
  // Servicios
  final GeminiService _geminiService = GeminiService();

  // Datos Usuario
  String userName = "Atleta";
  String userGoal = "Perder Peso";
  String userLevel = "Intermedio";
  String userGender = "Hombre";
  int userAge = 30;

  // Progreso
  int currentDay = 1;
  int waterGlasses = 0;

  // Rutinas
  RutinaDia? _rutinaIAGenerada;
  List<RutinaDia> _rutinaCompleta = [];

  // NUTRICIÓN: Datos completos del JSON
  Map<String, dynamic> _fullNutritionalPlan = {};
  List<PlanDiario> _menuSemanal = [];

  bool isLoading = true;
  bool isGeneratingRoutine = false;

  // --- GETTERS ---

  RutinaDia get rutinaPersonalizada {
    if (_rutinaIAGenerada != null) {
      return _rutinaIAGenerada!;
    }
    return _getRutinaHardcodedFallback();
  }

  RutinaDia? get rutinaRetoHoy {
    if (_rutinaCompleta.isEmpty) return null;
    return _rutinaCompleta.firstWhere(
      (r) => r.dia == currentDay,
      orElse: () => _rutinaCompleta.first,
    );
  }

  // Getter para acceder a toda la info del JSON (Profesional, Metas, etc.)
  Map<String, dynamic> get nutritionalPlan => _fullNutritionalPlan;

  // Getter para el menú (Lista de objetos)
  List<PlanDiario> get menuSemanal => _menuSemanal;

  PlanDiario? get dietaHoy {
    if (_menuSemanal.isEmpty) return null;
    int indexDiaSemana = (currentDay - 1) % 7;
    if (indexDiaSemana < _menuSemanal.length) {
      return _menuSemanal[indexDiaSemana];
    }
    return _menuSemanal.first;
  }

  String get grupoEdadUsuario {
    if (userAge < 30) return "20s";
    if (userAge < 40) return "30s";
    return "40s_mas";
  }

  // --- Generar Rutina con IA ---
  Future<void> generarRutinaIA(UserProfile user) async {
    if (_rutinaIAGenerada != null) return;

    isGeneratingRoutine = true;
    notifyListeners();

    try {
      print("🤖 Solicitando rutina a Gemini...");
      final jsonString = await _geminiService.generateRoutineJson(user);

      if (jsonString == "{}") throw Exception("Respuesta vacía de IA");

      final Map<String, dynamic> jsonData = json.decode(jsonString);

      List<Ejercicio> ejercicios = (jsonData['ejercicios'] as List).map((e) {
        String repeticionValor = "10 reps";
        if (e['repeticiones'] != null &&
            e['repeticiones']['standard'] != null) {
          repeticionValor = e['repeticiones']['standard'].toString();
        }

        return Ejercicio(
          nombre: e['nombre']?.toString() ?? "Ejercicio IA",
          descanso: e['descanso']?.toString() ?? "30s",
          nota: e['nota']?.toString(),
          repeticionesPorEdad: {
            "20s": repeticionValor,
            "30s": repeticionValor,
            "40s_mas": repeticionValor,
          },
        );
      }).toList();

      _rutinaIAGenerada = RutinaDia(
        dia: jsonData['dia'] is int
            ? jsonData['dia']
            : int.tryParse(jsonData['dia'].toString()) ?? 1,
        enfoque: jsonData['enfoque']?.toString() ?? "Entrenamiento Inteligente",
        ejercicios: ejercicios,
      );

      print("✅ Rutina IA cargada con éxito");
    } catch (e) {
      print("❌ Error generando rutina IA: $e");
    } finally {
      isGeneratingRoutine = false;
      notifyListeners();
    }
  }

  // --- Fallback (Respaldo) ---
  RutinaDia _getRutinaHardcodedFallback() {
    String enfoque = "Entrenamiento Personal (Básico)";
    List<Ejercicio> ejercicios = [];

    if (userGoal == "Ganar Músculo") {
      enfoque = "Fuerza Básica";
      ejercicios = [
        Ejercicio(
          nombre: "Push-ups",
          descanso: "60s",
          repeticionesPorEdad: {"20s": "15", "30s": "12", "40s_mas": "10"},
        ),
        Ejercicio(
          nombre: "Sentadillas",
          descanso: "60s",
          repeticionesPorEdad: {"20s": "20", "30s": "15", "40s_mas": "12"},
        ),
      ];
    } else {
      enfoque = "Cardio Básico";
      ejercicios = [
        Ejercicio(
          nombre: "Jumping Jacks",
          descanso: "30s",
          repeticionesPorEdad: {"20s": "50", "30s": "40", "40s_mas": "30"},
        ),
        Ejercicio(
          nombre: "Burpees",
          descanso: "45s",
          repeticionesPorEdad: {"20s": "10", "30s": "8", "40s_mas": "6"},
        ),
      ];
    }

    return RutinaDia(dia: 0, enfoque: enfoque, ejercicios: ejercicios);
  }

  // --- Métodos de Carga de Datos (ACTUALIZADO) ---
  Future<void> loadData() async {
    // Si ya tenemos datos, no recargamos
    if (_rutinaCompleta.isNotEmpty && _fullNutritionalPlan.isNotEmpty) {
      await _loadPreferences();
      isLoading = false;
      notifyListeners();
      return;
    }

    await _loadPreferences();
    try {
      // 1. Cargar Reto 45
      final workoutString = await rootBundle.loadString(
        'assets/data/reto45.json',
      );
      final workoutJson = json.decode(workoutString);
      _rutinaCompleta = (workoutJson['rutina'] as List)
          .map((x) => RutinaDia.fromJson(x))
          .toList();

      // 2. Cargar Plan Nutricional Completo
      final dietString = await rootBundle.loadString(
        'assets/data/plan-nutri.json',
      );
      final dietJson = json.decode(dietString);

      // Guardamos el JSON crudo para mostrar info del profesional, etc.
      _fullNutritionalPlan = dietJson;

      // También guardamos el menú como lista de objetos (para compatibilidad)
      _menuSemanal = (dietJson['menu_semanal'] as List)
          .map((x) => PlanDiario.fromJson(x))
          .toList();

      isLoading = false;
      notifyListeners();
    } catch (e) {
      print("❌ Error cargando datos locales: $e");
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
          if (data.containsKey('goal')) userGoal = data['goal'];
          if (data.containsKey('gender')) userGender = data['gender'];
        }
      } catch (e) {
        print("Error sync Firebase: $e");
      }
    }
    userName = prefs.getString('userName') ?? userName;
    userAge = prefs.getInt('userAge') ?? userAge;
    userGoal = prefs.getString('userGoal') ?? userGoal;
    userLevel = prefs.getString('userLevel') ?? userLevel;
    userGender = prefs.getString('userGender') ?? userGender;
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
