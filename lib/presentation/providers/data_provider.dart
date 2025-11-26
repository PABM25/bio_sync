import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Para rootBundle
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import '../../data/models/workout_model.dart';
import '../../data/models/diet_model.dart';
import '../../data/models/user.model.dart'; // Importa UserProfile
import '../../data/datasources/gemini_service.dart'; // Importa el servicio

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
  RutinaDia? _rutinaIAGenerada; // Aquí guardamos la respuesta de la IA
  List<RutinaDia> _rutinaCompleta = []; // Rutina del JSON local (Reto 45)
  List<PlanDiario> _planNutricional = []; // Dieta del JSON local

  bool isLoading = true;
  bool isGeneratingRoutine = false; // Estado para carga de IA

  // Getter inteligente: Devuelve IA si existe, sino Fallback
  RutinaDia get rutinaPersonalizada {
    if (_rutinaIAGenerada != null) {
      return _rutinaIAGenerada!;
    }
    return _getRutinaHardcodedFallback(); // Tu lógica antigua como respaldo
  }

  // Getter para el reto de 45 días (JSON local)
  RutinaDia? get rutinaRetoHoy {
    if (_rutinaCompleta.isEmpty) return null;
    return _rutinaCompleta.firstWhere(
      (r) => r.dia == currentDay,
      orElse: () => _rutinaCompleta.first,
    );
  }

  // Getter para la dieta
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

  // --- NUEVO: Generar Rutina con IA (CORREGIDO) ---
  Future<void> generarRutinaIA(UserProfile user) async {
    if (_rutinaIAGenerada != null)
      return; // Evitar re-generar si ya tenemos una para esta sesión

    isGeneratingRoutine = true;
    notifyListeners();

    try {
      print("🤖 Solicitando rutina a Gemini...");
      final jsonString = await _geminiService.generateRoutineJson(user);
      final Map<String, dynamic> jsonData = json.decode(jsonString);

      // Transformamos el JSON de Gemini a tu modelo RutinaDia
      // FIX: Usamos .toString() en TODOS los campos para evitar errores de tipo int vs String
      List<Ejercicio> ejercicios = (jsonData['ejercicios'] as List).map((e) {
        // Extraemos el valor de repetición de forma segura
        String repeticionValor = "10 reps"; // Valor por defecto
        if (e['repeticiones'] != null &&
            e['repeticiones']['standard'] != null) {
          repeticionValor = e['repeticiones']['standard'].toString();
        }

        return Ejercicio(
          nombre: e['nombre']?.toString() ?? "Ejercicio IA",
          descanso: e['descanso']?.toString() ?? "30s",
          nota: e['nota']?.toString(),
          // Truco: Guardamos el valor estándar en todas las claves de edad
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
      // Si falla, silenciosamente nos quedamos con el fallback
    } finally {
      isGeneratingRoutine = false;
      notifyListeners();
    }
  }

  // --- Tu lógica original como respaldo (Fallback) ---
  RutinaDia _getRutinaHardcodedFallback() {
    String enfoque = "Entrenamiento Personal (Básico)";
    List<Ejercicio> ejercicios = [];

    if (userGoal == "Ganar Músculo") {
      enfoque = "Fuerza Básica";
      ejercicios = [
        Ejercicio(
          nombre: "Push-ups",
          descanso: "60s",
          repeticionesPorEdad: {"20s": 15, "30s": 12, "40s_mas": 10},
        ),
        Ejercicio(
          nombre: "Sentadillas",
          descanso: "60s",
          repeticionesPorEdad: {"20s": 20, "30s": 15, "40s_mas": 12},
        ),
      ];
    } else {
      enfoque = "Cardio Básico";
      ejercicios = [
        Ejercicio(
          nombre: "Jumping Jacks",
          descanso: "30s",
          repeticionesPorEdad: {"20s": 50, "30s": 40, "40s_mas": 30},
        ),
        Ejercicio(
          nombre: "Burpees",
          descanso: "45s",
          repeticionesPorEdad: {"20s": 10, "30s": 8, "40s_mas": 6},
        ),
      ];
    }

    return RutinaDia(dia: 0, enfoque: enfoque, ejercicios: ejercicios);
  }

  // --- Métodos de Carga de Datos (JSON Local) ---
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
