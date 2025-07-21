import 'dart:async';

import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:get/get.dart';
import 'package:shopai/domain/repositories/CartRepository.dart';
import 'package:shopai/domain/repositories/ProductRepository.dart';
import 'package:shopai/domain/entities/product_entity.dart';
import 'package:shopai/domain/entities/cart_entity.dart';
import 'package:shopai/presentation/ui/state/cart_state.dart';
import 'package:shopai/presentation/ui/state/product_state.dart';
import 'package:shopai/presentation/ui/state/shop_controller_state.dart';


class ShopController extends GetxController {
  final ProductRepository productRepository;
  final CartRepository cartRepository;

  Rx<ShopState> shopState = ShopState(CartInitial(), ProductInitial()).obs;

  ShopController({
    required this.productRepository,
    required this.cartRepository,
  });

  Map<String, CartEntity> _cartItems = {};
  List<ProductEntity> _productList = [];

  RxBool isInternetConnected = false.obs;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  @override
  void onInit() {
    super.onInit();
    checkConnectivity(); // Initial and stream subscription
    loadCartAndProducts();
  }

  /// Check internet status once and subscribe to changes
  Future<void> checkConnectivity() async {
    // Initial check
    final result = await Connectivity().checkConnectivity();
    isInternetConnected.value = result != ConnectivityResult.none;

    // Subscribe to network changes
    _connectivitySubscription = Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) {
      final connected = result != ConnectivityResult.none;
      isInternetConnected.value = connected;

      if (connected) {
        // Internet came back — trigger retry sync, refresh, etc.
        _retryPendingSync();
      }
    });

  }

  /// Clean up on destroy
  @override
  void onClose() {
    _connectivitySubscription?.cancel();
    super.onClose();
  }

  /// Trigger syncing unsynced cart items if any
  Future<void> _retryPendingSync() async {
    await cartRepository.syncCart();
    _cartItems = await cartRepository.getAllCartItems();
    shopState.value = ShopState(CartLoaded(_cartItems), shopState.value.productState);
  }

  /// Load both cart and product list, and update shopState accordingly
  Future<void> loadCartAndProducts() async {
    shopState.value = ShopState(CartLoading(), ProductLoading());

    _cartItems = await cartRepository.getAllCartItems();
    shopState.value = ShopState(CartLoaded(_cartItems), ProductLoading());

    _productList = await productRepository.getAllProducts();
    shopState.value = ShopState(CartLoaded(_cartItems), ProductLoaded(_productList));
  }

  /// Add one quantity of a product to the cart
  Future<void> addToCart(ProductEntity product) async {
    final id = product.productId;

    if (_cartItems.containsKey(id)) {
      final existing = _cartItems[id]!;
      final newQty = existing.batchOrderQty + 1;

      _cartItems[id] = CartEntity(
        product: product,
        batchOrderQty: newQty,
        synced: false,
        lastModifiedTimestamp: DateTime.now(),
        createdTimestamp: existing.createdTimestamp,
      );
    } else {
      _cartItems[id] = CartEntity(
        product: product,
        batchOrderQty: 1,
        synced: false,
        lastModifiedTimestamp: DateTime.now(),
        createdTimestamp: DateTime.now(),
      );
    }

    await cartRepository.addToCart(_cartItems[id]!);
    shopState.value = ShopState(CartLoaded(_cartItems), shopState.value.productState);
  }

  /// Optional: Remove from cart
  Future<void> removeFromCart(ProductEntity product) async {
    final id = product.productId;

    if (_cartItems.containsKey(id)) {
      final existing = _cartItems[id]!;
      final newQty = existing.batchOrderQty - 1;

      if (newQty <= 0) {
        _cartItems.remove(id);
        await cartRepository.removeFromCartById(id);
      } else {
        _cartItems[id] = CartEntity(
          product: product,
          batchOrderQty: newQty,
          synced: false,
          lastModifiedTimestamp: DateTime.now(),
          createdTimestamp: existing.createdTimestamp,
        );
        await cartRepository.addToCart(_cartItems[id]!);
      }

      shopState.value = ShopState(CartLoaded(_cartItems), shopState.value.productState);
    }
  }

  int getQuantityInCart(String productId) {
    return _cartItems[productId]?.batchOrderQty ?? 0;
  }
}
