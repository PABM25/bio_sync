import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'firebase_options.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/chat_provider.dart';
import 'presentation/providers/data_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/main_layout.dart';
import 'presentation/screens/onboarding_screen.dart'; // Importar Onboarding

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDateFormatting('es_ES', null);
  Intl.defaultLocale = 'es_ES';

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => ChatProvider()),
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
      home: const AuthWrapper(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);

    // 1. Si está cargando, mostrar spinner
    if (authProvider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 2. Si no hay usuario logueado -> Login
    if (authProvider.user == null) {
      return const LoginScreen();
    }

    // 3. Si hay usuario, pero NO ha completado el onboarding (no tiene perfil) -> Onboarding
    if (!authProvider.hasCompletedOnboarding) {
      return const OnboardingScreen();
    }

    // 4. Si tiene todo -> App Principal
    return const MainLayout();
  }
}
