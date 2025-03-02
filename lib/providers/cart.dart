import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

class CartItem {
  final String id;
  final String productId;
  final String title;
  final int quantity;
  final double price;

  CartItem({
    @required this.id,
    @required this.productId,
    @required this.title,
    @required this.quantity,
    @required this.price,
  });
}

class Cart with ChangeNotifier {
  Map<String, CartItem> _items = {};

  Map<String, CartItem> get items {
    return {..._items};
  }

  int get itemCount {
    return _items.length;
  }

  double get totalAmount {
    var total = 0.0;
    _items.forEach((key, item) {
      total += item.price * item.quantity;
    });
    return total;
  }

  void addItem({
    @required productId,
    @required title,
    @required price,
  }) {
    if (_items.containsKey(productId)) {
      _items.update(
          productId,
          (existing) => CartItem(
                id: existing.id,
                title: existing.title,
                price: existing.price,
                quantity: existing.quantity + 1,
              ));
    } else {
      _items.putIfAbsent(
          productId,
          () => CartItem(
                id: Uuid().v4(),
                title: title,
                price: price,
                quantity: 1,
              ));
    }
    notifyListeners();
  }

  void removeItem(String productId) {
    _items.remove(productId);
    notifyListeners();
  }

  void clearCart() {
    _items = {};
    notifyListeners();
  }

  void removeSingleItem(String productId) {
    if (_items.containsKey(productId) && _items[productId].quantity > 1) {
      _items.update(
          productId,
          (existing) => CartItem(
                id: existing.id,
                productId: existing.productId,
                title: existing.title,
                price: existing.price,
                quantity: existing.quantity - 1,
              ));
    } else if (_items.containsKey(productId)) {
      _items.remove(productId);
    }
    notifyListeners();
  }
}
