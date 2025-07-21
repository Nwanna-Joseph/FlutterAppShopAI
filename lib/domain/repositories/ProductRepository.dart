import '../entities/product_entity.dart';

/// Abstract contract for accessing product data
abstract class ProductRepository {
  /// Fetch all products
  Future<List<ProductEntity>> getAllProducts();

  /// Add or overwrite a product
  Future<void> addProduct(ProductEntity product);

  /// Remove product by ID
  Future<void> removeProductById(String id);

  /// Get product by ID
  Future<ProductEntity?> getProductById(String id);
}
