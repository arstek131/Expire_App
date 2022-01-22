import 'dart:convert';

import 'package:expire_app/enums/expire_status.dart';
import 'package:expire_app/models/product.dart';
import 'package:expire_app/providers/products_provider.dart';
import 'package:expire_app/widgets/eco_product_detail.dart';
import 'package:expire_app/widgets/expire_clip.dart';
import 'package:expire_app/widgets/health_product_detail.dart';
import 'package:expire_app/widgets/shopping_list_detail.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:openfoodfacts/openfoodfacts.dart' as opf;
import 'package:openfoodfacts/utils/TagType.dart';

/* styles */
import '../app_styles.dart' as styles;

enum Pages { Health, Eco, ShoppingList, Score }

class ProductDetails extends StatefulWidget {
  static const routeName = "/product-details";
  const ProductDetails();

  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  final ScrollController _scrollController = ScrollController();

  Pages _page = Pages.Health;

  @override
  Widget build(BuildContext context) {
    String productId = ModalRoute.of(context)?.settings.arguments as String;
    Product _product = Provider.of<ProductsProvider>(context).getItemFromId(productId);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: MediaQuery.of(context).size.height * 0.09,
        backgroundColor: Colors.indigoAccent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: styles.ghostWhite,
            size: 25,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: FaIcon(FontAwesomeIcons.heart),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert),
          )
        ],
      ),
      backgroundColor: styles.primaryColor,
      body: Padding(
        padding: const EdgeInsets.only(top: 15.0),
        child: CustomScrollView(
          controller: _scrollController,
          physics: BouncingScrollPhysics(),
          slivers: <Widget>[
            SliverPersistentHeader(
              pinned: true,
              floating: false,
              delegate: CustomSliverDelegate(
                expandedHeight: 120,
                product: _product,
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.only(left: 8, right: 8, top: 0.9),
              sliver: SliverList(
                key: UniqueKey(),
                delegate: SliverChildListDelegate(
                  [
                    Card(
                      elevation: 5,
                      color: styles.deepIndigo.withOpacity(0.9),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 15.0, horizontal: 25.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            CircleAvatar(
                              backgroundColor: styles.primaryColor,
                              radius: 35,
                              //foregroundImage: , todo: take image of user and insert here
                            ),
                            Column(
                              children: [
                                Text(
                                  'User',
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: styles.ghostWhite,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: styles.currentFontFamily,
                                  ),
                                ),
                                SizedBox(height: 3),
                                SizedBox(
                                  width: 100,
                                  child: Text(
                                    _product.creatorName,
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                    style: const TextStyle(
                                      height: 1,
                                      color: styles.ghostWhite,
                                      fontSize: 16,
                                      fontFamily: styles.currentFontFamily,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            Column(
                              children: [
                                Text(
                                  'Uploaded on date',
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: styles.ghostWhite,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: styles.currentFontFamily,
                                  ),
                                ),
                                Text(
                                  DateFormat('dd MMM yyyy').format(_product.dateAdded),
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: styles.ghostWhite,
                                    fontSize: 14,
                                    fontFamily: styles.currentFontFamily,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    Card(
                      elevation: 5,
                      color: styles.deepIndigo.withOpacity(0.9), //styles.secondaryColor,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            children: [
                              IconButton(
                                onPressed: () => setState(() {
                                  _page = Pages.Health;
                                }),
                                icon: FaIcon(
                                  FontAwesomeIcons.heartbeat,
                                  size: 32,
                                  color: _page == Pages.Health ? Colors.red.shade700 : Colors.grey.shade300,
                                ),
                              ),
                              IconButton(
                                onPressed: () => setState(() {
                                  _page = Pages.Eco;
                                }),
                                icon: FaIcon(
                                  FontAwesomeIcons.leaf,
                                  size: 30,
                                  color: _page == Pages.Eco ? Colors.green : Colors.grey.shade300,
                                ),
                              ),
                              IconButton(
                                onPressed: () => setState(() {
                                  _page = Pages.ShoppingList;
                                }),
                                icon: FaIcon(
                                  FontAwesomeIcons.receipt,
                                  size: 30,
                                  color: _page == Pages.ShoppingList ? Colors.lightBlue.shade300 : Colors.grey.shade300,
                                ),
                              ),
                              IconButton(
                                onPressed: () => setState(() {
                                  _page = Pages.Score;
                                }),
                                icon: FaIcon(
                                  FontAwesomeIcons.font,
                                  size: 30,
                                  color: _page == Pages.Score ? styles.tertiaryColor : Colors.grey.shade300,
                                ),
                              ),
                            ],
                          ),
                          Divider(
                            color: Colors.indigo.withOpacity(0.9),
                            thickness: 1.5,
                          ),
                          if (_page == Pages.Health)
                            HealthProductDetail(
                              product: _product,
                            ),
                          if (_page == Pages.Eco)
                            EcoProductDetail(
                              product: _product,
                            ),
                          if (_page == Pages.ShoppingList)
                            // add to some shopping list
                            ShoppingListDetail(),
                          if (_page == Pages.Score)
                            // add to some shopping list
                            Container(
                              height: 200,
                              color: Colors.black,
                            ),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}

class CustomSliverDelegate extends SliverPersistentHeaderDelegate {
  final double expandedHeight;
  final bool hideTitleWhenExpanded;
  final Product product;

  CustomSliverDelegate({
    required this.expandedHeight,
    required this.product,
    this.hideTitleWhenExpanded = true,
  });

  ExpireStatus _checkExpireStatus(DateTime expireDate) {
    DateTime today = DateTime.now();
    int dateDifferenceInDays = DateTime(product.expiration.year, product.expiration.month, product.expiration.day)
        .difference(
          DateTime(today.year, today.month, today.day),
        )
        .inDays;

    if (dateDifferenceInDays < 0) {
      return ExpireStatus.Expired;
    } else if (dateDifferenceInDays == 0) {
      return ExpireStatus.ExpiringToday;
    } else {
      return ExpireStatus.NotExpired;
    }
  }

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    final appBarSize = expandedHeight - shrinkOffset;
    final cardTopPosition = expandedHeight / 100 - shrinkOffset;
    final proportion = 2 - (expandedHeight / appBarSize);
    final percent = proportion < 0 || proportion > 1 ? 0.0 : proportion;
    return SizedBox(
      height: expandedHeight + expandedHeight / 2,
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 7),
            height: appBarSize < kToolbarHeight ? kToolbarHeight : appBarSize,
            child: AppBar(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
              backgroundColor: styles.deepIndigo.withOpacity(0.9), //styles.secondaryColor,
              automaticallyImplyLeading: false,
              elevation: 10.0,
              title: Opacity(
                opacity: hideTitleWhenExpanded ? 1.0 - percent : 1.0,
                child: Row(
                  children: [
                    Opacity(
                      opacity: 1 - percent,
                      child: SizedBox(
                        height: 45,
                        width: 45,
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: product.image != null
                              ? product.image is String
                                  ? Image.network(
                                      product.image!,
                                      fit: BoxFit.cover,
                                      color: const Color.fromRGBO(255, 255, 255, 0.85),
                                      colorBlendMode: BlendMode.modulate,
                                    )
                                  : Image.file(
                                      product.image!,
                                      fit: BoxFit.cover,
                                      color: const Color.fromRGBO(255, 255, 255, 0.85),
                                      colorBlendMode: BlendMode.modulate,
                                    )
                              : Image.asset(
                                  "assets/images/missing_image_placeholder.png",
                                  fit: BoxFit.cover,
                                ),
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(left: 10.0),
                      child: Container(
                        width: 250,
                        height: 30,
                        alignment: Alignment.centerLeft,
                        child: SizedBox(
                          width: 150,
                          child: Text(
                            product.title,
                            style: styles.heading,
                            overflow: TextOverflow.fade,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            left: 0.0,
            right: 0.0,
            top: cardTopPosition > 0 ? cardTopPosition : 0,
            bottom: 0,
            child: Opacity(
              opacity: percent,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 3),
                child: Card(
                  elevation: 5,
                  color: styles.deepIndigo.withOpacity(0.9), //styles.secondaryColor,
                  child: Container(
                    margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Hero(
                          tag: 'produt-image${product.id}',
                          child: Container(
                            margin: EdgeInsets.only(right: 10),
                            //color: Colors.red,
                            height: max(160 * percent, 40),
                            constraints: BoxConstraints(
                              minWidth: 0,
                              maxWidth: 140,
                            ),
                            decoration: BoxDecoration(
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black38,
                                  blurRadius: 5.0,
                                  offset: Offset(0, 5),
                                  spreadRadius: 2,
                                ),
                              ],
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(10.0),
                              child: product.image != null
                                  ? product.image is String
                                      ? Image.network(
                                          product.image!,
                                          fit: BoxFit.contain,
                                          color: const Color.fromRGBO(255, 255, 255, 0.85),
                                          colorBlendMode: BlendMode.modulate,
                                        )
                                      : Image.file(
                                          product.image!,
                                          fit: BoxFit.fill,
                                          color: const Color.fromRGBO(255, 255, 255, 0.85),
                                          colorBlendMode: BlendMode.modulate,
                                        )
                                  : Image.asset(
                                      "assets/images/missing_image_placeholder.png",
                                      fit: BoxFit.cover,
                                    ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: Container(
                            padding: const EdgeInsets.all(5.0),
                            margin: EdgeInsets.only(top: 20 * percent),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  product.brandName ?? 'No brand',
                                  style: TextStyle(
                                      fontFamily: styles.currentFontFamily,
                                      color: styles.ghostWhite.withOpacity(0.8),
                                      fontWeight: FontWeight.bold),
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  product.title,

                                  style: TextStyle(
                                    height: 0.96,
                                    fontFamily: styles.currentFontFamily,
                                    color: styles.ghostWhite,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ), //styles.heading,
                                  maxLines: 2,

                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  'Expiration: ${DateFormat('dd MMMM yyyy').format(product.expiration)}',
                                  style: styles.subheading,
                                ),
                                SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  product.quantity ?? '',
                                  style: styles.subheading,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            right: 20,
            top: 15,
            child: ExpireClip(_checkExpireStatus(product.expiration), product.expiration),
          ),
        ],
      ),
    );
  }

  @override
  double get maxExtent => expandedHeight + expandedHeight / 2;

  @override
  double get minExtent => kToolbarHeight;

  @override
  bool shouldRebuild(SliverPersistentHeaderDelegate oldDelegate) {
    return true;
  }
}
