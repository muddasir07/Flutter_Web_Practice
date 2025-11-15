import 'package:hive/hive.dart';
import 'package:equatable/equatable.dart';

class ProductAdapter extends TypeAdapter<Product> {
  @override
  final int typeId = 0;

  @override
  Product read(BinaryReader reader) {
    return Product(
      id: reader.readInt(),
      name: reader.readString(),
      category: reader.readString(),
      price: reader.readDouble(),
      stock: reader.readInt(),
      description: reader.readBool() ? reader.readString() : null,
      imageUrl: reader.readBool() ? reader.readString() : null,
    );
  }

  @override
  void write(BinaryWriter writer, Product obj) {
    writer.writeInt(obj.id);
    writer.writeString(obj.name);
    writer.writeString(obj.category);
    writer.writeDouble(obj.price);
    writer.writeInt(obj.stock);
    writer.writeBool(obj.description != null);
    if (obj.description != null) writer.writeString(obj.description!);
    writer.writeBool(obj.imageUrl != null);
    if (obj.imageUrl != null) writer.writeString(obj.imageUrl!);
  }
}

class Product extends Equatable {
  final int id;
  final String name;
  final String category;
  final double price;
  final int stock;
  final String? description;
  final String? imageUrl;

  const Product({
    required this.id,
    required this.name,
    required this.category,
    required this.price,
    required this.stock,
    this.description,
    this.imageUrl,
  });

  bool get isInStock => stock > 0;
  String get stockStatus => isInStock ? 'In stock' : 'Out of stock';

  Product copyWith({
    int? id,
    String? name,
    String? category,
    double? price,
    int? stock,
    String? description,
    String? imageUrl,
  }) {
    return Product(
      id: id ?? this.id,
      name: name ?? this.name,
      category: category ?? this.category,
      price: price ?? this.price,
      stock: stock ?? this.stock,
      description: description ?? this.description,
      imageUrl: imageUrl ?? this.imageUrl,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': name,
      'category': category,
      'price': price,
      'stock': stock,
      'description': description,
      'thumbnail': imageUrl,
    };
  }

  factory Product.fromJson(Map<String, dynamic> json) {
    return Product(
      id: json['id'] as int,
      name: json['title'] as String? ?? json['name'] as String? ?? '',
      category: json['category'] as String? ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      stock: json['stock'] as int? ?? 0,
      description: json['description'] as String?,
      imageUrl: json['thumbnail'] as String? ?? json['imageUrl'] as String?,
    );
  }

  @override
  List<Object?> get props => [id, name, category, price, stock, description, imageUrl];
}

