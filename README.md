
# 🛒 Modular Offline-First Shopping Cart

A robust Flutter shopping cart app that works **offline-first**, with intelligent syncing, clean architecture, and full test coverage.

---

## 🚀 About the App

This is a **modular, offline-capable shopping cart** system built with Flutter. It enables users to browse products, add them to cart, and continue shopping even when there's no internet. When connectivity is restored, the cart is **synchronized** intelligently with the server using conflict resolution.

---

## 🧰 Features

- 🛍️ View a list of products with images, prices, and batch constraints
- ➕ Add to cart / ➖ Remove from cart
- 📴 Offline-first: cart works seamlessly without internet
- 🔁 Auto-sync cart with server once online
- 🔀 Conflict resolution using `lastModifiedTimestamp`
- 🔄 Retry sync using **exponential backoff**
- ✅ Clean architecture (Domain → Data → Presentation)
- 🧪 Unit tested with command-line support

---

## 🧠 How the Cart Works

- Cart items are saved locally using `SharedPreferences`
- Each cart item includes:
  - Product reference
  - Quantity (`batchOrderQty`)
  - `lastModifiedTimestamp`
  - `synced` status
- Items are uniquely keyed by `productId`
- The cart is **merged with server data** during sync based on timestamps

---

## 📦 Shared Preferences Usage

We use [`shared_preferences`](https://pub.dev/packages/shared_preferences) to persist cart items on-device.

### ✅ Key Points:
- Data is serialized as JSON
- On `addToCart`, the cart is saved to shared preferences
- On startup, cart is loaded from shared preferences

```dart
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
```

---

## 🌐 Network Unavailability Handling

We use the [`connectivity_plus`](https://pub.dev/packages/connectivity_plus) package to detect when the device is online or offline.

```dart
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
```

## 🔄 Cart Syncing (Remote & Local)

Cart items are compared locally and server-side using their `productId` and `lastModifiedTimestamp`. The most recent version wins.

```dart
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
```

---

## 🔁 Retry Mechanism with Exponential Backoff

If syncing a cart item fails due to network issues or server errors, we use **exponential backoff** to retry:

```dart
Future<void> retryWithExponentialBackoff(
  Future<void> Function() action,
  {int maxAttempts = 5}
) async {
  int attempt = 0;
  Duration delay = Duration(seconds: 1);

  while (attempt < maxAttempts) {
    try {
      await action();
      return;
    } catch (_) {
      attempt++;
      if (attempt == maxAttempts) rethrow;
      await Future.delayed(delay);
      delay *= 2;
    }
  }
}
```

---

## 🔧 Conflict Resolution Example

This ensures the most recent update (local or server) is used:

```dart
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
```

---

## 🧪 Unit Testing

We follow the **Clean Architecture** testing pyramid:
- Domain logic is fully unit tested
- Repositories are mock-tested
- Presentation is widget-tested where necessary

---

## 🧼 Clean Architecture

The codebase follows the **Clean Architecture** principles:

```
lib/
│
├── data/          # Local and remote implementations
├── domain/        # Entities & Repositories
├── presentation/  # UI, Controllers, State classes
```

---

## 🧩 Technologies Used

- Flutter 3+
- shared_preferences
- connectivity_plus
- http
- workmanager
- get / bloc / cubit (depending on layer)
- faker (for test data)

---
### Build APK:
```
flutter build apk --release --target=lib\presentation\screen\main.dart
```

### Run Debug
```
flutter run --target=lib\presentation\screen\main.dart
```

### Run Test
```
flutter test test/task_repository_tests/mock_flutter_secure_storage.dart
```

