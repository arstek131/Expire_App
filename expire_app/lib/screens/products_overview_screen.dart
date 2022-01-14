/* dart */
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/* providers */
import 'package:provider/provider.dart';
import '../providers/products_provider.dart';

/* widgets */
import '../widgets/options_bar.dart';
import '../widgets/products_container.dart';
import '../widgets/product_list_tile_placeholder.dart';

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
  ProductsViewMode _productsViewMode = ProductsViewMode.List;

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
            FutureBuilder(
                future: Provider.of<ProductsProvider>(context, listen: false).fetchProducts(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return Expanded(
                      child: ListView(
                        children: const [
                          ProductListTilePlaceholder(),
                          ProductListTilePlaceholder(),
                          ProductListTilePlaceholder(),
                        ],
                      ),
                    );
                  } else {
                    return ProductsContainer(_productsViewMode);
                  }
                }),

            /*StreamBuilder(
              stream: FirestoreHelper.instance.getFamilyProductsStream(familyId: familyId!),
              builder: (BuildContext ctx, AsyncSnapshot<QuerySnapshot> productSnaphshot) {
                if (productSnaphshot.connectionState == ConnectionState.waiting) {
                  return Expanded(
                    child: ListView(
                      children: const [
                        ProductListTilePlaceholder(),
                        ProductListTilePlaceholder(),
                        ProductListTilePlaceholder(),
                      ],
                    ),
                  );
                } else if (productSnaphshot.connectionState == ConnectionState.active) {
                  final changedDocs = productSnaphshot.data!.docChanges;

                  for (var changedDoc in changedDocs) {
                    Product tmp = Product(
                      id: changedDoc.doc.id,
                      title: changedDoc.doc['title'],
                      expiration: DateTime.parse(changedDoc.doc['expiration']),
                      creatorId: changedDoc.doc['creatorId'],
                      image: changedDoc.doc['imageUrl'],
                    );
                    Provider.of<ProductsProvider>(context, listen: false).modifyProduct(tmp);
                    //print(productData.doc['title']);
                  }

                  return Consumer<ProductsProvider>(
                    builder: (_, data, __) => Flexible(
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
                          child: data.items.isEmpty //!productSnaphshot.hasData || changedDocs.isEmpty
                              ? Stack(
                                  alignment: Alignment.center,
                                  children: [
                                    Positioned.fill(
                                      right: -300,
                                      top: 300,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          boxShadow: customShadow,
                                          shape: BoxShape.circle,
                                          color: Colors.white12,
                                        ),
                                      ),
                                    ),
                                    Positioned.fill(
                                      right: -600,
                                      top: -100,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          boxShadow: customShadow,
                                          shape: BoxShape.circle,
                                          color: Colors.white12,
                                        ),
                                      ),
                                    ),
                                    Positioned.fill(
                                      top: 200,
                                      child: RichText(
                                        textAlign: TextAlign.center,
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "Click the  ",
                                              style: styles.subheading,
                                            ),
                                            WidgetSpan(
                                              child: FaIcon(
                                                FontAwesomeIcons.plusCircle,
                                                size: 16,
                                                color: Colors.white,
                                              ),
                                            ),
                                            TextSpan(
                                              text: "  button to start adding products!",
                                              style: styles.subheading,
                                            ),
                                          ],
                                        ),
                                      ),
                                    )
                                  ],
                                )
                              : Stack(
                                  children: [
                                    Positioned.fill(
                                      right: -300,
                                      top: 300,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          boxShadow: customShadow,
                                          shape: BoxShape.circle,
                                          color: Colors.white12,
                                        ),
                                      ),
                                    ),
                                    Positioned.fill(
                                      right: -600,
                                      top: -100,
                                      child: Container(
                                        decoration: BoxDecoration(
                                          boxShadow: customShadow,
                                          shape: BoxShape.circle,
                                          color: Colors.white12,
                                        ),
                                      ),
                                    ),
                                    if (_productsViewMode == ProductsViewMode.List)
                                      ListView.builder(
                                          itemCount: data.items.length + 1,
                                          itemBuilder: (ctx, i) {
                                            if (i < data.items.length) {
                                              Product product = Product(
                                                id: data.items[i].id,
                                                title: data.items[i].title,
                                                expiration: data.items[i].expiration,
                                                creatorId: data.items[i].creatorId,
                                                image: data.items[i].image,
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
                                          }
                                          /*itemCount: productDocs.length + 1,
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
                                              },*/ //product item...
                                          ),

                                    /*else if (_productsViewMode == ProductsViewMode.Grid)
                                    GridView.builder(
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        crossAxisCount: 2, mainAxisSpacing: 10, crossAxisSpacing: 10,

                                        //childAspectRatio: 1,
                                      ),
                                      itemCount: changedDocs.length + 1,
                                      itemBuilder: (ctx, i) {
                                        if (i < changedDocs.length) {
                                          Product product = Product(
                                            id: changedDocs[i].id,
                                            title: changedDocs[i]['title'],
                                            expiration: DateTime.parse(changedDocs[i]['expiration']),
                                            creatorId: changedDocs[i]['creatorId'],
                                            imageUrl: changedDocs[i]['imageUrl'],
                                          );
                                          return Padding(
                                            padding:
                                                (i % 2 == 0) ? const EdgeInsets.only(left: 10) : const EdgeInsets.only(right: 10),
                                            child: ProductGridTile(product),
                                          );
                                        } else {
                                          return SizedBox(
                                            height: 0, // ???
                                          );
                                        }
                                      },
                                    )
                                  else if (_productsViewMode == ProductsViewMode.ListGrid)
                                    GridView.builder(
                                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                                        mainAxisSpacing: 10,
                                        crossAxisCount: 1,
                                        //childAspectRatio: 1,
                                      ),
                                      itemCount: changedDocs.length + 1,
                                      itemBuilder: (ctx, i) {
                                        if (i < changedDocs.length) {
                                          Product product = Product(
                                            id: changedDocs[i].id,
                                            title: changedDocs[i]['title'],
                                            expiration: DateTime.parse(changedDocs[i]['expiration']),
                                            creatorId: changedDocs[i]['creatorId'],
                                            imageUrl: changedDocs[i]['imageUrl'],
                                          );
                                          return ProductSingleGridTile(product);
                                        } else {
                                          return SizedBox(
                                            height: 0, // ???
                                          );
                                        }
                                      },
                                    ),*/
                                  ],
                                ),
                        ),
                      ),
                    ),
                  );
                } else {
                  return Center(
                    child: Text("Something went wrong"),
                  );
                }
              },
            ),*/
          ],
        ),
      ),
    );
  }
}
