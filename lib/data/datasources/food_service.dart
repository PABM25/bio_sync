import 'package:openfoodfacts/openfoodfacts.dart';

class FoodService {
  Future<List<Product>> searchFood(String query) async {
    // Configuración corregida con el parámetro 'version' obligatorio
    ProductSearchQueryConfiguration configuration =
        ProductSearchQueryConfiguration(
          parametersList: <Parameter>[
            SearchTerms(terms: [query]),
            const PageSize(size: 10),
          ],
          language: OpenFoodFactsLanguage.SPANISH,
          fields: [
            ProductField.NAME,
            ProductField.NUTRIMENTS,
            ProductField.IMAGE_FRONT_URL,
          ],
          version: ProductQueryVersion.v3, // <--- ESTA ES LA LÍNEA QUE FALTABA
        );

    try {
      final SearchResult result = await OpenFoodAPIClient.searchProducts(
        null, // Pasamos null si no hay usuario autenticado en la API
        configuration,
      );

      return result.products ?? [];
    } catch (e) {
      print("Error buscando comida: $e");
      return [];
    }
  }

  double getCalories(Product product) {
    return product.nutriments?.getValue(Nutrient.energyKCal, PerSize.serving) ??
        product.nutriments?.getValue(
          Nutrient.energyKCal,
          PerSize.oneHundredGrams,
        ) ??
        0.0;
  }
}
