import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
// IMPORTANTE: Estas dos librerías son necesarias para arreglar el error de la fecha
import 'package:intl/date_symbol_data_local.dart';
import 'package:intl/intl.dart';

import 'firebase_options.dart';
import 'presentation/providers/auth_provider.dart';
import 'presentation/providers/chat_provider.dart';
import 'presentation/providers/data_provider.dart';
import 'presentation/screens/auth/login_screen.dart';
import 'presentation/screens/main_layout.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});
  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _index = 0;

  final _screens = [
    const ExerciseScreen(),
    const NutritionScreen(),
    ChatScreen(),
    const ProfileScreen(), // <--- AGREGAR A LA LISTA
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        // Usamos NavigationBar moderno de Material 3
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        indicatorColor: const Color(0xFFEADDFF),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.fitness_center_outlined),
            selectedIcon: Icon(Icons.fitness_center),
            label: "Entrenar",
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(Icons.restaurant),
            label: "Nutrición",
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: "FitAI",
          ),
          NavigationDestination(
            // <--- NUEVO BOTÓN
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: "Perfil",
          ),
        ],
      ),
    );
  }
}
