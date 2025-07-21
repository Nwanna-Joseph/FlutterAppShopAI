
import 'package:shopai/domain/entities/product_entity.dart';

abstract class PlayBoiState {}

class ProductInitial extends PlayBoiState {}

class ProductLoading extends PlayBoiState {}

class ProductLoaded extends PlayBoiState {
  final List<ProductEntity> products;

  ProductLoaded(this.products);
}

class ProductError extends PlayBoiState {
  final String message;

  ProductError(this.message);
}
