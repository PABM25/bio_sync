import 'package:flutter/material.dart';
import 'package:provider/provider.dart'; // Importar Provider
import 'main_layout.dart';
import '../providers/data_provider.dart'; // Importar DataProvider

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _page = 0;

  // Controladores para los datos del usuario
  final TextEditingController _nameController = TextEditingController();
  String _selectedGoal = "Perder Peso";
  String _selectedLevel = "Intermedio";

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
                    // Página 1: Bienvenida y Nombre
                    _buildNamePage(),

                    // Página 2: Meta
                    _buildGoalPage(),

                    // Página 3: Nivel
                    _buildLevelPage(),
                  ],
                ),
              ),

              // Botón de Continuar/Comenzar
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
                    if (_page < 2) {
                      _pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                    } else {
                      // Lógica para guardar datos y navegar
                      _finishOnboarding();
                    }
                  },
                  child: Text(
                    _page == 2 ? "COMENZAR" : "CONTINUAR",
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
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
    // 1. Obtener el Provider (sin escuchar cambios, solo para ejecutar método)
    final dataProvider = Provider.of<DataProvider>(context, listen: false);

    // 2. Guardar los datos recolectados
    // Si el nombre está vacío, usamos "Atleta" por defecto
    String name = _nameController.text.trim().isEmpty
        ? "Atleta"
        : _nameController.text.trim();
    dataProvider.setUserData(name, _selectedGoal, _selectedLevel);

    // 3. Navegar a la pantalla principal
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainLayout()),
    );
  }

  // Página 1: Nombre
  Widget _buildNamePage() {
    return Padding(
      padding: const EdgeInsets.all(32.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.fitness_center, size: 80, color: Colors.white),
          const SizedBox(height: 30),
          const Text(
            "Bienvenido a BioSync",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 10),
          const Text(
            "Tu entrenador personal con IA",
            style: TextStyle(fontSize: 16, color: Colors.white70),
          ),
          const SizedBox(height: 50),
          const Align(
            alignment: Alignment.centerLeft,
            child: Text(
              "¿Cómo te llamas?",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _nameController,
            style: const TextStyle(color: Colors.black87),
            decoration: InputDecoration(
              filled: true,
              fillColor: Colors.white,
              hintText: "Tu nombre",
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 20,
                vertical: 15,
              ),
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Página 2: Meta
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
            (val) => setState(() => _selectedGoal = val),
          ),
          _buildSelectableOption(
            "Ganar Músculo",
            Icons.fitness_center,
            _selectedGoal,
            (val) => setState(() => _selectedGoal = val),
          ),
          _buildSelectableOption(
            "Mantenerme Activo",
            Icons.favorite,
            _selectedGoal,
            (val) => setState(() => _selectedGoal = val),
          ),
        ],
      ),
    );
  }

  // Página 3: Nivel
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
            (val) => setState(() => _selectedLevel = val),
          ),
          _buildSelectableOption(
            "Intermedio",
            Icons.star_half,
            _selectedLevel,
            (val) => setState(() => _selectedLevel = val),
          ),
          _buildSelectableOption(
            "Avanzado",
            Icons.star,
            _selectedLevel,
            (val) => setState(() => _selectedLevel = val),
          ),
        ],
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
