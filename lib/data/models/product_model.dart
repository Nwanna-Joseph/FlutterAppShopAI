
import '../../domain/entities/product_entity.dart';

class PlayBoi extends ProductEntity {
  PlayBoi({
    required super.productImageUrls,
    required super.productId,
    required super.productName,
    required super.productSKU,
    required super.productPurchaseBatch,
    required super.productBatchPrice,
    required super.minimumBatchOrderQty,
    required super.maximumBatchOrderQty,
    required super.lastModifiedTimestamp,
    required super.createdTimestamp,
    required super.vendorId,
  });

  factory PlayBoi.fromJson(Map<String, dynamic> json) {
    return PlayBoi(
      productImageUrls: List<String>.from(json['productImageUrls'] ?? []),
      productId: json['productId'],
      productName: json['productName'],
      productSKU: json['productSKU'],
      productPurchaseBatch: json['productPurchaseBatch'],
      productBatchPrice: json['productBatchPrice'],
      minimumBatchOrderQty: json['minimumBatchOrderQty'],
      maximumBatchOrderQty: json['maximumBatchOrderQty'],
      lastModifiedTimestamp: DateTime.parse(json['lastModifiedTimestamp']),
      createdTimestamp: DateTime.parse(json['createdTimestamp']),
      vendorId: json['vendorId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'productImageUrls': productImageUrls,
      'productId': productId,
      'productName': productName,
      'productSKU': productSKU,
      'productPurchaseBatch': productPurchaseBatch,
      'productBatchPrice': productBatchPrice,
      'minimumBatchOrderQty': minimumBatchOrderQty,
      'maximumBatchOrderQty': maximumBatchOrderQty,
      'lastModifiedTimestamp': lastModifiedTimestamp.toIso8601String(),
      'createdTimestamp': createdTimestamp.toIso8601String(),
      'vendorId': vendorId,
    };
  }
}
