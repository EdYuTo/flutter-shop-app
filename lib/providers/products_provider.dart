import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shop_app/models/http_exception.dart';
import 'package:shop_app/providers/product.dart';
import 'package:http/http.dart' as http;

class ProductsProvider with ChangeNotifier {
  static const _url = 'https://shop-app-77ef6.firebaseio.com/products.json';

  List<Product> _items = [];

  List<Product> get items {
    return [..._items];
  }

  List<Product> get favoriteItems {
    return _items.where((item) => item.isFavorite).toList();
  }

  Product findById(String id) {
    return _items.firstWhere((product) => product.id == id);
  }

  Future<void> addProduct(Product product) async {
    try {
      final response = await http.post(_url, body: jsonEncode(product.toMap()));
      //_items.add(product);
      _items.add(Product(
        id: json.decode(response.body)['name'],
        title: product.title,
        description: product.description,
        price: product.price,
        imageUrl: product.imageUrl,
        isFavorite: product.isFavorite,
      ));
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }

  Future<void> updateProduct(String id, Product newProduct) async {
    final url = 'https://shop-app-77ef6.firebaseio.com/products/$id.json';
    final productIdx = _items.indexWhere((product) => product.id == id);
    if (productIdx >= 0) {
      try {
        await http.patch(url, body: json.encode(newProduct.toMap()));
      } catch (error) {
        throw (error);
      }
      _items[productIdx] = newProduct;
    }
    notifyListeners();
  }

  Future<void> deleteProduct(String id) async {
    final url = 'https://shop-app-77ef6.firebaseio.com/products/$id.json';
    final existingProductIndex =
        _items.indexWhere((product) => product.id == id);
    var existingProduct = _items[existingProductIndex];
    _items.removeAt(existingProductIndex);
    notifyListeners();
    final response = await http.delete(url);
    if (response.statusCode >= 400) {
      _items.insert(existingProductIndex, existingProduct);
      notifyListeners();
      throw HttpException('Could not delete product');
    }
    existingProduct = null;
  }

  Future<void> fetchProducts() async {
    try {
      final response = await http.get(_url);
      final data = json.decode(response.body) as Map<String, dynamic>;
      final List<Product> newItems = [];
      if (data == null)
        return;
      data.forEach((id, product) {
        newItems.add(Product(
          id: id,
          title: product['title'],
          description: product['description'],
          price: product['price'],
          imageUrl: product['imageUrl'],
          isFavorite: product['isFavorite'],
        ));
      });
      _items = newItems;
      notifyListeners();
    } catch (error) {
      throw (error);
    }
  }
}
