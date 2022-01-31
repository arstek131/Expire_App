/* dart */
import 'package:expire_app/helpers/device_info.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
/* providers */
import 'package:provider/provider.dart';

/* styles */
import '../app_styles.dart' as styles;
import '../enums/ordering.dart';
/* enums */
import '../enums/products_view_mode.dart';
/* helpers */
import '../helpers/user_info.dart' as userinfo;
import '../providers/filters_provider.dart';
import '../providers/products_provider.dart';
/* widgets */
import '../widgets/options_bar.dart';
import '../widgets/product_list_tile_placeholder.dart';
import '../widgets/products_container.dart';

enum ViewMode {
  HideExpired,
  ShowExpired,
}

class ProductsOverviewScreen extends StatefulWidget {
  @override
  _ProductsOverviewScreenState createState() => _ProductsOverviewScreenState();
}

class _ProductsOverviewScreenState extends State<ProductsOverviewScreen>
    with AutomaticKeepAliveClientMixin<ProductsOverviewScreen> {
  String? familyId = userinfo.UserInfo().familyId;
  ProductsViewMode _productsViewMode = ProductsViewMode.List;

  // Keep page state alive
  @override
  bool get wantKeepAlive => true;

  Ordering _ordering = Ordering.ExpiringSoon;
  ViewMode _viewMode = ViewMode.ShowExpired;

  void _toggleProductsViewMode() {
    setState(() {
      if (_productsViewMode == ProductsViewMode.List) {
        _productsViewMode = ProductsViewMode.Grid;
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

  void _toggleViewMode() {
    switch (_viewMode) {
      case ViewMode.HideExpired:
        setState(() {
          _viewMode = ViewMode.ShowExpired;
        });
        break;
      case ViewMode.ShowExpired:
        setState(() {
          _viewMode = ViewMode.HideExpired;
        });
        break;
      default:
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    final filtersData = Provider.of<FiltersProvider>(context, listen: false);

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
              padding: EdgeInsets.only(
                  top: MediaQuery.of(context).orientation == Orientation.portrait ? 10 : 5, left: 20, right: 20, bottom: 0),
              child: Row(
                mainAxisAlignment: DeviceInfo.instance.isPhone ? MainAxisAlignment.spaceBetween : MainAxisAlignment.spaceEvenly,
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
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: () {
                      _toggleViewMode();
                      filtersData.setSingleFilter(hideExpired: !filtersData.filter.hideExpired);
                    },
                    child: Row(
                      children: [
                        FaIcon(
                          _viewMode == ViewMode.HideExpired ? FontAwesomeIcons.solidEyeSlash : FontAwesomeIcons.solidEye,
                          color: styles.ghostWhite,
                          size: 20,
                        ),
                        SizedBox(width: 10),
                        Text(
                          _viewMode == ViewMode.HideExpired ? "Hide expired" : "Show expired",
                          style: styles.subheading,
                        ),
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
                        : FaIcon(
                            FontAwesomeIcons.th,
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
                  return DeviceInfo.instance.isPhone
                      ? Expanded(
                          child: ListView(
                            children: [
                              ProductListTilePlaceholder(first: true),
                              ProductListTilePlaceholder(),
                              ProductListTilePlaceholder(last: true),
                            ],
                          ),
                        )
                      : Align(
                          alignment: Alignment.topLeft,
                          child: Container(
                            width: DeviceInfo.instance.deviceWidth / 2.7,
                            child: Column(
                              children: [
                                ProductListTilePlaceholder(),
                                ProductListTilePlaceholder(),
                                ProductListTilePlaceholder(),
                              ],
                            ),
                          ),
                        );
                } else {
                  return ProductsContainer(_productsViewMode);
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
