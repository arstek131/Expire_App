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
import '../widgets/product_list_tile_placeholder.dart';
import '../widgets/options_bar.dart';

/* helpers */
import '../helpers/user_info.dart' as userinfo;
import '../app_styles.dart' as styles;

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

    return Container(
      height: double.infinity,
      width: double.infinity,
      color: styles.primaryColor, //Colors.indigo,
      child: SafeArea(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            OptionsBar(),
            StreamBuilder(
                stream: FirestoreHelper.instance.getFamilyProductsStream(familyId: userinfo.UserInfo.instance.familyId!),
                builder: (BuildContext ctx, AsyncSnapshot<QuerySnapshot> productSnaphshot) {
                  if (productSnaphshot.connectionState == ConnectionState.waiting) {
                    return Expanded(
                      child: ListView(
                        children: const [
                          ProductListTilePlaceholder(),
                          ProductListTilePlaceholder(),
                        ],
                      ),
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
                              ? Column(
                                  children: [
                                    Image.asset(
                                      "./assets/images/empty_list_products.png",
                                      fit: BoxFit.contain,
                                      color: Color(0xFFFFFF).withOpacity(0.9),
                                      colorBlendMode: BlendMode.modulate,
                                    ),
                                    Text(
                                      "Add a product to start!",
                                      style: styles.subheading,
                                    )
                                  ],
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
                                        imageUrl: productDocs[i]['imageUrl'],
                                      );
                                      return Padding(
                                        padding: const EdgeInsets.all(10.0),
                                        child: ProductListTile(product),
                                      );
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
          ],
        ),
      ),
    );
  }
}
