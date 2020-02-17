import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;

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

  void toggleFavorite(String userId, String authToken) async {
    final oldFavStatus = isFavorite;
    isFavorite = !isFavorite;
    notifyListeners();
    final url =
        'https://shop-app-77ef6.firebaseio.com/userFavorites/$userId/$id.json?auth=$authToken';
    try {
      final response = await http.put(
        url,
        body: json.encode(
          isFavorite,
        ),
      );
      if (response.statusCode >= 400) {
        isFavorite = oldFavStatus;
        notifyListeners();
      }
    } catch (error) {
      isFavorite = oldFavStatus;
      notifyListeners();
    }
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
