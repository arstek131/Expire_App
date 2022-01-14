/* dart */
import 'package:expire_app/screens/product_details.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/* providers */
import '../providers/products_provider.dart';
import '../providers/bottom_navigator_bar_size_provider.dart';

/* models */
import '../models/product.dart';

/* widgets */
import '../widgets/product_list_tile.dart';

/* enums */
import '../enums/products_view_mode.dart';

/* helpers */

/* styles */
import '../app_styles.dart' as styles;

class ProductsContainer extends StatefulWidget {
  final ProductsViewMode _productsViewMode;

  ProductsContainer(this._productsViewMode);

  @override
  _ProductsContainerState createState() => _ProductsContainerState();
}

class _ProductsContainerState extends State<ProductsContainer> {
  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

  @override
  Widget build(BuildContext context) {
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
            return Provider.of<ProductsProvider>(context, listen: false).fetchProducts();
          },
          child: Consumer<ProductsProvider>(
            builder: (_, data, __) {
              if (data.items.isEmpty) {
                return Stack(
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
                );
              } else {
                return Stack(
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
                    if (widget._productsViewMode == ProductsViewMode.List)
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
                            bool first = (i == 0);
                            bool last = (i == data.items.length - 1);
                            return GestureDetector(
                              onTap: () => Navigator.of(context).pushNamed(ProductDetails.routeName, arguments: product),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 0.6, horizontal: 10),
                                child: ProductListTile(product, first, last),
                              ),
                            );
                          } else {
                            return const SizedBox(
                              height: 80,
                            );
                          }
                        },
                      ),
                  ],
                );
              }
            },
          ),
        ),
      ),
    );
  }

  List<BoxShadow> customShadow = [
    BoxShadow(
      color: Colors.indigoAccent.withOpacity(0.5),
      spreadRadius: -5,
      offset: Offset(-5, -5),
      blurRadius: 30,
    ),
    BoxShadow(
      color: Colors.indigo.shade900.withOpacity(0.2),
      spreadRadius: 2,
      offset: Offset(7, 7),
      blurRadius: 20,
    )
  ];
}
