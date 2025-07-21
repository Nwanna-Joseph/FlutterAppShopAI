import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopai/domain/entities/cart_entity.dart';
import 'package:shopai/domain/entities/product_entity.dart';
import 'package:shopai/presentation/ui/components/product_item_view.dart';

import '../../controllers/shop_controller.dart';

class ProductsListView extends StatelessWidget {
  final ShopController shopController = Get.find();
  final List<ProductEntity> products;
  final Map<String,CartEntity> cartItems;
  final VoidCallback onViewCart;

  ProductsListView({
    super.key,
    required this.products,
    required this.onViewCart,
    required this.cartItems,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: products.length,
        itemBuilder: (context, index) => ProductItemView(productEntity: products[index],
            addTap: (){ shopController.addToCart(products[index]); },
            removeTap: (){ shopController.removeFromCart(products[index]); },
            cartEntity: cartItems[products[index].productId]),
      ),
    );
  }
}