import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shopai/domain/entities/cart_entity.dart';
import 'package:shopai/domain/entities/product_entity.dart';
import 'package:shopai/presentation/ui/components/cart_item_view.dart';
import 'package:shopai/presentation/ui/components/product_item_view.dart';

import '../../controllers/shop_controller.dart';

class CartListView extends StatelessWidget {
  final ShopController shopController = Get.find();
  final List<CartEntity> cartItems;
  final VoidCallback onViewCart;

  CartListView({
    super.key,
    required this.onViewCart,
    required this.cartItems,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: ListView.builder(
        itemCount: cartItems.length,
        itemBuilder: (context, index) => CartItemView(cartEntity: cartItems[index],),
      ),
    );
  }
}