
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../../../domain/entities/cart_entity.dart';
import '../../../domain/entities/product_entity.dart';


class CartItemView extends StatelessWidget {

  final CartEntity cartEntity;

  const CartItemView({
    super.key,
    required this.cartEntity,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
      ),
      margin: const EdgeInsets.all(4),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                 imageUrl: 'https://via.placeholder.com/600x400.png?text=Product+Image',
                placeholder: (context, url) =>
                    Container(height: 100, color: Colors.grey[200]),
                errorWidget: (context, url, error) =>
                    Container(height: 100, color: Colors.grey[300]),
                height: 100,
                width: double.infinity,
                fit: BoxFit.cover,
              ),
            ),

            const SizedBox(height: 8),

            // Name
            Text(
              cartEntity.product.productName,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 4),

            // Price and batch
            Text(
              '₦${cartEntity.product.productBatchPrice.toStringAsFixed(2)} per batch '
                  '(Minimum order quantity: ${cartEntity.product.minimumBatchOrderQty}. Maximum order quantity: ${cartEntity.product.maximumBatchOrderQty})',
              style: const TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),

            const SizedBox(height: 8),

            // Add/remove row
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                cartEntity.synced ? const Text("Synced") : const Text("Not yet synced"),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
