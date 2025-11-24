import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'presentation/providers/chat_provider.dart';
import 'presentation/screens/ai_chat/chat_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Cargar secretos (.env)
  await dotenv.load(fileName: "assets/.env");

  // 2. Inicializar Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    // 3. Inyectar el ChatProvider en toda la app
    MultiProvider(
      providers: [ChangeNotifierProvider(create: (_) => ChatProvider())],
      child: const BioSyncApp(),
    ),
  );
}

class BioSyncApp extends StatelessWidget {
  const BioSyncApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'BioSync',
      theme: ThemeData(
        useMaterial3: true,
        // Usamos el color morado de tus capturas
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8B5CF6)),
      ),
      // Definimos la pantalla de chat como la inicial por ahora
      home: ChatScreen(),
    );
  }
}
