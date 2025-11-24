import 'package:flutter/material.dart';
import 'dashboard_screen.dart';
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
    const DashboardScreen(),
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
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Inicio"),
          BottomNavigationBarItem(
            icon: Icon(Icons.restaurant),
            label: "Nutrición",
          ),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: "FitAI"),
        ],
      ),
    );
  }
}
