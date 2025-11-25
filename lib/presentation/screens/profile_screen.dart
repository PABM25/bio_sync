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
  final _nameController = TextEditingController();
  final _weightController = TextEditingController();
  final _heightController = TextEditingController();
  final _ageController = TextEditingController();
  String _selectedGoal = "Perder Peso";
  bool _isEditing = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadUserData());
  }

  void _loadUserData() {
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final dataProvider = Provider.of<DataProvider>(context, listen: false);
    final user = authProvider.userProfile;

    setState(() {
      if (user != null) {
        // Datos de Firebase
        _nameController.text = user.name;
        _weightController.text = user.weight.toString();
        _heightController.text = user.height.toString();
        _ageController.text = user.age.toString();
        _selectedGoal = user.goal;
      } else {
        // Datos Locales (Fallback)
        _nameController.text = dataProvider.userName;
        _ageController.text = dataProvider.userAge.toString();
        _weightController.text = "70.0"; // Valores por defecto si falla todo
        _heightController.text = "170.0";
      }
    });
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

            _buildField("Nombre", _nameController, Icons.person, false),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: _buildField("Edad", _ageController, Icons.cake, true),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildField(
                    "Peso (kg)",
                    _weightController,
                    Icons.monitor_weight,
                    true,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildField("Altura (cm)", _heightController, Icons.height, true),
            const SizedBox(height: 24),

            // Selector de Meta
            DropdownButtonFormField<String>(
              value:
                  [
                    "Perder Peso",
                    "Ganar Músculo",
                    "Mantenerme Activo",
                    "Mantenerme",
                  ].contains(_selectedGoal)
                  ? _selectedGoal
                  : "Perder Peso",
              items: [
                "Perder Peso",
                "Ganar Músculo",
                "Mantenerme Activo",
                "Mantenerme",
              ].map((g) => DropdownMenuItem(value: g, child: Text(g))).toList(),
              onChanged: _isEditing
                  ? (val) => setState(() => _selectedGoal = val!)
                  : null,
              decoration: InputDecoration(
                labelText: "Meta Actual",
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                filled: true,
                fillColor: _isEditing ? Colors.white : Colors.grey[100],
              ),
            ),

            const SizedBox(height: 40),
            if (_isLoading) const CircularProgressIndicator(),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await authProvider.logout();
                  if (mounted)
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (r) => false,
                    );
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  "Cerrar Sesión",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    TextEditingController ctrl,
    IconData icon,
    bool isNum,
  ) {
    return TextField(
      controller: ctrl,
      enabled: _isEditing,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(
          icon,
          color: _isEditing ? const Color(0xFF8B5CF6) : Colors.grey,
        ),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: _isEditing ? Colors.white : Colors.grey[100],
      ),
    );
  }

  void _toggleEdit(AuthProvider auth, DataProvider data) async {
    if (_isEditing) {
      setState(() => _isLoading = true);
      final newProfile = UserProfile(
        id: auth.user?.uid ?? '',
        email: auth.user?.email ?? '',
        name: _nameController.text,
        age: int.tryParse(_ageController.text) ?? 30,
        weight: double.tryParse(_weightController.text) ?? 70.0,
        height: double.tryParse(_heightController.text) ?? 170.0,
        gender: auth.userProfile?.gender ?? "Otro",
        goal: _selectedGoal,
        level: auth.userProfile?.level ?? "Intermedio",
      );

      await auth.saveUserProfile(newProfile);
      // Actualizamos también el data provider local
      data.setUserData(
        newProfile.name,
        newProfile.goal,
        newProfile.level,
        newProfile.age,
      );

      setState(() => _isLoading = false);
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text("Perfil actualizado")));
    }
    setState(() => _isEditing = !_isEditing);
  }
}
