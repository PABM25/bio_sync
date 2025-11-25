import 'package:flutter/material.dart';
// import 'dashboard_screen.dart'; // Ya no usamos esta, la reemplazamos por la moderna
import 'exercise_screen.dart'; // <--- IMPORTA LA NUEVA PANTALLA DE EJERCICIOS
import 'nutrition_screen.dart';
import 'ai_chat/chat_screen.dart';

class MainLayout extends StatefulWidget {
  const MainLayout({super.key});
  @override
  State<MainLayout> createState() => _MainLayoutState();
}

class _MainLayoutState extends State<MainLayout> {
  int _index = 0;

  final _screens = [
    const ExerciseScreen(), // <--- USAMOS ExerciseScreen COMO INICIO
    const NutritionScreen(),
    ChatScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_index],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _index,
        onTap: (i) => setState(() => _index = i),
        selectedItemColor: const Color(0xFF8B5CF6),
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.fitness_center), // Icono más acorde a ejercicios
            label: "Entrenar",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: "Nutrición",
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.chat_bubble_outline),
            label: "FitAI",
          ),
        ],
      ),
    );
  }
}
