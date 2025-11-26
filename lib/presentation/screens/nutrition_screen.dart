import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import '../providers/data_provider.dart';
import '../../data/datasources/food_service.dart'; // Tu servicio corregido
import '../widgets/macro_chart.dart'; // Tu widget nuevo

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});

  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  final FoodService _foodService = FoodService();
  final TextEditingController _searchController = TextEditingController();
  List<Product> _searchResults = [];
  bool _isSearching = false;

  // Variables simples para demo de macros (esto debería ir en tu Provider idealmente)
  double _carbs = 40;
  double _protein = 30;
  double _fat = 30;

  void _searchFood() async {
    if (_searchController.text.isEmpty) return;
    setState(() => _isSearching = true);

    final results = await _foodService.searchFood(_searchController.text);

    setState(() {
      _searchResults = results;
      _isSearching = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final data = Provider.of<DataProvider>(context);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : Colors.black87;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                "NUTRICIÓN INTELIGENTE",
                style: TextStyle(
                  color: Color(0xFF8B5CF6),
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),

              // --- 1. GRÁFICO DE MACROS (Estilo Fitia) ---
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark ? const Color(0xFF1E1E1E) : Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.1),
                      blurRadius: 10,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      "Resumen Diario",
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 20),
                    MacroChart(carbs: _carbs, protein: _protein, fat: _fat),
                  ],
                ),
              ),
              const SizedBox(height: 30),

              // --- 2. BUSCADOR DE ALIMENTOS (Real Data) ---
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: "Buscar alimento (ej: Manzana, Pollo)",
                  filled: true,
                  fillColor: isDark
                      ? const Color(0xFF2C2C2C)
                      : Colors.grey[100],
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _searchFood,
                  ),
                ),
                onSubmitted: (_) => _searchFood(),
              ),

              const SizedBox(height: 10),

              if (_isSearching)
                const Center(child: CircularProgressIndicator())
              else if (_searchResults.isNotEmpty)
                ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: _searchResults.length,
                  itemBuilder: (context, index) {
                    final product = _searchResults[index];
                    return ListTile(
                      leading: product.imageFrontUrl != null
                          ? Image.network(
                              product.imageFrontUrl!,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                            )
                          : const Icon(Icons.fastfood),
                      title: Text(
                        product.productName ?? "Desconocido",
                        style: TextStyle(color: textColor),
                      ),
                      subtitle: Text(
                        "${_foodService.getCalories(product).toStringAsFixed(0)} kcal / 100g",
                      ),
                      trailing: IconButton(
                        icon: const Icon(
                          Icons.add_circle,
                          color: Color(0xFF8B5CF6),
                        ),
                        onPressed: () {
                          // Aquí añadirías la lógica para sumar macros al gráfico
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text("Añadido: ${product.productName}"),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),

              const SizedBox(height: 30),
              // ... El resto de tu código original (Trackers de agua, etc.) ...
            ],
          ),
        ),
      ),
    );
  }
}
