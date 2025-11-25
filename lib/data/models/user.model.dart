class UserProfile {
  final String id;
  final String email;
  final String name;
  final int age;
  final double weight; // en kg
  final double height; // en cm
  final String gender; // "Hombre", "Mujer" u "Otro"
  final String goal; // "Perder Peso", "Ganar Músculo", "Mantenerme"
  final String level; // "Principiante", "Intermedio", "Avanzado"
  final int currentDay;

  UserProfile({
    required this.id,
    required this.email,
    required this.name,
    required this.age,
    required this.weight,
    required this.height,
    required this.gender,
    required this.goal,
    required this.level,
    this.currentDay = 1,
  });

  // --- LÓGICA DE NEGOCIO: CÁLCULO DE CALORÍAS (MEJORA 5) ---
  int get dailyCalories {
    // 1. Tasa Metabólica Basal (Mifflin-St Jeor)
    double bmr = (10 * weight) + (6.25 * height) - (5 * age);

    // Ajuste por género
    if (gender == 'Hombre') {
      bmr += 5;
    } else {
      // Asumimos Mujer u Otro resta
      bmr -= 161;
    }

    // 2. Factor de Actividad
    double multiplier = 1.2; // Sedentario por defecto
    if (level == 'Intermedio') multiplier = 1.55;
    if (level == 'Avanzado') multiplier = 1.725;

    // 3. Ajuste según Objetivo
    double total = bmr * multiplier;

    if (goal == 'Perder Peso') return (total - 500).toInt(); // Déficit
    if (goal == 'Ganar Músculo') return (total + 300).toInt(); // Superávit

    return total.toInt(); // Mantenimiento
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'email': email,
      'name': name,
      'age': age,
      'weight': weight,
      'height': height,
      'gender': gender,
      'goal': goal,
      'level': level,
      'currentDay': currentDay,
    };
  }

  factory UserProfile.fromMap(Map<String, dynamic> map) {
    return UserProfile(
      id: map['id'] ?? '',
      email: map['email'] ?? '',
      name: map['name'] ?? '',
      age: map['age']?.toInt() ?? 0,
      weight: map['weight']?.toDouble() ?? 0.0,
      height: map['height']?.toDouble() ?? 0.0,
      gender: map['gender'] ?? 'Otro',
      goal: map['goal'] ?? 'Mantenerme',
      level: map['level'] ?? 'Principiante',
      currentDay: map['currentDay']?.toInt() ?? 1,
    );
  }
}
