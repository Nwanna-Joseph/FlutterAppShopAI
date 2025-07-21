import 'dart:convert';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:shopai/data/repositories/cart_repository_impl.dart';
import 'package:shopai/domain/entities/cart_entity.dart';
import 'package:shopai/domain/entities/product_entity.dart';

class MockSharedPreferences extends Mock implements SharedPreferences {}
class MockHttpClient extends Mock implements http.Client {}

void main() {
  late MockSharedPreferences mockPrefs;
  late MockHttpClient mockHttpClient;
  late CartRepositoryImpl repo;

  const fakeKey = 'cart_items';

  final testProduct = ProductEntity(
    productImageUrls: [],
    productId: "product23323",
    productName: "Oven",
    productSKU: "oven_",
    productPurchaseBatch: "5",
    productBatchPrice: 543.4,
    minimumBatchOrderQty: 2,
    maximumBatchOrderQty: 5,
    lastModifiedTimestamp: DateTime.now(),
    createdTimestamp: DateTime.now(),
    vendorId: "ebeano_lekki_1",
  );

  final testCartItem = CartEntity(
    product: testProduct,
    batchOrderQty: 2,
    synced: false,
    createdTimestamp: DateTime.now(),
    lastModifiedTimestamp: DateTime.now(),
  );

  setUp(() {
    mockPrefs = MockSharedPreferences();
    mockHttpClient = MockHttpClient();

    repo = CartRepositoryImpl(
      prefs: mockPrefs,
      client: mockHttpClient,
      fetchServerCartFn: () async => {},
    );
  });

  group('CartRepositoryImpl', () {

    test('getAllCartItems returns empty map if nothing is stored', () async {
      when(() => mockPrefs.getString(fakeKey)).thenReturn(null);

      final result = await repo.getAllCartItems();

      expect(result, isEmpty);
    });

    test('getCartItemById returns the correct item', () async {
      final encoded = json.encode({
        'product23323': {
          'product': {
            'productId': 'product23323',
            'productName': 'Oven',
            'productSKU': 'oven_',
            'productPurchaseBatch': '5',
            'productBatchPrice': 543.4,
            'minimumBatchOrderQty': 2,
            'maximumBatchOrderQty': 5,
            'vendorId': 'ebeano_lekki_1',
            'lastModifiedTimestamp': DateTime.now().toIso8601String(),
            'createdTimestamp': DateTime.now().toIso8601String(),
            'productImageUrls': []
          },
          'batchOrderQty': 2,
          'synced': false,
          'createdTimestamp': DateTime.now().toIso8601String(),
          'lastModifiedTimestamp': DateTime.now().toIso8601String(),
        }
      });

      when(() => mockPrefs.getString(fakeKey)).thenReturn(encoded);

      final item = await repo.getCartItemById('product23323');

      expect(item?.product.productName, equals('Oven'));
    });

    test('removeFromCartById removes correct item from cart', () async {
      final initialCart = {
        'product23323': {
          'product': {
            'productId': 'product23323',
            'productName': 'Oven',
            'productSKU': 'oven_',
            'productPurchaseBatch': '5',
            'productBatchPrice': 543.4,
            'minimumBatchOrderQty': 2,
            'maximumBatchOrderQty': 5,
            'vendorId': 'ebeano_lekki_1',
            'lastModifiedTimestamp': DateTime.now().toIso8601String(),
            'createdTimestamp': DateTime.now().toIso8601String(),
            'productImageUrls': []
          },
          'batchOrderQty': 2,
          'synced': false,
          'createdTimestamp': DateTime.now().toIso8601String(),
          'lastModifiedTimestamp': DateTime.now().toIso8601String(),
        }
      };

      when(() => mockPrefs.getString(fakeKey)).thenReturn(json.encode(initialCart));
      when(() => mockPrefs.setString(any(), any())).thenAnswer((_) async => true);

      await repo.removeFromCartById('product23323');

      verify(() => mockPrefs.setString(fakeKey, '{}')).called(1);
    });

    test('retryWithExponentialBackoff retries 3 times before success', () async {
      int tries = 0;

      await repo.retryWithExponentialBackoff(() async {
        tries++;
        if (tries < 3) throw Exception('fail');
      });

      expect(tries, equals(3));
    });
  });
}
