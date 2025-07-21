import '../entities/cart_entity.dart';

/// Abstract contract for accessing cart data
abstract class CartRepository {
  /// Fetch all products in the cart
  Future<Map<String, CartEntity>> getAllCartItems();

  /// Add or update a product in the cart
  Future<void> addToCart(CartEntity cartItem);

  /// Remove a product from the cart by product ID
  Future<void> removeFromCartById(String productId);

  /// Get a product in the cart by product ID
  Future<CartEntity?> getCartItemById(String productId);

  /// Sync the cart with server and merge based on lastModifiedTimestamp
  Future<Map<String, CartEntity>> syncCart();

}
