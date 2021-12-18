/* dart */
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/rendering.dart';

/* providers */
import '../providers/products_provider.dart';
import '../providers/bottom_navigator_bar_size_provider.dart';

/* models */

/* widgets */
import '../widgets/product_tile.dart';

class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen> {
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
            child: Center(
              child: Text(
                "SEARCH BAR, FILTERING AND VIEW CHANGE",
                textAlign: TextAlign.center,
              ),
            ),
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
                            child: NotificationListener<ScrollNotification>(
                              onNotification: (ScrollNotification scrollInfo) {
                                if (scrollInfo is UserScrollNotification) {
                                  // scrolling up
                                  if (scrollInfo.direction == ScrollDirection.forward) {
                                    Provider.of<BottomNavigationBarSizeProvider>(context, listen: false).notifyGrow();
                                  } else if (scrollInfo.direction == ScrollDirection.reverse) {
                                    // scrolling down
                                    Provider.of<BottomNavigationBarSizeProvider>(context, listen: false).notifyShrink();
                                  }
                                }
                                return true;
                              },
                              child: RefreshIndicator(
                                key: _refreshIndicatorKey,
                                color: Colors.blue,
                                onRefresh: Provider.of<ProductsProvider>(context, listen: false).fetchAndSetProducts,
                                child: ListView.builder(
                                  itemCount: productsData.items.length + 1,
                                  itemBuilder: (ctx, i) {
                                    if (i < productsData.items.length) {
                                      return ProductTile(productsData.items[i]);
                                    } else {
                                      return const SizedBox(
                                        height: 80,
                                      );
                                    }
                                  }, //product item...
                                ),
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
