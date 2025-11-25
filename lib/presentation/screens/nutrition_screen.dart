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

    // Formato de fecha
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
              // Header con Fecha
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

              // Barra de Búsqueda
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    icon: Icon(Icons.search, color: Colors.grey),
                    hintText: 'Buscar comidas...',
                    border: InputBorder.none,
                  ),
                ),
              ),
              const SizedBox(height: 30),

              // Tira de Calendario (Estática)
              SizedBox(
                height: 80,
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: 7,
                  itemBuilder: (context, index) {
                    final isActive =
                        index == 3; // Simulamos que hoy es el activo
                    final days = [
                      'Lun',
                      'Mar',
                      'Mié',
                      'Jue',
                      'Vie',
                      'Sáb',
                      'Dom',
                    ];
                    return Container(
                      margin: const EdgeInsets.only(right: 12),
                      width: 60,
                      decoration: BoxDecoration(
                        color: isActive
                            ? const Color(0xFF8B5CF6)
                            : Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isActive
                              ? Colors.transparent
                              : Colors.grey.shade200,
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            '${10 + index}',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: isActive ? Colors.white : Colors.black,
                            ),
                          ),
                          Text(
                            days[index],
                            style: TextStyle(
                              fontSize: 14,
                              color: isActive ? Colors.white70 : Colors.grey,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 30),

              // Sección "Menú de Hoy"
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
                const SizedBox(height: 12),
                // Dato simulado de calorías
                Row(
                  children: [
                    Icon(
                      Icons.local_fire_department,
                      size: 16,
                      color: Colors.grey[400],
                    ),
                    const SizedBox(width: 4),
                    Text(
                      "~450 Kcal",
                      style: TextStyle(color: Colors.grey[600], fontSize: 12),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
