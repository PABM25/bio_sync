import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/data_provider.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<DataProvider>(context);
    final dieta = data.dietaHoy;

    final now = DateTime.now();
    final dayName = DateFormat('EEEE', 'es_ES').format(now);
    final dateStr = DateFormat('d MMMM yyyy', 'es_ES').format(now);

    if (data.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Colors.grey[50],
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                dayName.toUpperCase(),
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                dateStr,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 20),

              // --- NUEVO: TRACKER DE HIDRATACIÓN ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.blue.withOpacity(0.3)),
                ),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.water_drop, color: Colors.blue),
                            SizedBox(width: 10),
                            Text(
                              "Hidratación",
                              style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.blue,
                              ),
                            ),
                          ],
                        ),
                        Text(
                          "${data.waterGlasses}/8 Vasos",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        // Botón pequeño para resetear si se equivocan
                        if (data.waterGlasses > 0)
                          GestureDetector(
                            onTap: () => data.resetWater(),
                            child: const Icon(
                              Icons.refresh,
                              size: 18,
                              color: Colors.grey,
                            ),
                          ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(8, (index) {
                        return GestureDetector(
                          onTap: () => data.drinkWater(),
                          child: Icon(
                            index < data.waterGlasses
                                ? Icons.local_drink
                                : Icons.local_drink_outlined,
                            color: Colors.blue,
                            size: 30,
                          ),
                        );
                      }),
                    ),
                    const SizedBox(height: 10),
                    if (data.waterGlasses >= 8)
                      const Text(
                        "¡Meta cumplida! 🎉",
                        style: TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                      )
                    else
                      const Text(
                        "Toca los vasos para registrar",
                        style: TextStyle(color: Colors.grey, fontSize: 12),
                      ),
                  ],
                ),
              ),

              // -------------------------------------
              const SizedBox(height: 30),

              const Text(
                "Tu Menú de Hoy",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              if (dieta != null) ...[
                SizedBox(
                  height: 260,
                  child: ListView(
                    scrollDirection: Axis.horizontal,
                    clipBehavior: Clip.none,
                    children: [
                      _buildModernMealCard(
                        "Desayuno",
                        dieta.comidas.desayuno,
                        Icons.breakfast_dining,
                        Colors.orange,
                      ),
                      _buildModernMealCard(
                        "Almuerzo",
                        dieta.comidas.almuerzo,
                        Icons.lunch_dining,
                        Colors.green,
                      ),
                      _buildModernMealCard(
                        "Cena",
                        dieta.comidas.cena,
                        Icons.dinner_dining,
                        Colors.blueGrey,
                      ),
                      _buildModernMealCard(
                        "Colación",
                        dieta.comidas.colacion,
                        Icons.apple,
                        Colors.redAccent,
                      ),
                    ],
                  ),
                ),
              ] else
                const Center(child: Text("No hay datos para hoy")),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildModernMealCard(
    String mealType,
    String foodName,
    IconData icon,
    Color color,
  ) {
    return Container(
      width: 200,
      margin: const EdgeInsets.only(right: 16, bottom: 10),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 15,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            height: 120,
            decoration: BoxDecoration(
              color: color.withOpacity(0.2),
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(24),
                topRight: Radius.circular(24),
              ),
            ),
            child: Center(child: Icon(icon, size: 50, color: color)),
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  mealType,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  foodName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
