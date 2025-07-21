
import 'package:shopai/data/models/product_model.dart';

import '../../domain/entities/cart_entity.dart';

class Carti extends CartEntity {
  Carti({
    required super.product,
    required super.batchOrderQty,
    required super.synced,
    required super.lastModifiedTimestamp,
    required super.createdTimestamp,
  });

  factory Carti.fromJson(Map<String, dynamic> json) {
    return Carti(
      product: PlayBoi.fromJson(json['product']),
      batchOrderQty: json['batchOrderQty'],
      synced: json['synced'],
      lastModifiedTimestamp: DateTime.parse(json['lastModifiedTimestamp']),
      createdTimestamp: DateTime.parse(json['createdTimestamp']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'product': product,
      'batchOrderQty': batchOrderQty,
      'synced': synced,
      'lastModifiedTimestamp': lastModifiedTimestamp.toIso8601String(),
      'createdTimestamp': createdTimestamp.toIso8601String(),
    };
  }

  CartEntity copyWith({
    int? batchOrderQty,
    bool? synced,
    DateTime? lastModifiedTimestamp,
    int? syncAttempts,
  }) =>
      CartEntity(
        product: product,
        batchOrderQty: batchOrderQty ?? this.batchOrderQty,
        synced: synced ?? this.synced,
        lastModifiedTimestamp: lastModifiedTimestamp ?? this.lastModifiedTimestamp,
        createdTimestamp: createdTimestamp,
        syncAttempts: syncAttempts ?? this.syncAttempts,
      );

}
