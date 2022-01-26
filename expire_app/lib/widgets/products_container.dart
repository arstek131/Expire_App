/* dart */
import 'package:expire_app/screens/product_details.dart';
import 'package:expire_app/widgets/product_grid_tile.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/* providers */
import '../providers/products_provider.dart';
import '../providers/bottom_navigator_bar_size_provider.dart';
import '../providers/filters_provider.dart';

/* models */
import '../models/product.dart';

/* helpers */
import '../helpers/device_info.dart' as deviceInfo;

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

  bool first = true;
  bool last = true;

  @override
  _ProductsContainerState createState() => _ProductsContainerState();
}

class _ProductsContainerState extends State<ProductsContainer> {
  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  deviceInfo.DeviceInfo _deviceInfo = deviceInfo.DeviceInfo.instance;

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
                    Row(
                      children: [
                        Flexible(
                          flex: _deviceInfo.isTablet ? 4 : 1,
                          child: Consumer<FiltersProvider>(
                            builder: (_, filterData, __) {
                              final filteredProducts = data.getItems(filter: filterData.filter);

                              if (widget._productsViewMode == ProductsViewMode.List) {
                                return ListView.builder(
                                  controller: ScrollController(initialScrollOffset: 0),
                                  physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                                  itemCount: filteredProducts.length + 1,
                                  itemBuilder: (ctx, i) {
                                    if (!filteredProducts.isEmpty) {
                                      if (i < filteredProducts.length) {
                                        Product product = filteredProducts[i];

                                        bool first = (i == 0);
                                        bool last = (i == data.items.length - 1);

                                        return GestureDetector(
                                          onTap: () =>
                                              Navigator.of(context).pushNamed(ProductDetails.routeName, arguments: product.id),
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
                                    } else {
                                      return Container(
                                        margin: EdgeInsets.only(top: 100),
                                        child: Text(
                                          "No products found.",
                                          style: styles.subheading,
                                          textAlign: TextAlign.center,
                                        ),
                                      );
                                    }
                                  },
                                );
                              } else {
                                return Container(
                                  padding: EdgeInsets.only(bottom: 70),
                                  child: GridView.builder(
                                    padding: EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                                    controller: ScrollController(initialScrollOffset: 0),
                                    physics: BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: _deviceInfo.isPhonePotrait(context)
                                          ? 2
                                          : _deviceInfo.isPhoneLandscape(context)
                                              ? 4
                                              : _deviceInfo.isTabletPotrait(context)
                                                  ? 2
                                                  : 3,
                                      childAspectRatio: 1,
                                      crossAxisSpacing: 5,
                                      mainAxisSpacing: 5,
                                    ),
                                    itemCount: filteredProducts.length,
                                    itemBuilder: (ctx, i) {
                                      if (!filteredProducts.isEmpty) {
                                        Product product = filteredProducts[i];

                                        bool first = (i == 0);
                                        bool second = (i == 1);
                                        bool second_last = (i == data.items.length - 2);
                                        bool last = (i == data.items.length - 1);

                                        return GestureDetector(
                                          onTap: () =>
                                              Navigator.of(context).pushNamed(ProductDetails.routeName, arguments: product.id),
                                          child: Container(
                                            padding: EdgeInsets.all(5.0),
                                            decoration: BoxDecoration(
                                              color: styles.ghostWhite,
                                              //borderRadius: BorderRadius.all(Radius.circular(15)
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(first ? 15.0 : 0.0),
                                                topRight: Radius.circular(second ? 15.0 : 0.0),
                                                bottomRight: Radius.circular(
                                                  last && filteredProducts.length.isEven ? 15.0 : 0.0,
                                                ),
                                                bottomLeft: Radius.circular(
                                                  second_last && filteredProducts.length.isEven
                                                      ? 15.0
                                                      : last && filteredProducts.length.isOdd
                                                          ? 15.0
                                                          : 0.0,
                                                ),
                                              ),
                                            ),
                                            child: ProductGridTile(
                                                product, first, second, second_last, last, filteredProducts.length.isEven),
                                          ),
                                        );
                                      } else {
                                        return Container(
                                          margin: EdgeInsets.only(top: 100),
                                          child: Text(
                                            "No products found.",
                                            style: styles.subheading,
                                            textAlign: TextAlign.center,
                                          ),
                                        );
                                      }
                                    },
                                  ),
                                );
                              }
                            },
                          ),
                        ),
                        if (_deviceInfo.isTablet)
                          Flexible(
                            child: Container(color: Colors.red),
                            flex: 7,
                          ) // todo: idea: remove spacing on the right, make like spark, shadow dropping and neat cut
                      ],
                    )
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
