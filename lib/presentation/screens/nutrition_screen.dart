import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/data_provider.dart';

class NutritionScreen extends StatelessWidget {
  const NutritionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final dataProvider = Provider.of<DataProvider>(context);
    final plan = dataProvider.nutritionalPlan;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (plan.isEmpty) {
      return const Center(child: CircularProgressIndicator());
    }

    final info = plan['info_profesional'];
    final req = plan['requerimiento_nutricional_diario'];
    final indicaciones = plan['indicaciones_generales'] as List;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("Mi Pauta Nutricional"),
        centerTitle: false,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Tarjeta de Información Profesional
            _buildInfoCard(context, info, req, isDark),
            const SizedBox(height: 20),

            // Indicaciones Generales
            const Text(
              "Indicaciones",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...indicaciones.map((ind) => _buildIndicationTile(ind, isDark)),

            const SizedBox(height: 25),

            // Menú Semanal (Expansion Tiles)
            const Text(
              "Menú Semanal",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            ...dataProvider.menuSemanal.map(
              (dia) => _buildDayTile(dia, isDark),
            ),

            const SizedBox(height: 40),
            Center(
              child: Text(
                "Registra tu consumo en Fitia",
                style: TextStyle(
                  color: Colors.grey[600],
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(BuildContext context, Map info, Map req, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF4A148C), const Color(0xFF7B1FA2)]
              : [const Color(0xFF8B5CF6), const Color(0xFFA78BFA)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.medical_services_outlined,
                color: Colors.white,
                size: 30,
              ),
              const SizedBox(width: 15),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      info['nombre'],
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    Text(
                      info['titulo'],
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const Divider(color: Colors.white24, height: 30),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildMacroItem("Calorías", "${req['calorias_totales']}"),
              _buildMacroItem(
                "Proteínas",
                "${req['macronutrientes']['proteinas']['gramos']}g",
              ),
              _buildMacroItem(
                "Carbos",
                "${req['macronutrientes']['carbohidratos']['gramos']}g",
              ),
              _buildMacroItem(
                "Grasas",
                "${req['macronutrientes']['lipidos']['gramos']}g",
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildMacroItem(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: 16,
          ),
        ),
        Text(
          label,
          style: const TextStyle(color: Colors.white70, fontSize: 12),
        ),
      ],
    );
  }

  Widget _buildIndicationTile(String text, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.check_circle_outline,
            color: Color(0xFF8B5CF6),
            size: 20,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: isDark ? Colors.grey[300] : Colors.grey[800],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDayTile(dynamic diaPlan, bool isDark) {
    return Card(
      elevation: 0,
      color: isDark ? const Color(0xFF2C2C2C) : Colors.grey[100],
      margin: const EdgeInsets.only(bottom: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: ExpansionTile(
        title: Text(
          diaPlan.dia,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF8B5CF6),
          ),
        ),
        childrenPadding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
        children: [
          _buildMealRow("Desayuno", diaPlan.comidas.desayuno, isDark),
          _buildMealRow("Almuerzo", diaPlan.comidas.almuerzo, isDark),
          _buildMealRow("Colación", diaPlan.comidas.colacion, isDark),
          _buildMealRow("Cena", diaPlan.comidas.cena, isDark),
        ],
      ),
    );
  }

  Widget _buildMealRow(String label, String food, bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 70,
            child: Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
                color: isDark ? Colors.grey[400] : Colors.grey[700],
              ),
            ),
          ),
          Expanded(
            child: Text(
              food,
              style: TextStyle(
                fontSize: 14,
                color: isDark ? Colors.white : Colors.black87,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
