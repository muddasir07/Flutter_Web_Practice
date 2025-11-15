import 'package:hive_flutter/hive_flutter.dart';
import '../../models/product_model.dart';

abstract class ProductLocalDataSource {
  Future<List<Product>> getProducts();
  Future<Product?> getProductById(int id);
  Future<void> saveProducts(List<Product> products);
  Future<int> addProduct(Product product);
  Future<void> updateProduct(Product product);
  Future<void> deleteProduct(int id);
  Future<void> clearAll();
  Future<int> getNextId();
}

class ProductLocalDataSourceImpl implements ProductLocalDataSource {
  final Box<Product> box;
  final Box<int> idBox;

  ProductLocalDataSourceImpl({
    required this.box,
    required this.idBox,
  });

  @override
  Future<List<Product>> getProducts() async {
    return box.values.toList();
  }

  @override
  Future<Product?> getProductById(int id) async {
    // Search through all products to find by ID
    for (final product in box.values) {
      if (product.id == id) {
        return product;
      }
    }
    return null;
  }

  @override
  Future<void> saveProducts(List<Product> products) async {
    await box.clear();
    int maxId = 0;
    for (final product in products) {
      if (product.id > maxId) {
        maxId = product.id;
      }
      // Use a string key to avoid integer key range issues
      await box.put('product_${product.id}', product);
    }
    // Update the max ID counter
    await idBox.put('maxProductId', maxId);
  }

  @override
  Future<int> getNextId() async {
    final currentMax = idBox.get('maxProductId', defaultValue: 0) ?? 0;
    final nextId = currentMax + 1;
    await idBox.put('maxProductId', nextId);
    return nextId;
  }

  @override
  Future<int> addProduct(Product product) async {
    final nextId = await getNextId();
    final productWithId = Product(
      id: nextId,
      name: product.name,
      category: product.category,
      price: product.price,
      stock: product.stock,
      description: product.description,
      imageUrl: product.imageUrl,
    );
    await box.put('product_$nextId', productWithId);
    return nextId;
  }

  @override
  Future<void> updateProduct(Product product) async {
    // Try direct key first
    final directKey = 'product_${product.id}';
    if (box.containsKey(directKey)) {
      await box.put(directKey, product);
      return;
    }
    
    // If not found, search through all keys
    String? keyToUpdate;
    for (final key in box.keys) {
      try {
        final existingProduct = box.get(key);
        if (existingProduct?.id == product.id) {
          keyToUpdate = key.toString();
          break;
        }
      } catch (e) {
        // Skip invalid entries
        continue;
      }
    }
    if (keyToUpdate != null) {
      await box.put(keyToUpdate, product);
    } else {
      // If not found, add as new with direct key
      await box.put(directKey, product);
    }
  }

  @override
  Future<void> deleteProduct(int id) async {
    // Try direct key first
    final directKey = 'product_$id';
    if (box.containsKey(directKey)) {
      await box.delete(directKey);
      return;
    }
    
    // If not found, search through all keys
    String? keyToDelete;
    for (final key in box.keys) {
      try {
        final product = box.get(key);
        if (product?.id == id) {
          keyToDelete = key.toString();
          break;
        }
      } catch (e) {
        // Skip invalid entries
        continue;
      }
    }
    if (keyToDelete != null) {
      await box.delete(keyToDelete);
    }
  }

  @override
  Future<void> clearAll() async {
    await box.clear();
    await idBox.delete('maxProductId');
  }
}

