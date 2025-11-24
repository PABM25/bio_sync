import 'package:flutter/material.dart';
import 'main_layout.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _page = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF8B5CF6), Color(0xFFC4B5FD)],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: PageView(
                  controller: _pageController,
                  onPageChanged: (p) => setState(() => _page = p),
                  children: [
                    _buildPage(
                      "Bienvenido a BioSync",
                      "Tu entrenador personal con IA",
                      Icons.fitness_center,
                    ),
                    _buildPage(
                      "Define tu Meta",
                      "Perder peso, Ganar músculo o Mantenerte",
                      Icons.flag,
                    ),
                    _buildPage(
                      "Tu Nivel",
                      "Adaptamos el plan a tu experiencia",
                      Icons.bar_chart,
                    ),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(30),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF8B5CF6),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    if (_page < 2) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    } else {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => const MainLayout()),
                      );
                    }
                  },
                  child: Text(_page == 2 ? "COMENZAR" : "CONTINUAR"),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPage(String title, String subtitle, IconData icon) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(icon, size: 100, color: Colors.white),
        const SizedBox(height: 20),
        Text(
          title,
          style: const TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          subtitle,
          style: const TextStyle(fontSize: 16, color: Colors.white70),
        ),
      ],
    );
  }
}
