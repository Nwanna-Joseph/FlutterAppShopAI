class ProductEntity {
  final String productId;
  final String productName;
  final String productSKU;
  final String productPurchaseBatch;
  final double productBatchPrice;
  final int minimumBatchOrderQty;
  final int maximumBatchOrderQty;
  final DateTime lastModifiedTimestamp;
  final DateTime createdTimestamp;
  final String vendorId;
  final List<String> productImageUrls;

  ProductEntity({
    required this.productImageUrls,
    required this.productId,
    required this.productName,
    required this.productSKU,
    required this.productPurchaseBatch,
    required this.productBatchPrice,
    required this.minimumBatchOrderQty,
    required this.maximumBatchOrderQty,
    required this.lastModifiedTimestamp,
    required this.createdTimestamp,
    required this.vendorId,
  });
}