import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../providers/data_provider.dart';
import '../providers/theme_provider.dart';
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
  String _selectedGender = "Hombre"; // <---
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
        _nameController.text = user.name;
        _weightController.text = user.weight.toString();
        _heightController.text = user.height.toString();
        _ageController.text = user.age.toString();
        _selectedGoal = user.goal;
        _selectedGender = user.gender; // <---
      } else {
        _nameController.text = dataProvider.userName;
        _ageController.text = dataProvider.userAge.toString();
        _selectedGender = dataProvider.userGender; // <---
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = Provider.of<AuthProvider>(context);
    final dataProvider = Provider.of<DataProvider>(context);
    final themeProvider = Provider.of<ThemeProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? const Color(0xFF1E1E1E) : Colors.white;
    final textColor = isDark ? Colors.white : Colors.black87;

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
            // ... (Avatar e Info Email igual que antes)
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
            const SizedBox(height: 20),

            // Switch Tema
            Container(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withOpacity(0.1)),
              ),
              child: SwitchListTile(
                title: Text(
                  "Modo Oscuro",
                  style: TextStyle(
                    color: textColor,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                secondary: Icon(
                  themeProvider.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                  color: const Color(0xFF8B5CF6),
                ),
                value: themeProvider.isDarkMode,
                activeThumbColor: const Color(0xFF8B5CF6),
                onChanged: (val) => themeProvider.toggleTheme(val),
              ),
            ),
            const SizedBox(height: 32),

            _buildField("Nombre", _nameController, Icons.person, false, isDark),
            const SizedBox(height: 16),

            // Nuevo Dropdown de Género
            DropdownButtonFormField<String>(
              dropdownColor: cardColor,
              initialValue:
                  ["Hombre", "Mujer", "Otro"].contains(_selectedGender)
                  ? _selectedGender
                  : "Hombre",
              items: ["Hombre", "Mujer", "Otro"]
                  .map(
                    (g) => DropdownMenuItem(
                      value: g,
                      child: Text(g, style: TextStyle(color: textColor)),
                    ),
                  )
                  .toList(),
              onChanged: _isEditing
                  ? (val) => setState(() => _selectedGender = val!)
                  : null,
              decoration: _inputDecor("Género", isDark, _isEditing),
            ),
            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: _buildField(
                    "Edad",
                    _ageController,
                    Icons.cake,
                    true,
                    isDark,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildField(
                    "Peso (kg)",
                    _weightController,
                    Icons.monitor_weight,
                    true,
                    isDark,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildField(
              "Altura (cm)",
              _heightController,
              Icons.height,
              true,
              isDark,
            ),
            const SizedBox(height: 24),

            DropdownButtonFormField<String>(
              dropdownColor: cardColor,
              initialValue: _selectedGoal,
              items: ["Perder Peso", "Ganar Músculo", "Mantenerme"]
                  .map(
                    (g) => DropdownMenuItem(
                      value: g,
                      child: Text(g, style: TextStyle(color: textColor)),
                    ),
                  )
                  .toList(),
              onChanged: _isEditing
                  ? (val) => setState(() => _selectedGoal = val!)
                  : null,
              decoration: _inputDecor("Meta Actual", isDark, _isEditing),
            ),

            const SizedBox(height: 30),

            // Tarjeta Calorías (Igual que antes)
            if (authProvider.userProfile != null)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [const Color(0xFF2C2C2C), const Color(0xFF1E1E1E)]
                        : [
                            const Color(0xFF8B5CF6).withOpacity(0.1),
                            Colors.white,
                          ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF8B5CF6).withOpacity(0.3),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      "${authProvider.userProfile!.exactDailyCalories} Kcal",
                      style: const TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF8B5CF6),
                      ),
                    ),
                    const Text(
                      "Meta Diaria",
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                  ],
                ),
              ),

            const SizedBox(height: 40),
            if (_isLoading) const CircularProgressIndicator(),

            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () async {
                  await dataProvider.clearLocalData();
                  await authProvider.logout();
                  if (mounted) {
                    Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(builder: (_) => const LoginScreen()),
                      (r) => false,
                    );
                  }
                },
                icon: const Icon(Icons.logout, color: Colors.red),
                label: const Text(
                  "Cerrar Sesión",
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ),
            const SizedBox(height: 20),
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
    bool isDark,
  ) {
    return TextField(
      controller: ctrl,
      enabled: _isEditing,
      keyboardType: isNum ? TextInputType.number : TextInputType.text,
      style: TextStyle(color: isDark ? Colors.white : Colors.black87),
      decoration: _inputDecor(label, isDark, _isEditing, icon: icon),
    );
  }

  InputDecoration _inputDecor(
    String label,
    bool isDark,
    bool enabled, {
    IconData? icon,
  }) {
    return InputDecoration(
      labelText: label,
      labelStyle: TextStyle(color: isDark ? Colors.grey : Colors.black54),
      prefixIcon: icon != null
          ? Icon(icon, color: enabled ? const Color(0xFF8B5CF6) : Colors.grey)
          : null,
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      filled: true,
      fillColor: enabled
          ? (isDark ? const Color(0xFF2C2C2C) : Colors.white)
          : (isDark ? const Color(0xFF121212) : Colors.grey[100]),
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
        gender: _selectedGender, // <--- Guardar Género Editado
        goal: _selectedGoal,
        level: auth.userProfile?.level ?? "Intermedio",
      );

      await auth.saveUserProfile(newProfile);
      data.setUserData(
        newProfile.name,
        newProfile.goal,
        newProfile.level,
        newProfile.age,
        newProfile.gender,
      );
      setState(() => _isLoading = false);
    }
    setState(() => _isEditing = !_isEditing);
  }
}
