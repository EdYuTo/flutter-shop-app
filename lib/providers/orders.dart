import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shop_app/providers/cart.dart';

class OrderItem {
  final String id;
  final double amount;
  final List<CartItem> products;
  final DateTime dateTime;

  OrderItem({
    @required this.id,
    @required this.amount,
    @required this.products,
    @required this.dateTime,
  });
}

class Orders with ChangeNotifier {
  final String authToken;
  final String userId;
  List<OrderItem> _orders;

  String _url;

  Orders(this.authToken, this.userId, this._orders) {
    _url =
        'https://shop-app-77ef6.firebaseio.com/orders/$userId.json?auth=$authToken';
  }

  List<OrderItem> get orders {
    return _orders;
  }

  Future<void> addOrder(List<CartItem> cartProducts, double total) async {
    final timeStamp = DateTime.now();
    final response = await http.post(_url,
        body: json.encode({
          'amount': total,
          'dateTime': timeStamp.toIso8601String(),
          'products': cartProducts
              .map((cp) => {
                    'id': cp.id,
                    'title': cp.title,
                    'quantity': cp.quantity,
                    'price': cp.price,
                  })
              .toList()
        }));
    _orders.insert(
      0,
      OrderItem(
        id: json.decode(response.body)['name'],
        amount: total,
        products: cartProducts,
        dateTime: timeStamp,
      ),
    );
    notifyListeners();
  }

  Future<void> fetchOrders() async {
    final response = await http.get(_url);
    final List<OrderItem> loadedOrders = [];
    final data = json.decode(response.body) as Map<String, dynamic>;
    if (data == null) return;
    data.forEach((id, order) {
      loadedOrders.add(
        OrderItem(
          id: id,
          amount: order['amount'],
          products: (order['products'] as List<dynamic>)
              .map(
                (item) => CartItem(
                  id: item['id'],
                  productId: item['productId'],
                  title: item['title'],
                  price: item['price'],
                  quantity: item['quantity'],
                ),
              )
              .toList(),
          dateTime: DateTime.parse(order['dateTime']),
        ),
      );
    });
    _orders = loadedOrders.reversed.toList();
    notifyListeners();
  }
}
