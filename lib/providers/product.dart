import 'package:flutter/foundation.dart';

class Product with ChangeNotifier {
  final String id;
  final String title;
  final String description;
  final double price;
  final String imageUrl;
  bool isFavorite;

  Product({
    @required this.id,
    @required this.title,
    @required this.description,
    @required this.price,
    @required this.imageUrl,
    this.isFavorite = false,
  });

  static Product fromMap(Map<String, Object> productMap) {
    return Product(
      id: productMap['id'],
      title: productMap['title'],
      description: productMap['description'],
      price: productMap['price'],
      imageUrl: productMap['imageUrl'],
      isFavorite: productMap['isFavorite'],
    );
  }

  void toggleFavorite() {
    isFavorite = !isFavorite;
    notifyListeners();
  }

  Map<String, Object> toMap() {
    return {
      'id': this.id,
      'title': this.title,
      'description': this.description,
      'price': this.price,
      'imageUrl': this.imageUrl,
      'isFavorite': this.isFavorite,
    };
  }
}
