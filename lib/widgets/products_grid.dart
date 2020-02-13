import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shop_app/providers/products_provider.dart';
import 'product_item.dart';

class ProductsGrid extends StatelessWidget {
  final bool _showOnlyFavorites;

  ProductsGrid(this._showOnlyFavorites);

  @override
  Widget build(BuildContext context) {
    final productsData = Provider.of<ProductsProvider>(context);
    final loadedProducts =
        _showOnlyFavorites ? productsData.favoriteItems : productsData.items;
    return GridView.builder(
      padding: const EdgeInsets.all(10),
      itemCount: loadedProducts.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 3.0 / 2.0,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
      ),
      itemBuilder: (ctx, index) => ChangeNotifierProvider.value(
        // better for lists, and it cleans data automatically
        value: loadedProducts[index],
        child: ProductItem(),
      ),
    );
  }
}
