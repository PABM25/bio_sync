import 'package:openfoodfacts/openfoodfacts.dart';

class FoodService {
  Future<List<Product>> searchFood(String query) async {
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
          version: ProductQueryVersion.v3, // CORRECCIÓN CRÍTICA
        );

    try {
      final SearchResult result = await OpenFoodAPIClient.searchProducts(
        null,
        configuration,
      );
      return result.products ?? [];
    } catch (e) {
      return [];
    }
  }

  Future<Product?> getProductByBarcode(String barcode) async {
    final ProductQueryConfiguration configuration = ProductQueryConfiguration(
      barcode,
      language: OpenFoodFactsLanguage.SPANISH,
      fields: [
        ProductField.NAME,
        ProductField.NUTRIMENTS,
        ProductField.IMAGE_FRONT_URL,
      ],
      version: ProductQueryVersion.v3,
    );
    final ProductResultV3 result = await OpenFoodAPIClient.getProductV3(
      configuration,
    );
    return result.status == ProductResultV3.statusSuccess
        ? result.product
        : null;
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
