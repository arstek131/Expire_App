/* dart */
import 'package:flutter/material.dart';

/* providers */
import '../providers/products_provider.dart';
import 'package:provider/provider.dart';

class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  @override
  Widget build(BuildContext context) {
    return Consumer<ProductsProvider>(
      child: const Center(
        child: Text("Add some products!"),
      ),
      builder: (ctx, productsData, ch) => productsData.items.isEmpty
          ? ch!
          : ListView.builder(
              itemCount: productsData.items.length,
              itemBuilder: (ctx, i) => ListTile(
                title: Text(productsData.items[i].title),
              ),
            ),
    );
  }
}
