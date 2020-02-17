import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/orders.dart';
import 'package:shop_app/widgets/app_drawer.dart';
import 'package:shop_app/widgets/order_item.dart' as item;

class OrdersScreen extends StatelessWidget {
  static const routeName = '/orders-screen';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Your orders'),
      ),
      body: FutureBuilder(
        future: Provider.of<Orders>(context, listen: false).fetchOrders(),
        builder: (ctx, dataSnapShot) {
          if (dataSnapShot.connectionState == ConnectionState.waiting)
            return Center(
              child: CircularProgressIndicator(),
            );
          else if (dataSnapShot.error == null)
            return Consumer<Orders>(
              builder: (ctx, orderData, child) => ListView.builder(
                itemCount: orderData.orders.length,
                itemBuilder: (ctx, idx) =>
                    item.OrderItem(orderData.orders[idx]),
              ),
            );
          return null;
        },
      ),
      drawer: AppDrawer(),
    );
  }
}
