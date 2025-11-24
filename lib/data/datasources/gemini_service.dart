import 'package:flutter/services.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  late GenerativeModel _model;
  ChatSession? _chat;
  bool _isInitialized = false;

  // Inicializa el modelo con la API KEY del .env
  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? "";
    if (apiKey.isEmpty) {
      print("❌ ERROR: No se encontró GEMINI_API_KEY en el archivo .env");
    }

    // CAMBIO AQUÍ: Usamos 'gemini-1.5-flash' que es más rápido y actual.
    _model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);
  }

  // Carga los JSONs y prepara a la IA (Grounding)
  Future<void> initializeContext() async {
    if (_isInitialized) return;

    try {
      // 1. Leemos tus archivos locales
      final rutinas = await rootBundle.loadString('assets/data/reto45.json');
      final nutricion = await rootBundle.loadString(
        'assets/data/plan-nutri.json',
      );

      // 2. Creamos el "Prompt del Sistema" para darle personalidad
      final contextData =
          """
      Actúa como FitAI, el entrenador personal de la app BioSync.
      
      Tus instrucciones principales son:
      1. Basa tus recomendaciones EXCLUSIVAMENTE en los siguientes planes JSON.
      2. Si te preguntan por ejercicios, busca en el 'PLAN DE ENTRENAMIENTO'.
      3. Si te preguntan por comida, busca en el 'PLAN NUTRICIONAL'.
      4. Si la pregunta no está en los planes, da un consejo general breve y aclara que no está en tu base de datos.
      5. Sé motivador, energético y breve.

      --- PLAN DE ENTRENAMIENTO ---
      $rutinas
      
      --- PLAN NUTRICIONAL ---
      $nutricion
      """;

      // 3. Iniciamos el chat con este conocimiento
      _chat = _model.startChat(
        history: [
          Content.text(contextData),
          Content.model([
            TextPart(
              "¡Entendido! Soy FitAI. Conozco el Reto de 45 días y el plan nutricional al detalle. ¿En qué puedo ayudarte hoy?",
            ),
          ]),
        ],
      );

      _isInitialized = true;
      print("✅ FitAI Inicializado con contexto");
    } catch (e) {
      print("❌ Error cargando contexto de IA: $e");
    }
  }

  // Enviar mensaje del usuario
  Future<String> sendMessage(String message) async {
    if (_chat == null) await initializeContext();

    try {
      final response = await _chat!.sendMessage(Content.text(message));
      return response.text ?? "No pude generar una respuesta.";
    } catch (e) {
      return "Error de conexión con FitAI. Verifica tu internet o API Key. ($e)";
    }
  }
}
