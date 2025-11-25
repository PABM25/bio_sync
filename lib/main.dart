import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/chat_provider.dart';
import 'presentation/providers/data_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/main_layout.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Cargamos las variables de entorno para la IA
  await dotenv.load(fileName: ".env");

  // Inicializamos Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
    MultiProvider(
      providers: [
        // Proveedor de Autenticación (Login/Registro)
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        // Proveedor del Chat IA
        ChangeNotifierProvider(create: (_) => ChatProvider()),
        // Proveedor de Datos (Nutrición/Ejercicios) - Cargamos datos al iniciar
        ChangeNotifierProvider(create: (_) => DataProvider()..loadData()),
      ],
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8B5CF6)),
        scaffoldBackgroundColor: const Color(0xFFF3F4F6),
      ),
      // Usamos un "Wrapper" para decidir qué pantalla mostrar
      home: const AuthWrapper(),
    );
  }
}

// Este widget decide si mostrar Login o la App principal
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // Si hay usuario logueado, vamos a la app principal
    if (authProvider.user != null) {
      return const MainLayout();
    }

    // Si no, vamos al login
    return const LoginScreen();
  }
}
