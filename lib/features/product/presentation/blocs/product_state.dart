import 'package:equatable/equatable.dart';
import '../../models/product_model.dart';

enum ProductStatus { initial, loading, success, failure }

class ProductState extends Equatable {
  final ProductStatus status;
  final List<Product> products;
  final List<Product> filteredProducts;
  final String? errorMessage;
  final String searchQuery;
  final String? selectedCategory;
  final bool? inStockFilter;
  final String sortBy;
  final bool sortAscending;
  final int currentPage;
  final int itemsPerPage;

  const ProductState({
    this.status = ProductStatus.initial,
    this.products = const [],
    this.filteredProducts = const [],
    this.errorMessage,
    this.searchQuery = '',
    this.selectedCategory,
    this.inStockFilter,
    this.sortBy = 'id',
    this.sortAscending = true,
    this.currentPage = 1,
    this.itemsPerPage = 10,
  });

  ProductState copyWith({
    ProductStatus? status,
    List<Product>? products,
    List<Product>? filteredProducts,
    String? errorMessage,
    String? searchQuery,
    String? selectedCategory,
    bool? inStockFilter,
    String? sortBy,
    bool? sortAscending,
    int? currentPage,
    int? itemsPerPage,
  }) {
    return ProductState(
      status: status ?? this.status,
      products: products ?? this.products,
      filteredProducts: filteredProducts ?? this.filteredProducts,
      errorMessage: errorMessage,
      searchQuery: searchQuery ?? this.searchQuery,
      selectedCategory: selectedCategory ?? this.selectedCategory,
      inStockFilter: inStockFilter ?? this.inStockFilter,
      sortBy: sortBy ?? this.sortBy,
      sortAscending: sortAscending ?? this.sortAscending,
      currentPage: currentPage ?? this.currentPage,
      itemsPerPage: itemsPerPage ?? this.itemsPerPage,
    );
  }

  List<Product> get paginatedProducts {
    if (filteredProducts.isEmpty) return [];
    final start = (currentPage - 1) * itemsPerPage;
    if (start >= filteredProducts.length) {
      return [];
    }
    final end = (start + itemsPerPage > filteredProducts.length)
        ? filteredProducts.length
        : start + itemsPerPage;
    return filteredProducts.sublist(start, end);
  }

  int get totalPages {
    return (filteredProducts.length / itemsPerPage).ceil();
  }

  List<String> get categories {
    return products.map((p) => p.category).toSet().toList()..sort();
  }

  @override
  List<Object?> get props => [
        status,
        products,
        filteredProducts,
        errorMessage,
        searchQuery,
        selectedCategory,
        inStockFilter,
        sortBy,
        sortAscending,
        currentPage,
        itemsPerPage,
      ];
}

