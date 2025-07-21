import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopai/presentation/controllers/shop_controller.dart';
import 'package:shopai/presentation/ui/screens/cart.dart';
import 'package:shopai/presentation/ui/screens/shop.dart';
import 'package:workmanager/workmanager.dart';

import 'data/repositories/cart_repository_impl.dart';
import 'data/repositories/product_repository_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initDependencyInjection();
  runApp(const MyApp());
}

initDependencyInjection() async {
  final prefs = await SharedPreferences.getInstance();

  Get.lazyPut<ShopController>(() => ShopController(
      productRepository: ProductRepositoryImpl(prefs: prefs),
      cartRepository: CartRepositoryImpl(prefs: prefs)));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: "/shop",
      routes: {
        '/shop': (context) => ShopApp(),
        '/cart': (context) => CartiScreen(),
      },
    );
  }
}
