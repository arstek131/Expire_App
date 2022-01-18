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
import '../enums/ordering.dart';

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

  Ordering _ordering = Ordering.ExpiringSoon;

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

  void _toggleOrdering() {
    switch (_ordering) {
      case Ordering.ExpiringSoon:
        setState(() {
          _ordering = Ordering.ExpiringLast;
        });
        break;
      case Ordering.ExpiringLast:
        setState(() {
          _ordering = Ordering.ExpiringSoon;
        });
        break;
      default:
        break;
    }
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
                    onTap: () {
                      _toggleOrdering();
                      Provider.of<ProductsProvider>(context, listen: false).sortProducts(_ordering);
                    },
                    child: Row(
                      children: [
                        FaIcon(
                          _ordering == Ordering.ExpiringSoon ? FontAwesomeIcons.sortAmountUp : FontAwesomeIcons.sortAmountDown,
                          color: styles.ghostWhite,
                        ),
                        SizedBox(width: 10),
                        Text(
                          _ordering == Ordering.ExpiringSoon ? "Expiring soon" : "Expiring last",
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
                        children: [
                          ProductListTilePlaceholder(first: true),
                          ProductListTilePlaceholder(),
                          ProductListTilePlaceholder(last: true),
                        ],
                      ),
                    );
                  } else {
                    return ProductsContainer(_productsViewMode);
                  }
                }),
          ],
        ),
      ),
    );
  }
}
