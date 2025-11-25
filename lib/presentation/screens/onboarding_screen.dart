import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'main_layout.dart';
import '../providers/data_provider.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _page = 0;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController(); // Nuevo

  String _selectedGoal = "Perder Peso";
  String _selectedLevel = "Intermedio";

  @override
  Widget build(BuildContext context) {
    // Lista de páginas
    final List<Widget> pages = [
      _buildNamePage(),
      _buildAgePage(), // Nueva página de edad
      _buildGoalPage(),
      _buildLevelPage(),
    ];

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
                  children: pages,
                ),
              ),

              // Indicadores de página (Puntos)
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(
                  pages.length,
                  (index) => Container(
                    margin: const EdgeInsets.symmetric(horizontal: 4),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _page == index ? Colors.white : Colors.white38,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // Botón
              Padding(
                padding: const EdgeInsets.all(30),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: const Color(0xFF8B5CF6),
                    minimumSize: const Size(double.infinity, 50),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  onPressed: () {
                    if (_page < pages.length - 1) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    } else {
                      _finishOnboarding();
                    }
                  },
                  child: Text(
                    _page == pages.length - 1 ? "COMENZAR" : "CONTINUAR",
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _finishOnboarding() {
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    String name = _nameController.text.trim().isEmpty
        ? "Atleta"
        : _nameController.text.trim();
    int age = int.tryParse(_ageController.text) ?? 30; // Edad por defecto 30

    dataProvider.setUserData(name, _selectedGoal, _selectedLevel, age);

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainLayout()),
    );
  }

  // --- PÁGINAS ---

  Widget _buildNamePage() {
    return _buildPageBase(
      icon: Icons.fitness_center,
      title: "Bienvenido a BioSync",
      subtitle: "¿Cómo te llamas?",
      child: TextField(
        controller: _nameController,
        decoration: _inputDecor("Tu nombre"),
      ),
    );
  }

  // NUEVA PÁGINA DE EDAD
  Widget _buildAgePage() {
    return _buildPageBase(
      icon: Icons.cake,
      title: "Tu Edad",
      subtitle: "Para personalizar tu plan",
      child: TextField(
        controller: _ageController,
        keyboardType: TextInputType.number,
        decoration: _inputDecor("Ej: 28"),
      ),
    );
  }

  Widget _buildGoalPage() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Define tu Meta",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 30),
          _buildSelectableOption(
            "Perder Peso",
            Icons.trending_down,
            _selectedGoal,
            (v) => setState(() => _selectedGoal = v),
          ),
          _buildSelectableOption(
            "Ganar Músculo",
            Icons.fitness_center,
            _selectedGoal,
            (v) => setState(() => _selectedGoal = v),
          ),
          _buildSelectableOption(
            "Mantenerme Activo",
            Icons.favorite,
            _selectedGoal,
            (v) => setState(() => _selectedGoal = v),
          ),
        ],
      ),
    );
  }

  Widget _buildLevelPage() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Tu Nivel",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 30),
          _buildSelectableOption(
            "Principiante",
            Icons.star_border,
            _selectedLevel,
            (v) => setState(() => _selectedLevel = v),
          ),
          _buildSelectableOption(
            "Intermedio",
            Icons.star_half,
            _selectedLevel,
            (v) => setState(() => _selectedLevel = v),
          ),
          _buildSelectableOption(
            "Avanzado",
            Icons.star,
            _selectedLevel,
            (v) => setState(() => _selectedLevel = v),
          ),
        ],
      ),
    );
  }

  // Helpers de UI
  Widget _buildPageBase({
    required IconData icon,
    required String title,
    required String subtitle,
    required Widget child,
  }) {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 80, color: Colors.white),
          const SizedBox(height: 30),
          Text(
            title,
            style: const TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          Text(
            subtitle,
            style: const TextStyle(fontSize: 18, color: Colors.white70),
          ),
          const SizedBox(height: 40),
          child,
        ],
      ),
    );
  }

  InputDecoration _inputDecor(String hint) {
    return InputDecoration(
      filled: true,
      fillColor: Colors.white,
      hintText: hint,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _buildSelectableOption(
    String title,
    IconData icon,
    String groupValue,
    Function(String) onTap,
  ) {
    bool isSelected = title == groupValue;
    return GestureDetector(
      onTap: () => onTap(title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: isSelected
              ? Border.all(color: const Color(0xFF8B5CF6), width: 3)
              : null,
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected ? const Color(0xFF8B5CF6) : Colors.grey,
            ),
            const SizedBox(width: 15),
            Text(
              title,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: isSelected ? const Color(0xFF8B5CF6) : Colors.black87,
              ),
            ),
            const Spacer(),
            if (isSelected)
              const Icon(Icons.check_circle, color: Color(0xFF8B5CF6)),
          ],
        ),
      ),
    );
  }
}
