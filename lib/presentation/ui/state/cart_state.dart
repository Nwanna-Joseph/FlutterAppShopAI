
import 'package:shopai/domain/entities/cart_entity.dart';

abstract class CartiState {}

class CartInitial extends CartiState {}

class CartLoading extends CartiState {}

class CartLoaded extends CartiState {
  final Map<String,CartEntity> items;

  CartLoaded(this.items);
}

class CartError extends CartiState {
  final String message;

  CartError(this.message);
}
