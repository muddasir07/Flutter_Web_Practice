import 'package:flutter_bloc/flutter_bloc.dart';
import '../../data/repositories/product_repository.dart';
import '../../models/product_model.dart';
import 'product_event.dart';
import 'product_state.dart';

class ProductBloc extends Bloc<ProductEvent, ProductState> {
  final ProductRepository repository;

  ProductBloc({required this.repository}) : super(const ProductState()) {
    on<LoadProducts>(_onLoadProducts);
    on<AddProduct>(_onAddProduct);
    on<UpdateProduct>(_onUpdateProduct);
    on<DeleteProduct>(_onDeleteProduct);
    on<SearchProducts>(_onSearchProducts);
    on<FilterProducts>(_onFilterProducts);
    on<SortProducts>(_onSortProducts);
    on<ChangePage>(_onChangePage);
  }

  Future<void> _onLoadProducts(
    LoadProducts event,
    Emitter<ProductState> emit,
  ) async {
    emit(state.copyWith(status: ProductStatus.loading));

    try {
      final products = await repository.getProducts(
        forceRefresh: event.forceRefresh,
      );
      final filteredProducts = _applyFilters(products, state);
      emit(
        state.copyWith(
          status: ProductStatus.success,
          products: products,
          filteredProducts: filteredProducts,
          errorMessage: null,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProductStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onAddProduct(
    AddProduct event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await repository.addProduct(event.product);
      // Reload products to ensure consistency
      final updatedProducts = await repository.getProducts();
      final filteredProducts = _applyFilters(updatedProducts, state);
      emit(
        state.copyWith(
          products: updatedProducts,
          filteredProducts: filteredProducts,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProductStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onUpdateProduct(
    UpdateProduct event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await repository.updateProduct(event.product);
      // Reload products to ensure consistency
      final updatedProducts = await repository.getProducts();
      final filteredProducts = _applyFilters(updatedProducts, state);
      emit(
        state.copyWith(
          products: updatedProducts,
          filteredProducts: filteredProducts,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProductStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  Future<void> _onDeleteProduct(
    DeleteProduct event,
    Emitter<ProductState> emit,
  ) async {
    try {
      await repository.deleteProduct(event.id);
      // Reload products to ensure consistency
      final updatedProducts = await repository.getProducts();
      final filteredProducts = _applyFilters(updatedProducts, state);
      emit(
        state.copyWith(
          products: updatedProducts,
          filteredProducts: filteredProducts,
        ),
      );
    } catch (e) {
      emit(
        state.copyWith(
          status: ProductStatus.failure,
          errorMessage: e.toString(),
        ),
      );
    }
  }

  void _onSearchProducts(
    SearchProducts event,
    Emitter<ProductState> emit,
  ) {
    final newState = state.copyWith(searchQuery: event.query);
    final filteredProducts = _applyFilters(state.products, newState);
    emit(newState.copyWith(filteredProducts: filteredProducts, currentPage: 1));
  }

  void _onFilterProducts(
    FilterProducts event,
    Emitter<ProductState> emit,
  ) {
    final newState = state.copyWith(
      selectedCategory: event.category,
      inStockFilter: event.inStock,
    );
    final filteredProducts = _applyFilters(state.products, newState);
    emit(newState.copyWith(filteredProducts: filteredProducts, currentPage: 1));
  }

  void _onSortProducts(
    SortProducts event,
    Emitter<ProductState> emit,
  ) {
    final sortedProducts = List<Product>.from(state.filteredProducts);
    sortedProducts.sort((a, b) {
      int comparison = 0;
      switch (event.sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'category':
          comparison = a.category.compareTo(b.category);
          break;
        case 'price':
          comparison = a.price.compareTo(b.price);
          break;
        case 'stock':
          comparison = a.stock.compareTo(b.stock);
          break;
        default:
          comparison = a.id.compareTo(b.id);
      }
      return event.ascending ? comparison : -comparison;
    });

    emit(
      state.copyWith(
        filteredProducts: sortedProducts,
        sortBy: event.sortBy,
        sortAscending: event.ascending,
        currentPage: 1,
      ),
    );
  }

  void _onChangePage(
    ChangePage event,
    Emitter<ProductState> emit,
  ) {
    emit(state.copyWith(currentPage: event.page));
  }

  List<Product> _applyFilters(List<Product> products, ProductState state) {
    var filtered = List<Product>.from(products);

    // Apply search
    if (state.searchQuery.isNotEmpty) {
      final query = state.searchQuery.toLowerCase();
      filtered = filtered
          .where((p) =>
              p.name.toLowerCase().contains(query) ||
              p.category.toLowerCase().contains(query) ||
              (p.description?.toLowerCase().contains(query) ?? false))
          .toList();
    }

    // Apply category filter
    if (state.selectedCategory != null) {
      filtered = filtered
          .where((p) => p.category == state.selectedCategory)
          .toList();
    }

    // Apply stock filter
    if (state.inStockFilter != null) {
      filtered = filtered
          .where((p) => p.isInStock == state.inStockFilter)
          .toList();
    }

    // Apply sorting
    filtered.sort((a, b) {
      int comparison = 0;
      switch (state.sortBy) {
        case 'name':
          comparison = a.name.compareTo(b.name);
          break;
        case 'category':
          comparison = a.category.compareTo(b.category);
          break;
        case 'price':
          comparison = a.price.compareTo(b.price);
          break;
        case 'stock':
          comparison = a.stock.compareTo(b.stock);
          break;
        default:
          comparison = a.id.compareTo(b.id);
      }
      return state.sortAscending ? comparison : -comparison;
    });

    return filtered;
  }
}

