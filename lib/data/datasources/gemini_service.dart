import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class GeminiService {
  late GenerativeModel _model;
  ChatSession? _chat;
  bool _isInitialized = false;

  GeminiService() {
    final apiKey = dotenv.env['GEMINI_API_KEY'] ?? "";
    if (apiKey.isEmpty) {
      print("❌ ERROR: No se encontró GEMINI_API_KEY en el archivo .env");
    }
    // Usamos gemini-1.5-flash por velocidad y costo
    _model = GenerativeModel(model: 'gemini-2.0-flash', apiKey: apiKey);
  }

  // Inicialización ligera: Solo define la personalidad, NO carga todos los datos aún
  Future<void> initializeContext() async {
    if (_isInitialized) return;

    try {
      final systemPrompt = """
      Eres FitAI, el entrenador personal virtual de la app BioSync.
      Tu tono es motivador, energético, breve y directo.
      Responderás preguntas sobre rutinas de ejercicio y nutrición basándote en el contexto que se te proveerá en cada mensaje.
      Si no tienes información sobre algo específico en el contexto proporcionado, ofrece un consejo general pero aclara que no está en el plan específico.
      """;

      _chat = _model.startChat(
        history: [
          Content.text(systemPrompt),
          Content.model([
            TextPart(
              "¡Entendido! Soy FitAI, listo para ayudar. ¿Cuál es el estado actual del usuario?",
            ),
          ]),
        ],
      );

      _isInitialized = true;
      print("✅ FitAI Inicializado (Modo Optimizado)");
    } catch (e) {
      print("❌ Error cargando contexto de IA: $e");
    }
  }

  // Enviamos mensaje + contexto del día específico (Inyección Dinámica)
  Future<String> sendMessage(String message, {String? dailyContext}) async {
    if (_chat == null) await initializeContext();

    try {
      // Construimos un prompt combinado
      String finalPrompt = message;

      if (dailyContext != null && dailyContext.isNotEmpty) {
        finalPrompt =
            """
        [CONTEXTO ACTUAL DEL USUARIO]
        $dailyContext
        -----------------------------
        [PREGUNTA DEL USUARIO]
        $message
        """;
      }

      final response = await _chat!.sendMessage(Content.text(finalPrompt));
      return response.text ?? "No pude generar una respuesta.";
    } catch (e) {
      return "Error de conexión con FitAI. Verifica tu internet. ($e)";
    }
  }
}
