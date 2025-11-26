import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../providers/chat_provider.dart';
import '../../providers/data_provider.dart'; // Importamos DataProvider

class ChatScreen extends StatelessWidget {
  final TextEditingController _controller = TextEditingController();

  ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final chatProvider = Provider.of<ChatProvider>(context);
    // Obtenemos acceso a los datos pero SIN escuchar cambios (listen: false) para no reconstruir toda la pantalla
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "FitAI Entrenador",
          style: TextStyle(fontWeight: FontWeight.bold, color: Colors.white),
        ),
        backgroundColor: const Color(0xFF8B5CF6),
        elevation: 0,
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF8B5CF6), Colors.white],
            stops: [0.0, 0.3],
          ),
        ),
        child: Column(
          children: [
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: chatProvider.messages.length,
                itemBuilder: (context, index) {
                  final msg = chatProvider.messages[index];
                  return _MessageBubble(message: msg);
                },
              ),
            ),
            if (chatProvider.isLoading)
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text(
                  "FitAI está analizando tu plan...",
                  style: TextStyle(
                    color: Colors.grey,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
            Container(
              padding: const EdgeInsets.all(16.0),
              color: Colors.white,
              child: Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _controller,
                      decoration: InputDecoration(
                        hintText: "Ej: ¿Cómo hago las sentadillas?",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 10,
                        ),
                        filled: true,
                        fillColor: Colors.grey[100],
                      ),
                      onSubmitted: (_) =>
                          _sendMessage(context, chatProvider, dataProvider),
                    ),
                  ),
                  const SizedBox(width: 8),
                  FloatingActionButton(
                    mini: true,
                    backgroundColor: const Color(0xFF8B5CF6),
                    child: const Icon(Icons.send, color: Colors.white),
                    onPressed: () =>
                        _sendMessage(context, chatProvider, dataProvider),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage(
    BuildContext context,
    ChatProvider chat,
    DataProvider data,
  ) {
    if (_controller.text.trim().isNotEmpty) {
      // Preparamos el contexto del día actual para la IA
      final rutina = data.rutinaRetoHoy;
      final dieta = data.dietaHoy;

      String contextInfo =
          """
      Datos del Usuario:
      - Nombre: ${data.userName}
      - Nivel: ${data.userLevel}
      - Día del Reto: ${data.currentDay}
      
      Rutina de Hoy (Enfoque: ${rutina?.enfoque ?? 'Descanso'}):
      ${rutina?.ejercicios.map((e) => "- ${e.nombre} (${e.descanso})").join('\n') ?? 'Descanso'}
      
      Comidas de Hoy:
      - Desayuno: ${dieta?.comidas.desayuno ?? 'N/A'}
      - Almuerzo: ${dieta?.comidas.almuerzo ?? 'N/A'}
      """;

      chat.sendMessage(_controller.text, contextData: contextInfo);
      _controller.clear();
    }
  }
}

class _MessageBubble extends StatelessWidget {
  final ChatMessage message;
  const _MessageBubble({required this.message});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: message.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.75,
        ),
        decoration: BoxDecoration(
          color: message.isUser ? const Color(0xFF8B5CF6) : Colors.white,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: message.isUser
                ? const Radius.circular(16)
                : const Radius.circular(2),
            bottomRight: message.isUser
                ? const Radius.circular(2)
                : const Radius.circular(16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 5,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          message.text,
          style: TextStyle(
            color: message.isUser ? Colors.white : Colors.black87,
            fontSize: 15,
          ),
        ),
      ),
    );
  }
}
