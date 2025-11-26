import 'dart:math' as math;

class UserProfile {
  final String id;
  final String email;
  final String name;
  final int age;
  final double weight; // kg
  final double height; // cm
  final String gender; // "Hombre", "Mujer"
  final String goal; // "Perder Peso", "Ganar Músculo", "Mantenerme"
  final String level; // "Principiante", "Intermedio", "Avanzado"
  final int currentDay;

  // Nuevos campos para mayor precisión (Opcionales)
  final double? neck; // Cuello en cm
  final double? waist; // Cintura en cm
  final double? hip; // Cadera en cm (Solo mujeres)

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
    this.neck,
    this.waist,
    this.hip,
  });

  // --- 1. Cálculo de Grasa Corporal (Método de la Marina de EE.UU.) ---
  double get bodyFatPercentage {
    // Valores por defecto si no hay medidas
    if (neck == null || waist == null) {
      return gender == 'Hombre' ? 18.0 : 25.0;
    }

    // Helper para logaritmo base 10
    double log10(num x) => math.log(x) / math.ln10;

    if (gender == 'Hombre') {
      return 495 /
              (1.0324 -
                  0.19077 * log10(waist! - neck!) +
                  0.15456 * log10(height)) -
          450;
    } else {
      // Mujeres necesitan cadera
      double c = hip ?? (waist! + 15); // Estimación si falta cadera
      return 495 /
              (1.29579 -
                  0.35004 * log10(waist! + c - neck!) +
                  0.22100 * log10(height)) -
          450;
    }
  }

  // --- 2. Cálculo de Calorías Exacto (Katch-McArdle) ---
  // Este método usa la Masa Magra, que es mucho más preciso que el peso total.
  int get exactDailyCalories {
    double bodyFat = bodyFatPercentage;
    // Masa Magra (LBM)
    double leanBodyMass = weight * (1 - (bodyFat / 100));

    // Tasa Metabólica Basal (BMR)
    double bmr = 370 + (21.6 * leanBodyMass);

    // Factor de Actividad
    double multiplier = 1.2;
    if (level == 'Intermedio') multiplier = 1.55;
    if (level == 'Avanzado') multiplier = 1.725;

    double tdee = bmr * multiplier;

    // Ajuste por Objetivo
    if (goal == 'Perder Peso') return (tdee * 0.80).toInt(); // Déficit 20%
    if (goal == 'Ganar Músculo') return (tdee * 1.10).toInt(); // Superávit 10%

    return tdee.toInt(); // Mantenimiento
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
      'neck': neck,
      'waist': waist,
      'hip': hip,
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
      gender: map['gender'] ?? 'Hombre',
      goal: map['goal'] ?? 'Mantenerme',
      level: map['level'] ?? 'Intermedio',
      currentDay: map['currentDay']?.toInt() ?? 1,
      neck: map['neck']?.toDouble(),
      waist: map['waist']?.toDouble(),
      hip: map['hip']?.toDouble(),
    );
  }
}
