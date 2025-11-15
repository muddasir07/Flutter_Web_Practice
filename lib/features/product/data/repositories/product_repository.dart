import '../../models/product_model.dart';
import '../datasources/product_local_datasource.dart';
import '../datasources/product_remote_datasource.dart';

abstract class ProductRepository {
  Future<List<Product>> getProducts({bool forceRefresh = false});
  Future<Product?> getProductById(int id);
  Future<int> addProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(int id);
}

class ProductRepositoryImpl implements ProductRepository {
  final ProductLocalDataSource localDataSource;
  final ProductRemoteDataSource remoteDataSource;

  ProductRepositoryImpl({
    required this.localDataSource,
    required this.remoteDataSource,
  });

  @override
  Future<List<Product>> getProducts({bool forceRefresh = false}) async {
    try {
      if (forceRefresh) {
        final remoteProducts = await remoteDataSource.getProducts();
        await localDataSource.saveProducts(remoteProducts);
        return remoteProducts;
      }

      final localProducts = await localDataSource.getProducts();
      if (localProducts.isEmpty) {
        final remoteProducts = await remoteDataSource.getProducts();
        await localDataSource.saveProducts(remoteProducts);
        return remoteProducts;
      }

      // Max ID will be set correctly when products are saved

      return localProducts;
    } catch (e) {
      // If remote fails, return local data
      return await localDataSource.getProducts();
    }
  }

  @override
  Future<Product?> getProductById(int id) async {
    try {
      final localProduct = await localDataSource.getProductById(id);
      if (localProduct != null) {
        return localProduct;
      }

      // Try to fetch from remote
      final remoteProduct = await remoteDataSource.getProductById(id);
      await localDataSource.addProduct(remoteProduct);
      return remoteProduct;
    } catch (e) {
      return await localDataSource.getProductById(id);
    }
  }

  @override
  Future<int> addProduct(Product product) async {
    return await localDataSource.addProduct(product);
  }

  @override
  Future<void> updateProduct(Product product) async {
    await localDataSource.updateProduct(product);
  }

  @override
  Future<void> deleteProduct(int id) async {
    await localDataSource.deleteProduct(id);
  }
}

