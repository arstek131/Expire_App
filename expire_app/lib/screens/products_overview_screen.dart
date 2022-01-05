/* dart */
import 'package:expire_app/helpers/firebase_auth_helper.dart';
import 'package:expire_app/helpers/firestore_helper.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/rendering.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/* providers */
import '../providers/products_provider.dart';
import '../providers/bottom_navigator_bar_size_provider.dart';

/* models */
import '../models/product.dart';

/* widgets */
import '../widgets/product_list_tile.dart';
import '../widgets/product_grid_tile.dart';
import '../widgets/product_single_grid_tile.dart';
import '../widgets/product_list_tile_placeholder.dart';
import '../widgets/options_bar.dart';

/* enums */
import '../enums/products_view_mode.dart';

/* helpers */
import '../helpers/user_info.dart' as userinfo;

/* styles */
import '../app_styles.dart' as styles;

class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen>
    with AutomaticKeepAliveClientMixin<ProductsOverviewScreen> {
  String? familyId = userinfo.UserInfo.instance.familyId;
  ProductsViewMode _productsViewMode = ProductsViewMode.Grid;

  // Keep page state alive
  @override
  bool get wantKeepAlive => true;

  void _toggleProductsViewMode() {
    setState(() {
      if (_productsViewMode == ProductsViewMode.List) {
        _productsViewMode = ProductsViewMode.Grid;
      } else if (_productsViewMode == ProductsViewMode.Grid) {
        _productsViewMode = ProductsViewMode.ListGrid;
      } else {
        _productsViewMode = ProductsViewMode.List;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

    return Container(
      height: double.infinity,
      width: double.infinity,
      color: styles.primaryColor,
      child: SafeArea(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            OptionsBar(),
            Container(
              margin: const EdgeInsets.only(bottom: 0),
              padding: EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: null,
                    child: Row(
                      children: [
                        FaIcon(
                          FontAwesomeIcons.sort,
                          color: styles.ghostWhite,
                        ),
                        SizedBox(width: 10),
                        Text(
                          "Expiring soon",
                          style: styles.subheading,
                        )
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: _toggleProductsViewMode,
                    icon: _productsViewMode == ProductsViewMode.List
                        ? FaIcon(
                            FontAwesomeIcons.thList,
                            color: styles.ghostWhite,
                            size: 21,
                          )
                        : _productsViewMode == ProductsViewMode.Grid
                            ? FaIcon(
                                FontAwesomeIcons.th,
                                color: styles.ghostWhite,
                                size: 21,
                              )
                            : FaIcon(
                                FontAwesomeIcons.thLarge,
                                color: styles.ghostWhite,
                                size: 21,
                              ),
                    color: styles.ghostWhite,
                  ),
                ],
              ),
            ),
            StreamBuilder(
              // todo: don't user streambuilder but products provider with listener on all products to store locally
              stream: FirestoreHelper.instance.getFamilyProductsStream(familyId: familyId!),
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
                            : _productsViewMode == ProductsViewMode.List
                                ? ListView.builder(
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
                                  )
                                : _productsViewMode == ProductsViewMode.Grid
                                    ? GridView.builder(
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10,

                                          //childAspectRatio: 1,
                                        ),
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
                                              padding: (i % 2 == 0)
                                                  ? const EdgeInsets.only(left: 10)
                                                  : const EdgeInsets.only(right: 10),
                                              child: ProductGridTile(product),
                                            );
                                          } else {
                                            return SizedBox(
                                              height: 0, // ???
                                            );
                                          }
                                        },
                                      )
                                    : GridView.builder(
                                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                          mainAxisSpacing: 10,
                                          crossAxisCount: 1,
                                          //childAspectRatio: 1,
                                        ),
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
                                            return ProductSingleGridTile(product);
                                          } else {
                                            return SizedBox(
                                              height: 0, // ???
                                            );
                                          }
                                        },
                                      ),
                      ),
                    ),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
