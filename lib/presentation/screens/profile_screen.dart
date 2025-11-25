import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';
import '../../data/models/user.model.dart';
import 'auth/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  // Controladores para la edición
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  String _selectedGoal = "Mantenerme";
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    // Cargar datos iniciales al entrar a la pantalla
    _loadUserData();
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final user = authProvider.userProfile;

    // Si el usuario viene de Firebase
    if (user != null) {
      _nameController.text = user.name;
      _weightController.text = user.weight.toString();
      _heightController.text = user.height.toString();
      _ageController.text = user.age.toString();
      _selectedGoal = user.goal;
    } else {
      // Si no (por ejemplo, recién registrado o datos locales del DataProvider)
      final dataProvider = Provider.of<DataProvider>(context, listen: false);
      _nameController.text = dataProvider.userName;
      _ageController.text = dataProvider.userAge.toString();
      // Peso y altura podrían no estar en DataProvider simple, los dejamos vacíos o default
    }
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "Mi Perfil",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isEditing ? Icons.save : Icons.edit,
              color: const Color(0xFF8B5CF6),
            ),
            onPressed: () => _toggleEdit(authProvider, dataProvider),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          children: [
            // Avatar
            const CircleAvatar(
              radius: 50,
              backgroundColor: Color(0xFFEADDFF),
              child: Icon(Icons.person, size: 50, color: Color(0xFF8B5CF6)),
            ),
            const SizedBox(height: 16),
            Text(
              authProvider.user?.email ?? "usuario@biosync.com",
              style: TextStyle(color: Colors.grey[600]),
            ),
            const SizedBox(height: 32),

            // Campos de Datos
            _buildProfileField(
              "Nombre",
              _nameController,
              icon: Icons.person_outline,
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildProfileField(
                    "Edad",
                    _ageController,
                    icon: Icons.cake,
                    isNumber: true,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildProfileField(
                    "Peso (kg)",
                    _weightController,
                    icon: Icons.monitor_weight_outlined,
                    isNumber: true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildProfileField(
              "Altura (cm)",
              _heightController,
              icon: Icons.height,
              isNumber: true,
            ),

            const SizedBox(height: 24),

            // Selector de Meta (Solo visible si edita o como texto si no)
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                "Meta Actual",
                style: TextStyle(color: Colors.grey[600], fontSize: 14),
              ),
            ),
            const SizedBox(height: 8),
            _isEditing
                ? _buildGoalSelector()
                : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.grey.shade200),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.flag, color: Color(0xFF8B5CF6)),
                        const SizedBox(width: 12),
                        Text(
                          _selectedGoal,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),

            const SizedBox(height: 40),

            // Botón Cerrar Sesión
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await authProvider.logout();
                  // Navegar al login removiendo todo lo anterior
                  if (mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (route) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  "Cerrar Sesión",
                  style: TextStyle(color: Colors.red),
                ),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: const BorderSide(color: Colors.red),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProfileField(
    String label,
    TextEditingController controller, {
    required IconData icon,
    bool isNumber = false,
  }) {
    return TextField(
      controller: controller,
      enabled: _isEditing,
      keyboardType: isNumber ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: _isEditing ? const Color(0xFF8B5CF6) : Colors.grey,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: _isEditing ? Colors.white : Colors.grey[100],
        disabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.grey.shade200),
        ),
      ),
    );
  }

  Widget _buildGoalSelector() {
    final goals = ["Perder Peso", "Ganar Músculo", "Mantenerme Activo"];
    return DropdownButtonFormField<String>(
      value: goals.contains(_selectedGoal) ? _selectedGoal : goals.first,
      items: goals
          .map((g) => DropdownMenuItem(value: g, child: Text(g)))
          .toList(),
      onChanged: (val) => setState(() => _selectedGoal = val!),
      decoration: InputDecoration(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white,
      ),
    );
  }

  void _toggleEdit(AuthProvider auth, DataProvider data) async {
    if (_isEditing) {
      // GUARDAR CAMBIOS
      final newProfile = UserProfile(
        id: auth.user?.uid ?? '',
        email: auth.user?.email ?? '',
        name: _nameController.text,
        age: int.tryParse(_ageController.text) ?? 0,
        weight: double.tryParse(_weightController.text) ?? 0.0,
        height: double.tryParse(_heightController.text) ?? 0.0,
        gender:
            auth.userProfile?.gender ??
            'Otro', // Mantenemos el que estaba o default
        goal: _selectedGoal,
        level: data.userLevel, // Usamos el del DataProvider o el guardado
      );

      // 1. Guardar en Firebase
      await auth.saveUserProfile(newProfile);

      // 2. Actualizar DataProvider (para que la app reaccione rápido, ej: edad para ejercicios)
      // Nota: setUserData en DataProvider actualmente no recibe peso/altura,
      // podrías expandirlo si quieres usar esos datos en la lógica local.
      data.setUserData(
        newProfile.name,
        newProfile.goal,
        newProfile.level,
        newProfile.age,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("¡Perfil actualizado correctamente! ✅")),
      );
    }

    setState(() {
      _isEditing = !_isEditing;
    });
  }
}
