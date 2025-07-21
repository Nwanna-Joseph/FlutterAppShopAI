import 'package:flutter/material.dart';
class CartAndProductsListView extends StatelessWidget {
  final List<Widget> items;
  final VoidCallback onViewCart;

  const CartAndProductsListView({
    super.key,
    required this.items,
    required this.onViewCart,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // 🛒 Fixed Header
        Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: Colors.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 🛒 Cart icon + text
              Row(
                children: [
                  const Icon(Icons.shopping_cart, color: Colors.black),
                  const SizedBox(width: 8),
                ],
              ),
              // 🔘 View Cart button
              ElevatedButton(
                onPressed: onViewCart,
                child: const Text("View Cart"),
              ),
            ],
          ),
        ),

        // 📜 Scrollable List that fills remaining space
        Expanded(
          child: ListView.builder(
            itemCount: items.length,
            itemBuilder: (context, index) => items[index],
          ),
        ),
      ],
    );
  }
}
