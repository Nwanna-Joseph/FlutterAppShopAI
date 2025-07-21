
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shopai/data/repositories/cart_repository_impl.dart';
import 'package:shopai/data/repositories/product_repository_impl.dart';
import 'package:shopai/presentation/ui/components/cart_list_view.dart';

import '../../controllers/shop_controller.dart';
import '../components/products_list_view.dart';
import '../components/shop_appbar.dart';
import '../state/cart_state.dart';
import '../state/product_state.dart';

class CartiScreen extends StatelessWidget{

  final ShopController shopController = Get.find();

  CartiScreen({super.key});


  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: ShopAppBar(title: "Your Shopping Cart"),
        body: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            Obx(() {
              var cartState = shopController.shopState.value.cartState;

              if (cartState is CartLoading) {
                return const SizedBox(width: 50, height: 50, child: CircularProgressIndicator());
              }

              if (cartState is CartError) {
                return Text("Error fetching cart items: ${cartState.message}");
              }

              if (cartState is CartLoaded) {
                final totalItems = cartState.items.values.fold<int>(
                  0,
                      (sum, item) => sum + item.batchOrderQty,
                );

                final totalPrice = cartState.items.values.fold<double>(
                  0.0,
                      (sum, item) => sum + (item.product.productBatchPrice * item.batchOrderQty),
                );

                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Text(
                    "🛒 $totalItems items in cart | Total: ₦${totalPrice.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                  ),
                );
              }

              return const SizedBox.shrink();
            }),
            Obx( () {
              var productState = shopController.shopState.value.productState;
              var cartState = shopController.shopState.value.cartState;
              if(productState is ProductLoading){
                return const SizedBox( width: 50, height: 50, child: CircularProgressIndicator());
              }
              if(productState is ProductError){
                return Center(child: Text("Error fetching products: ${productState.message}"));
              }
              if(productState is ProductLoaded && cartState is CartLoaded){ //Very important reason for choosing Getx
                return CartListView(cartItems: cartState.items.values.toList(), onViewCart: () {  },);
              }
              return const SizedBox.shrink();
            } )
          ],
        )
    );
  }

}