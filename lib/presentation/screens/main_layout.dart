import 'package:flutter/material.dart';
import 'exercise_screen.dart'; // Pestaña Personalizada
import 'challenge_screen.dart'; // Pestaña Reto (NUEVA)
import 'nutrition_screen.dart';
import 'ai_chat/chat_screen.dart';
import 'profile_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});
  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _index = 0;

  // Ahora tenemos 5 pestañas
  final _screens = [
    const ExerciseScreen(), // 0: Rutina Personalizada
    const ChallengeScreen(), // 1: Reto 45 Días (NUEVA)
    const NutritionScreen(), // 2: Nutrición
    ChatScreen(), // 3: Chat AI
    const ProfileScreen(), // 4: Perfil
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        indicatorColor: const Color(0xFFEADDFF),
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.accessibility_new),
            selectedIcon: Icon(Icons.accessibility_new_rounded),
            label: "Mi Plan", // Personalizado
          ),
          NavigationDestination(
            icon: Icon(Icons.flag_outlined),
            selectedIcon: Icon(Icons.flag),
            label: "Reto 45", // Reto
          ),
          NavigationDestination(
            icon: Icon(Icons.restaurant_outlined),
            selectedIcon: Icon(Icons.restaurant),
            label: "Dieta",
          ),
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: "FitAI",
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            selectedIcon: Icon(Icons.person),
            label: "Perfil",
          ),
        ],
      ),
    );
  }
}
