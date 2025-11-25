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
    await _geminiService.initializeContext();
    _messages.add(
      ChatMessage(
        text:
            "¡Hola! Soy FitAI 💪. Pregúntame sobre tu rutina de hoy o tu plan de comidas.",
        isUser: false,
      ),
    );
    notifyListeners();
  }

  // Aceptamos un contexto opcional aquí
  Future<void> sendMessage(String text, {String? contextData}) async {
    if (text.trim().isEmpty) return;

    _messages.add(ChatMessage(text: text, isUser: true));
    _isLoading = true;
    notifyListeners();

    // Pasamos el contextoData al servicio
    final response = await _geminiService.sendMessage(
      text,
      dailyContext: contextData,
    );

    _messages.add(ChatMessage(text: response, isUser: false));
    _isLoading = false;
    notifyListeners();
  }
}
