import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopai/data/repositories/cart_repository_impl.dart';
import 'package:shopai/data/repositories/product_repository_impl.dart';
import 'package:shopai/presentation/controllers/shop_controller.dart';
import 'package:shopai/presentation/ui/components/shop_appbar.dart';
import 'package:shopai/presentation/ui/components/products_list_view.dart';
import 'package:shopai/presentation/ui/state/cart_state.dart';
import 'package:shopai/presentation/ui/state/product_state.dart';


class ShopApp extends StatelessWidget{

  final ShopController shopController = Get.find();

  ShopApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: ShopAppBar(),
      body: Column(
       mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Obx(() {
            var cartState = shopController.shopState.value.cartState;

            if (cartState is CartLoading) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox(width: 50, height: 50, child: CircularProgressIndicator()),
                ],
              );
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

              return InkWell(
                onTap: (){ Get.toNamed("/cart"); },
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Text(
                        "🛒 $totalItems items in cart | Total: ₦${totalPrice.toStringAsFixed(2)}",
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Text("View Cart"),
                    )
                  ],
                ),
              );
            }

            return const SizedBox.shrink();
          }),
          Obx( () {
            var productState = shopController.shopState.value.productState;
            var cartState = shopController.shopState.value.cartState;
            if(productState is ProductLoading){
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const SizedBox( width: 50, height: 50, child: CircularProgressIndicator()),
                ],
              );
            }
            if(productState is ProductError){
              return Center(child: Text("Error fetching products: ${productState.message}"));
            }
            if(productState is ProductLoaded && cartState is CartLoaded){ //Very important reason for choosing Getx
              return ProductsListView(products: productState.products, onViewCart: (){  }, cartItems: cartState.items,);
            }
            return const SizedBox.shrink();
          } )
        ],
      )
    );
  }

}