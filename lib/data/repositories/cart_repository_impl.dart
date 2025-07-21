import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../domain/entities/cart_entity.dart';
import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/CartRepository.dart';
import '../models/cart_model.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class CartRepositoryImpl implements CartRepository {
  static const String _cartKey = 'cart_items';


  final SharedPreferences prefs;
  final http.Client httpClient;
  final Future<Map<String, CartEntity>> Function()? fetchServerCartFn;

  CartRepositoryImpl({
    required this.prefs,
    http.Client? client,
    this.fetchServerCartFn,
  }) : httpClient = client ?? http.Client();

  // Future<SharedPreferences> get _prefs async => SharedPreferences.getInstance();

  /// Load the full cart from shared preferences
  Future<Map<String, CartEntity>> _loadCart() async {
    // final prefs = await _prefs;
    final jsonString = prefs.getString(_cartKey);
    if (jsonString == null) return {};

    final decoded = json.decode(jsonString) as Map<String, dynamic>;
    return decoded.map((key, value) =>
        MapEntry(key, Carti.fromJson(value as Map<String, dynamic>)));
  }

  /// Save the full cart back to shared preferences
  Future<void> _saveCart(Map<String, CartEntity> cart) async {
    // final prefs = await _prefs;
    final encoded = json.encode(cart.map((key, value) => MapEntry(key, Carti(
      product: value.product,
      batchOrderQty: value.batchOrderQty,
      synced: value.synced,
      lastModifiedTimestamp: value.lastModifiedTimestamp,
      createdTimestamp: value.createdTimestamp,
    ).toJson())));
    await prefs.setString(_cartKey, encoded);
  }

  @override
  Future<Map<String, CartEntity>> getAllCartItems() async {
    final cart = await _loadCart();
    return cart;
  }

  @override
  Future<void> addToCart(CartEntity item) async {
    final cart = await _loadCart();
    cart[item.product.productId] = item;
    await _saveCart(cart);
  }

  @override
  Future<void> removeFromCartById(String productId) async {
    final cart = await _loadCart();
    cart.remove(productId);
    await _saveCart(cart);
  }

  @override
  Future<CartEntity?> getCartItemById(String productId) async {
    final cart = await _loadCart();
    return cart[productId];
  }

  @override
  Future<Map<String, CartEntity>> syncCart() async {

    final localCart = await getAllCartItems(); // Map<String, CartEntity>
    final serverCart = {}; //await fetchServerCart(); // Map<String, CartEntity>

    final mergedCart = <String, CartEntity>{};

    final allKeys = <String>{
      ...localCart.keys,
      ...serverCart.keys,
    };

    for (final key in allKeys) {
      final localItem = localCart[key];
      final serverItem = serverCart[key];

      if (localItem != null && serverItem != null) {
        // Both exist — compare timestamps
        if (localItem.lastModifiedTimestamp.isAfter(serverItem.lastModifiedTimestamp)) {
          mergedCart[key] = localItem;
          await uploadCartItemToServer(localItem); // Update server
        } else {
          mergedCart[key] = serverItem;
          await addToCart(serverItem); // Update local
        }
      }
      else if (localItem != null) {
        // Only local exists
        mergedCart[key] = localItem;
        await uploadCartItemToServer(localItem);
        // Mark as synced if successful
        final cart = await _loadCart();
        var copy = Carti(
            product: localItem.product,
            batchOrderQty: localItem.batchOrderQty,
            synced: true,
            lastModifiedTimestamp: localItem.lastModifiedTimestamp,
            createdTimestamp: localItem.createdTimestamp);
        cart[localItem.product.productId] = copy;
        await _saveCart(cart);

      }
      else if (serverItem != null) {
        // Only server exists
        mergedCart[key] = serverItem;
        await addToCart(serverItem);
      }
    }

    return mergedCart;
  }

  Future<void> retryWithExponentialBackoff(
      Future<void> Function() action, {
        int maxAttempts = 5,
        Duration initialDelay = const Duration(seconds: 1),
      }) async {
    int attempt = 0;
    Duration delay = initialDelay;

    while (attempt < maxAttempts) {
      try {
        await action();
        return; // Success
      } catch (e) {
        attempt++;
        if (attempt == maxAttempts) rethrow;
        await Future.delayed(delay);
        delay *= 2;
      }
    }
  }


  Future<void> uploadCartItemToServer(CartEntity item) async {
    final uri = Uri.parse('https://reqres.in/api/products'); // Fake endpoint
    final response = await http.post(
      uri,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'productId': item.product.productId,
        'productName': item.product.productName,
        'price': item.product.productBatchPrice,
        'batchOrderQty': item.batchOrderQty,
        'lastModified': item.lastModifiedTimestamp.toIso8601String(),
        'created': item.createdTimestamp.toIso8601String(),
      }),
    );

    if ( (response.statusCode / 100) != 2) {
      await retryWithExponentialBackoff(() => uploadCartItemToServer(item));
      // throw Exception('Failed to upload item. Status: ${response.statusCode}');
    }

    // Optional: log or parse response
    final jsonResp = jsonDecode(response.body);
    print('Uploaded to server: $jsonResp');
  }



}
