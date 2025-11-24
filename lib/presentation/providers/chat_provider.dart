import 'package:flutter/material.dart';
import '../../data/datasources/gemini_service.dart';

class ChatMessage {
  final String text;
  final bool isUser;
  ChatMessage({required this.text, required this.isUser});
}

class ChatProvider with ChangeNotifier {
  final GeminiService _geminiService = GeminiService();
  final List<ChatMessage> _messages = [];
  bool _isLoading = false;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;

  ChatProvider() {
    _initAI();
  }

  Future<void> _initAI() async {
    // Inicializa la IA leyendo los archivos
    await _geminiService.initializeContext();

    // Mensaje de bienvenida
    _messages.add(
      ChatMessage(
        text:
            "¡Hola! Soy FitAI 💪. Conozco tu plan de nutrición y tu reto de 45 días. ¿En qué te ayudo?",
        isUser: false,
      ),
    );
    notifyListeners();
  }

  Future<void> sendMessage(String text) async {
    if (text.trim().isEmpty) return;

    // 1. Agrega mensaje del usuario
    _messages.add(ChatMessage(text: text, isUser: true));
    _isLoading = true;
    notifyListeners();

    // 2. Pide respuesta a la IA
    final response = await _geminiService.sendMessage(text);

    // 3. Agrega respuesta de la IA
    _messages.add(ChatMessage(text: response, isUser: false));
    _isLoading = false;
    notifyListeners();
  }
}
