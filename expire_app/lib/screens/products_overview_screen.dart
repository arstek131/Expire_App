/* dart */
import 'package:expire_app/helpers/firebase_auth_helper.dart';
import 'package:expire_app/helpers/firestore_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/rendering.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/* providers */
import '../providers/products_provider.dart';
import '../providers/bottom_navigator_bar_size_provider.dart';

/* models */
import '../models/product.dart';

/* widgets */
import '../widgets/product_list_tile.dart';

/* helpers */
import '../helpers/user_info.dart' as userinfo;

class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen>
    with AutomaticKeepAliveClientMixin<ProductsOverviewScreen> {
  String? familyId;

  // Keep page state alive
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    super.build(context);

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
            child: const Center(
              child: Text(
                "SEARCH BAR, FILTERING AND VIEW CHANGE",
                textAlign: TextAlign.center,
              ),
            ),
          ),
          StreamBuilder(
              stream: FirestoreHelper.instance.getFamilyProductsStream(familyId: userinfo.UserInfo.instance.familyId!),
              builder: (BuildContext ctx, AsyncSnapshot<QuerySnapshot> productSnaphshot) {
                if (productSnaphshot.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                } else {
                  final productDocs = productSnaphshot.data!.docs;

                  return Flexible(
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
                        onRefresh: () {
                          return Future.value(true);
                        },
                        child: !productSnaphshot.hasData || productDocs.isEmpty
                            ? const Text(
                                "Add some products!",
                                textAlign: TextAlign.center,
                              )
                            : ListView.builder(
                                itemCount: productDocs.length + 1,
                                itemBuilder: (ctx, i) {
                                  if (i < productDocs.length) {
                                    Product product = Product(
                                      id: productDocs[i].id,
                                      title: productDocs[i]['title'],
                                      expiration: DateTime.parse(productDocs[i]['expiration']),
                                      creatorId: productDocs[i]['creatorId'],
                                      imageUrl: null,
                                    );
                                    return ProductListTile(product);
                                  } else {
                                    return const SizedBox(
                                      height: 80,
                                    );
                                  }
                                }, //product item...
                              ),
                      ),
                    ),
                  );
                }
              }),

          /*FutureBuilder(
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
                                      return ProductListTile(productsData.items[i]);
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
          ),*/
        ],
      ),
    );
  }
}
