import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../data/models/user.model.dart'; // Asegúrate que la ruta sea correcta
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';
import 'main_layout.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});
  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _page = 0;

  // Controladores
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _ageController = TextEditingController();
  final TextEditingController _weightController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();

  String _selectedGoal = "Perder Peso";
  String _selectedLevel = "Intermedio";
  bool _isSaving = false; // Para evitar doble clic

  @override
  Widget build(BuildContext context) {
    // Definimos las páginas según tus imágenes
    final List<Widget> pages = [
      _buildNamePage(),
      _buildAgePage(),
      _buildWeightHeightPage(), // Página combinada o separada
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
                  physics:
                      const NeverScrollableScrollPhysics(), // Bloqueamos swipe manual para obligar a usar botón
                  onPageChanged: (p) => setState(() => _page = p),
                  children: pages,
                ),
              ),

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
                  onPressed: _isSaving
                      ? null
                      : () {
                          if (_page < pages.length - 1) {
                            _pageController.nextPage(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.ease,
                            );
                          } else {
                            _finishOnboarding();
                          }
                        },
                  child: _isSaving
                      ? const CircularProgressIndicator()
                      : Text(
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

  Future<void> _finishOnboarding() async {
    setState(() => _isSaving = true);

    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      final dataProvider = Provider.of<DataProvider>(context, listen: false);

      // Recolectar datos
      String name = _nameController.text.trim().isEmpty
          ? "Atleta"
          : _nameController.text.trim();
      int age = int.tryParse(_ageController.text) ?? 30;
      double weight = double.tryParse(_weightController.text) ?? 70.0;
      double height = double.tryParse(_heightController.text) ?? 170.0;

      // 1. Crear Objeto Perfil
      final newProfile = UserProfile(
        id: authProvider.user?.uid ?? '',
        email: authProvider.user?.email ?? '',
        name: name,
        age: age,
        weight: weight,
        height: height,
        gender: "Otro", // Puedes agregar pantalla de género si quieres
        goal: _selectedGoal,
        level: _selectedLevel,
      );

      // 2. Guardar en Firebase (Esto desbloquea el MainLayout en AuthWrapper)
      await authProvider.saveUserProfile(newProfile);

      // 3. Guardar en Local (Para uso rápido en ejercicios)
      await dataProvider.setUserData(name, _selectedGoal, _selectedLevel, age);

      // Navegar al MainLayout
      if (mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainLayout()),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Error al guardar: $e")));
      setState(() => _isSaving = false);
    }
  }

  // --- Widgets de las Páginas ---

  Widget _buildNamePage() {
    return _buildPageBase(
      icon: Icons.person,
      title: "Bienvenido",
      subtitle: "¿Cómo te llamas?",
      child: TextField(
        controller: _nameController,
        decoration: _inputDecor("Tu nombre"),
      ),
    );
  }

  Widget _buildAgePage() {
    return _buildPageBase(
      icon: Icons.cake,
      title: "¿Cuántos años tienes?",
      subtitle: "Para adaptar tus ejercicios",
      child: TextField(
        controller: _ageController,
        keyboardType: TextInputType.number,
        decoration: _inputDecor("Ej: 25"),
      ),
    );
  }

  Widget _buildWeightHeightPage() {
    return _buildPageBase(
      icon: Icons.monitor_weight,
      title: "Medidas Corporales",
      subtitle: "Para calcular tus calorías",
      child: Column(
        children: [
          TextField(
            controller: _weightController,
            keyboardType: TextInputType.number,
            decoration: _inputDecor("Peso (kg)"),
          ),
          const SizedBox(height: 15),
          TextField(
            controller: _heightController,
            keyboardType: TextInputType.number,
            decoration: _inputDecor("Altura (cm)"),
          ),
        ],
      ),
    );
  }

  Widget _buildGoalPage() {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Tu Objetivo",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 30),
          _option(
            "Perder Peso",
            Icons.trending_down,
            _selectedGoal,
            (v) => setState(() => _selectedGoal = v),
          ),
          _option(
            "Ganar Músculo",
            Icons.fitness_center,
            _selectedGoal,
            (v) => setState(() => _selectedGoal = v),
          ),
          _option(
            "Mantenerme",
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
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            "Nivel de Actividad",
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 30),
          _option(
            "Principiante",
            Icons.star_border,
            _selectedLevel,
            (v) => setState(() => _selectedLevel = v),
          ),
          _option(
            "Intermedio",
            Icons.star_half,
            _selectedLevel,
            (v) => setState(() => _selectedLevel = v),
          ),
          _option(
            "Avanzado",
            Icons.star,
            _selectedLevel,
            (v) => setState(() => _selectedLevel = v),
          ),
        ],
      ),
    );
  }

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
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
    );
  }

  Widget _option(
    String title,
    IconData icon,
    String groupValue,
    Function(String) onTap,
  ) {
    bool selected = title == groupValue;
    return GestureDetector(
      onTap: () => onTap(title),
      child: Container(
        margin: const EdgeInsets.only(bottom: 15),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          border: selected
              ? Border.all(color: const Color(0xFF8B5CF6), width: 3)
              : null,
        ),
        child: Row(
          children: [
            Icon(icon, color: selected ? const Color(0xFF8B5CF6) : Colors.grey),
            const SizedBox(width: 15),
            Text(
              title,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: selected ? const Color(0xFF8B5CF6) : Colors.black87,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
