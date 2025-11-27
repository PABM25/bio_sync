import 'package:flutter/material.dart';
import 'package:openfoodfacts/openfoodfacts.dart';
import 'package:percent_indicator/linear_percent_indicator.dart';
import 'package:simple_barcode_scanner/simple_barcode_scanner.dart';
import '../../data/datasources/food_service.dart';
import '../widgets/macro_chart.dart';

class NutritionScreen extends StatefulWidget {
  const NutritionScreen({super.key});
  @override
  State<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends State<NutritionScreen> {
  double _consumedCalories = 0;
  final double _targetCalories = 2200;
  double _carbs = 0, _protein = 0, _fat = 0;
  List<Product> _breakfast = [], _lunch = [], _dinner = [];
  final FoodService _foodService = FoodService();

  void _openSearchModal(String mealType) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.9,
        builder: (_, controller) => _SearchFoodModal(
          scrollController: controller,
          foodService: _foodService,
          onAdd: (product) {
            setState(() {
              _consumedCalories += _foodService.getCalories(product);
              _carbs +=
                  product.nutriments?.getValue(
                    Nutrient.carbohydrates,
                    PerSize.serving,
                  ) ??
                  10;
              _protein +=
                  product.nutriments?.getValue(
                    Nutrient.proteins,
                    PerSize.serving,
                  ) ??
                  5;
              _fat +=
                  product.nutriments?.getValue(Nutrient.fat, PerSize.serving) ??
                  2;
              if (mealType == 'Desayuno') _breakfast.add(product);
              if (mealType == 'Almuerzo') _lunch.add(product);
              if (mealType == 'Cena') _dinner.add(product);
            });
            Navigator.pop(context);
          },
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "${_consumedCalories.toInt()} / ${_targetCalories.toInt()}",
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Text(
                          "Kcal Consumidas",
                          style: TextStyle(color: Colors.grey),
                        ),
                        LinearPercentIndicator(
                          lineHeight: 12.0,
                          percent: (_consumedCalories / _targetCalories).clamp(
                            0.0,
                            1.0,
                          ),
                          progressColor: const Color(0xFF8B5CF6),
                          barRadius: const Radius.circular(10),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    width: 100,
                    height: 100,
                    child: MacroChart(
                      carbs: _carbs,
                      protein: _protein,
                      fat: _fat,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              _buildMealSection("Desayuno", _breakfast, isDark),
              _buildMealSection("Almuerzo", _lunch, isDark),
              _buildMealSection("Cena", _dinner, isDark),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMealSection(String title, List<Product> foods, bool isDark) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            IconButton(
              icon: const Icon(Icons.add_circle, color: Color(0xFF8B5CF6)),
              onPressed: () => _openSearchModal(title),
            ),
          ],
        ),
        if (foods.isEmpty)
          const Text("Sin alimentos", style: TextStyle(color: Colors.grey))
        else
          ...foods.map(
            (f) => ListTile(
              title: Text(f.productName ?? "Comida"),
              subtitle: Text("${_foodService.getCalories(f).toInt()} kcal"),
            ),
          ),
        const Divider(),
      ],
    );
  }
}

class _SearchFoodModal extends StatefulWidget {
  final ScrollController scrollController;
  final FoodService foodService;
  final Function(Product) onAdd;
  const _SearchFoodModal({
    required this.scrollController,
    required this.foodService,
    required this.onAdd,
  });
  @override
  State<_SearchFoodModal> createState() => _SearchFoodModalState();
}

class _SearchFoodModalState extends State<_SearchFoodModal> {
  final TextEditingController _controller = TextEditingController();
  List<Product> _results = [];
  bool _loading = false;

  void _search() async {
    if (_controller.text.isEmpty) return;
    setState(() => _loading = true);
    final res = await widget.foodService.searchFood(_controller.text);
    setState(() {
      _results = res;
      _loading = false;
    });
  }

  void _scanBarcode() async {
    var res = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SimpleBarcodeScannerPage()),
    );
    if (res is String && res != '-1') {
      setState(() => _loading = true);
      final product = await widget.foodService.getProductByBarcode(res);
      setState(() => _loading = false);
      if (product != null) widget.onAdd(product);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(20),
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: "Buscar o escanear...",
                suffixIcon: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.qr_code_scanner),
                      onPressed: _scanBarcode,
                    ),
                    IconButton(
                      icon: const Icon(Icons.search),
                      onPressed: _search,
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : ListView.builder(
                    controller: widget.scrollController,
                    itemCount: _results.length,
                    itemBuilder: (ctx, i) {
                      final p = _results[i];
                      return ListTile(
                        leading: p.imageFrontUrl != null
                            ? Image.network(p.imageFrontUrl!, width: 40)
                            : const Icon(Icons.fastfood),
                        title: Text(p.productName ?? "Sin nombre"),
                        subtitle: Text(
                          "${widget.foodService.getCalories(p).toInt()} kcal",
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.add, color: Colors.green),
                          onPressed: () => widget.onAdd(p),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
