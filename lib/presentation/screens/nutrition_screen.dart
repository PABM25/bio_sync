import 'package:flutter/material.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF3F4F6),
      appBar: AppBar(
        title: const Text("Nutrición"),
        automaticallyImplyLeading: false,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _mealCard("Desayuno", "Avena con frutas", "350 kcal"),
          _mealCard("Almuerzo", "Pollo con arroz", "650 kcal"),
          _mealCard("Cena", "Ensalada de atún", "250 kcal"),
        ],
      ),
    );
  }

  Widget _mealCard(String title, String food, String cals) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: Colors.green.withOpacity(0.1),
            shape: BoxShape.circle,
          ),
          child: const Icon(Icons.restaurant, color: Colors.green),
        ),
        title: Text(
          title,
          style: const TextStyle(fontSize: 14, color: Colors.grey),
        ),
        subtitle: Text(
          food,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        trailing: Text(
          cals,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    );
  }
}
