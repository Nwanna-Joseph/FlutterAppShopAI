
import 'package:shopai/domain/entities/product_entity.dart';

class CartEntity {
  final ProductEntity product;
  final int batchOrderQty;
  final bool synced; // Already present
  final DateTime lastModifiedTimestamp;
  final DateTime createdTimestamp;
  final int syncAttempts; // NEW

  CartEntity({
    required this.product,
    required this.batchOrderQty,
    required this.synced,
    required this.lastModifiedTimestamp,
    required this.createdTimestamp,
    this.syncAttempts = 0,
  });


}
