/* dart */
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

/* providers */
import '../providers/products_provider.dart';
import 'package:provider/provider.dart';

/* widgets */
import '../widgets/product_tile.dart';

class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            height: 100,
            width: double.infinity,
            color: Colors.blue,
            margin: const EdgeInsets.symmetric(vertical: 10),
          ),
          FutureBuilder(
            future: Provider.of<ProductsProvider>(context, listen: false).fetchAndSetProducts(),
            builder: (ctx, snapshot) => snapshot.connectionState == ConnectionState.waiting
                ? const Center(
                    child: CircularProgressIndicator(),
                  )
                : Consumer<ProductsProvider>(
                    child: const Text(
                      "Add some products!",
                      textAlign: TextAlign.center,
                    ),
                    builder: (ctx, productsData, ch) => productsData.items.isEmpty
                        ? ch!
                        : Flexible(
                            child: RefreshIndicator(
                              key: _refreshIndicatorKey,
                              color: Colors.blue,
                              onRefresh: () async {
                                return; //return Provider.of<ProductsProvider>(context, listen: false).fetchAndSetProducts(); ????
                              },
                              child: ListView.builder(
                                itemCount: productsData.items.length,
                                itemBuilder: (ctx, i) => ProductTile(productsData.items[i]), //product item...
                              ),
                            ),
                          ),
                  ),
          ),
        ],
      ),
    );
  }
}
