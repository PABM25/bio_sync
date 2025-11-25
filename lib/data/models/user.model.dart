class UserProfile {
  final String id;
  final String email;
  final String name;
  final int age;
  final double weight; // en kg
  final double height; // en cm
  final String gender; // "Hombre", "Mujer"
  final String goal; // "Perder Peso", etc.
  final String level; // "Principiante", etc.

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
  });

  // Convertir a Mapa para guardar en Firebase
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
    };
  }

  // Crear objeto desde Firebase
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
    );
  }
}
