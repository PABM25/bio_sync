import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import '../models/user.model.dart'; // Asegúrate de importar tu modelo

class GeminiService {
  late GenerativeModel _model;
  ChatSession? _chat;
  bool _isInitialized = false;

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? "";
    // Usamos flash por velocidad y eficiencia
    _model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);
  }

  Future<void> initializeContext() async {
    if (_isInitialized) return;

    // Aquí puedes añadir el prompt de sistema para el Chatbot si lo necesitas
    // _chat = _model.startChat(...)

    _isInitialized = true;
  }

  // --- NUEVA FUNCIÓN: Generador de JSON Estructurado ---
  Future<String> generateRoutineJson(UserProfile user) async {
    final prompt =
        """
    Actúa como un entrenador personal de élite. Crea una rutina de ejercicios para HOY en formato JSON.
    
    PERFIL USUARIO:
    - Nivel: ${user.level}
    - Objetivo: ${user.goal}
    - Edad: ${user.age}
    - Género: ${user.gender}
    - Grasa Corporal Estimada: ${user.bodyFatPercentage.toStringAsFixed(1)}%

    REGLAS DE RESPUESTA:
    1. Responde ÚNICAMENTE con un JSON válido. Sin markdown, sin explicaciones previas.
    2. La estructura debe ser EXACTAMENTE así:
    {
      "dia": ${user.currentDay},
      "enfoque": "Texto corto (ej: Pierna y Glúteo)",
      "ejercicios": [
        {
          "nombre": "Nombre Ejercicio",
          "descanso": "ej: 60 seg",
          "nota": "Tip técnico breve",
          "repeticiones": { "standard": "ej: 4 series de 12 reps" }
        }
      ]
    }
    3. Genera entre 5 y 6 ejercicios adaptados perfectamente al nivel y objetivo.
    """;

    try {
      final response = await _model.generateContent([Content.text(prompt)]);
      String? text = response.text;

      // Limpieza de formato por si Gemini responde con bloques de código ```json
      if (text != null) {
        text = text.replaceAll('```json', '').replaceAll('```', '').trim();
      }

      return text ?? "{}";
    } catch (e) {
      print("❌ Error Gemini JSON: $e");
      return "{}";
    }
  }

  // Tu función de chat existente (para la pantalla de Chat)
  Future<String> sendMessage(String message, {String? dailyContext}) async {
    // Inicialización simple si no existe chat
    _chat ??= _model.startChat();
    try {
      String finalPrompt = message;
      if (dailyContext != null) {
        finalPrompt = "Contexto:\n$dailyContext\n\nMensaje: $message";
      }
      final response = await _chat!.sendMessage(Content.text(finalPrompt));
      return response.text ?? "No pude responder.";
    } catch (e) {
      return "Error de conexión: $e";
    }
  }
}
