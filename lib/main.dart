import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'firebase_options.dart';
import 'presentation/providers/chat_provider.dart';
import 'presentation/screens/onboarding_screen.dart'; // Importante

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Nota: 'assets/.env' funcionará si moviste la carpeta assets a la raíz
  await dotenv.load(fileName: ".env");
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(
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
        colorScheme: ColorScheme.fromSeed(seedColor: const Color(0xFF8B5CF6)),
      ),
      home: const OnboardingScreen(), // Arranca aquí
    );
  }
}
