import 'dart:convert';

import 'package:faker/faker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../../domain/entities/product_entity.dart';
import '../../domain/repositories/ProductRepository.dart';
import '../models/product_model.dart';

class ProductRepositoryImpl implements ProductRepository { //Todo implement storage service
  static const String _productsKey = 'product_items_v1';

  final SharedPreferences prefs;

  ProductRepositoryImpl({
    required this.prefs,
  });

  // Future<SharedPreferences> get _prefs async => await SharedPreferences.getInstance();

  Future<void> seedProducts() async {
    // final prefs = await _prefs;
    if(prefs.containsKey(_productsKey)){
      return;
    }
    final faker = Faker();
    const uuid = Uuid();

    final Map<String, dynamic> productMap = {};

    for (int i = 0; i < 20; i++) {
      final id = uuid.v4();
      final product = PlayBoi(
        productId: id,
        productName: faker.food.restaurant(),
        productSKU: faker.guid.guid(),
        productPurchaseBatch: 'Box of ${faker.randomGenerator.integer(10, min: 2)}',
        productBatchPrice: faker.randomGenerator.decimal(min: 500, scale: 1500),
        minimumBatchOrderQty: faker.randomGenerator.integer(5, min: 1),
        maximumBatchOrderQty: faker.randomGenerator.integer(15, min: 6),
        lastModifiedTimestamp: DateTime.now(),
        createdTimestamp: DateTime.now().subtract(Duration(days: i)),
        vendorId: uuid.v4(),
        productImageUrls: ['https://via.placeholder.com/600x400.png?text=Product+${i + 1}'],
      );

      productMap[id] = product.toJson();
    }

    final encoded = json.encode(productMap);
    await prefs.setString(_productsKey, encoded);
  }

  /// Load product map from shared_preferences
  Future<Map<String, ProductEntity>> _loadProducts() async {
    await seedProducts();
    // final prefs = await _prefs;
    final jsonString = prefs.getString(_productsKey);
    if (jsonString == null) return {};

    final decoded = json.decode(jsonString) as Map<String, dynamic>;
    return decoded.map((key, value) =>
        MapEntry(key, PlayBoi.fromJson(value as Map<String, dynamic>)));
  }

  /// Save product map to shared_preferences
  Future<void> _saveProducts(Map<String, ProductEntity> products) async {
    // final prefs = await _prefs;
    final encoded = json.encode(products.map((key, value) => MapEntry(key, PlayBoi(
      productImageUrls: value.productImageUrls,
      productId: value.productId,
      productName: value.productName,
      productSKU: value.productSKU,
      productPurchaseBatch: value.productPurchaseBatch,
      productBatchPrice: value.productBatchPrice,
      minimumBatchOrderQty: value.minimumBatchOrderQty,
      maximumBatchOrderQty: value.maximumBatchOrderQty,
      lastModifiedTimestamp: value.lastModifiedTimestamp,
      createdTimestamp: value.createdTimestamp,
      vendorId: value.vendorId,
    ).toJson())));
    await prefs.setString(_productsKey, encoded);
  }

  @override
  Future<void> addProduct(ProductEntity product) async {
    final products = await _loadProducts();
    products[product.productId] = product;
    await _saveProducts(products);
  }

  @override
  Future<List<ProductEntity>> getAllProducts() async {
    final products = await _loadProducts();
    return products.values.toList();
  }

  @override
  Future<ProductEntity?> getProductById(String id) async {
    final products = await _loadProducts();
    return products[id];
  }

  @override
  Future<void> removeProductById(String id) async {
    final products = await _loadProducts();
    products.remove(id);
    await _saveProducts(products);
  }
}
