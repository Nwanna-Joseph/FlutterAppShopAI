
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
final prefs = await SharedPreferences.getInstance();
prefs.setString('cart_items', jsonEncode(cartMap));
```

---

## 🌐 Network Unavailability Handling

We use the [`connectivity_plus`](https://pub.dev/packages/connectivity_plus) package to detect when the device is online or offline.

```dart
final connectivity = await Connectivity().checkConnectivity();
if (connectivity != ConnectivityResult.none) {
  await syncCart();
}
```

We also support **background sync** using `workmanager` which triggers a periodic job every 15 minutes to try syncing cart data if the device is online.

---

## 🔄 Cart Syncing (Remote & Local)

Cart items are compared locally and server-side using their `productId` and `lastModifiedTimestamp`. The most recent version wins.

```dart
if (localItem.lastModifiedTimestamp.isAfter(serverItem.lastModifiedTimestamp)) {
  // Keep local and upload
  await uploadCartItemToServer(localItem);
} else {
  // Use server version and save locally
  await saveCartItem(serverItem);
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
if (localItem.lastModifiedTimestamp.isAfter(serverItem.lastModifiedTimestamp)) {
  await uploadCartItemToServer(localItem);
  await saveCartItem(localItem.copyWith(synced: true));
} else {
  await saveCartItem(serverItem.copyWith(synced: true));
}
```

---

## 🧪 Unit Testing

We follow the **Clean Architecture** testing pyramid:
- Domain logic is fully unit tested
- Repositories are mock-tested
- Presentation is widget-tested where necessary

### 📦 Run tests from the command line:

```bash
flutter test
```

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

## 📬 Contributions

If you'd like to contribute to this app, feel free to fork the repo, create a feature branch, and open a pull request.

---

## 📝 License

This project is licensed under the MIT License.

---

> Built for offline performance, synced for scale. Happy coding!
