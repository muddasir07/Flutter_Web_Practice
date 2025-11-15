import 'package:equatable/equatable.dart';
import '../../models/product_model.dart';

abstract class ProductEvent extends Equatable {
  const ProductEvent();

  @override
  List<Object?> get props => [];
}

class LoadProducts extends ProductEvent {
  final bool forceRefresh;

  const LoadProducts({this.forceRefresh = false});

  @override
  List<Object?> get props => [forceRefresh];
}

class AddProduct extends ProductEvent {
  final Product product;

  const AddProduct(this.product);

  @override
  List<Object?> get props => [product];
}

class UpdateProduct extends ProductEvent {
  final Product product;

  const UpdateProduct(this.product);

  @override
  List<Object?> get props => [product];
}

class DeleteProduct extends ProductEvent {
  final int id;

  const DeleteProduct(this.id);

  @override
  List<Object?> get props => [id];
}

class SearchProducts extends ProductEvent {
  final String query;

  const SearchProducts(this.query);

  @override
  List<Object?> get props => [query];
}

class FilterProducts extends ProductEvent {
  final String? category;
  final bool? inStock;

  const FilterProducts({this.category, this.inStock});

  @override
  List<Object?> get props => [category, inStock];
}

class SortProducts extends ProductEvent {
  final String sortBy;
  final bool ascending;

  const SortProducts({required this.sortBy, this.ascending = true});

  @override
  List<Object?> get props => [sortBy, ascending];
}

class ChangePage extends ProductEvent {
  final int page;

  const ChangePage(this.page);

  @override
  List<Object?> get props => [page];
}

