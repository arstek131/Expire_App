import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expire_app/providers/products_provider.dart';
import 'package:expire_app/widgets/image_dispatcher.dart';
import 'package:expire_app/widgets/shopping_list_element_tile.dart';
import 'package:expire_app/widgets/shopping_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:circular_menu/circular_menu.dart';

/* providers */
import 'package:provider/provider.dart';
import '../providers/shopping_list_provider.dart';
import '../providers/tile_pointer_provider.dart';

/* models */
import '../models/product.dart';
import '../models/shopping_list_element.dart';

/* styles */
import '../app_styles.dart' as styles;

class ShoppingListDetailScreen extends StatefulWidget {
  static const routeName = "/shopping-list-details";

  const ShoppingListDetailScreen();

  @override
  _ShoppingListDetailScreenState createState() => _ShoppingListDetailScreenState();
}

class _ShoppingListDetailScreenState extends State<ShoppingListDetailScreen> {
  GlobalKey<CircularMenuState> menuKey = GlobalKey<CircularMenuState>();

  @override
  Widget build(BuildContext context) {
    GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

    String listId = ModalRoute.of(context)!.settings.arguments as String;
    List<ShoppingListElement> products = Provider.of<ShoppingListProvider>(context).getProductsFromListId(listId: listId);

    return Scaffold(
      appBar: AppBar(
        title: Text(
          Provider.of<ShoppingListProvider>(context).shoppingLists.firstWhere((element) => element.id == listId).title,
          textAlign: TextAlign.center,
        ),
        toolbarHeight:
            MediaQuery.of(context).size.height * (MediaQuery.of(context).orientation == Orientation.portrait ? 0.09 : 0.15),
        backgroundColor: Colors.indigoAccent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: styles.ghostWhite,
            size: 25,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [],
      ),
      backgroundColor: styles.primaryColor,
      body: SafeArea(
        child: products.isEmpty
            ? Center(
                child: RichText(
                  textAlign: TextAlign.center,
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Click the  ",
                        style: styles.subheading,
                      ),
                      WidgetSpan(
                        style: TextStyle(height: 1.6),
                        child: Icon(
                          Icons.menu,
                          size: 20,
                          color: Colors.white,
                        ),
                      ),
                      TextSpan(
                        text: "  button to add your first product!",
                        style: styles.subheading,
                      ),
                    ],
                  ),
                ),
              )
            : RefreshIndicator(
                key: _refreshIndicatorKey,
                color: Colors.blue,
                onRefresh: () {
                  return Provider.of<ShoppingListProvider>(context, listen: false).fetchShoppingLists();
                },
                child: Container(
                  margin: EdgeInsets.only(top: 10),
                  child: ListView.builder(
                    physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                    itemCount: products.length + 1,
                    itemBuilder: (context, index) {
                      if (index < products.length) {
                        return ChangeNotifierProvider(
                          create: (_) => TilePointerProvider(),
                          child: ShoppingListElementTile(listId, products[index]),
                        );
                      } else {
                        return SizedBox(height: 120);
                      }
                    },
                  ),
                ),
              ),
      ),
      floatingActionButton: CircularMenu(
        key: menuKey,
        alignment: Alignment.bottomRight,
        animationDuration: Duration(milliseconds: 500),
        curve: Curves.bounceOut,
        radius: 70,
        reverseCurve: Curves.fastOutSlowIn,
        // first item angle
        startingAngleInRadian: pi,
        // last item angle
        endingAngleInRadian: pi + pi / 2,
        toggleButtonMargin: 10.0,
        toggleButtonPadding: 10.0,
        toggleButtonSize: 40.0,
        toggleButtonBoxShadow: [
          BoxShadow(
            color: Colors.black54,
            blurRadius: 10,
          ),
        ],
        toggleButtonAnimatedIconData: AnimatedIcons.menu_close,
        toggleButtonIconColor: styles.ghostWhite,
        items: [
          CircularMenuItem(
            enableBadge: true,
            badgeColor: Colors.transparent,
            badgeRadius: 40,
            badgeLabel: "From existing",
            badgeTextStyle: styles.subheading,
            badgeLeftOffet: -80,
            badgeTopOffet: -5,
            icon: Icons.search,
            iconSize: 35,
            onTap: () async {
              menuKey.currentState!.reverseAnimation();

              List<Product>? params = await showModalBottomSheet<List<Product>>(
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                backgroundColor: styles.primaryColor,
                context: context,
                builder: (modalContext) {
                  List<Product> selectedProducts = [];
                  return StatefulBuilder(builder: (BuildContext context, StateSetter mystate) {
                    return Container(
                      height: MediaQuery.of(context).size.height * 0.9,
                      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
                      child: Container(
                        color: styles.secondaryColor.withOpacity(0.95),
                        child: Stack(
                          children: [
                            Column(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                Container(
                                  margin: const EdgeInsets.only(top: 5, bottom: 20),
                                  height: 5,
                                  width: MediaQuery.of(modalContext).size.width * 0.4,
                                  decoration: BoxDecoration(
                                    color: styles.ghostWhite.withOpacity(0.6),
                                    borderRadius: BorderRadius.vertical(
                                      top: Radius.circular(3),
                                    ),
                                    boxShadow: <BoxShadow>[
                                      BoxShadow(color: Colors.black54, blurRadius: 15.0, offset: Offset(0.0, 0.75)),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: Consumer<ProductsProvider>(
                                    builder: (_, data, __) {
                                      List<Product> products = data.items;
                                      if (data.items.isEmpty) {
                                        return Center(
                                          child: Padding(
                                            padding: const EdgeInsets.all(30.0),
                                            child: Text(
                                              "No products. Add a new one from the main screen!",
                                              style: styles.subheading,
                                              textAlign: TextAlign.center,
                                            ),
                                          ),
                                        );
                                      }
                                      return ListView.builder(
                                        physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                                        itemCount: products.length,
                                        itemBuilder: (context, i) {
                                          bool selected = selectedProducts.any((element) => element.id == products[i].id);
                                          return Card(
                                            margin: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                                            elevation: 10,
                                            color: selected ? Colors.grey.shade400 : styles.ghostWhite,
                                            child: ListTile(
                                              leading: SizedBox(
                                                height: 50,
                                                width: 50,
                                                child: ClipRRect(
                                                  borderRadius: BorderRadius.circular(10.0),
                                                  child: ImageDispatcher(products[i].image),
                                                ),
                                              ),
                                              subtitle: Row(
                                                mainAxisAlignment: MainAxisAlignment.start,
                                                children: [
                                                  const Icon(
                                                    Icons.person,
                                                    color: Colors.grey,
                                                    size: 20,
                                                  ),
                                                  SizedBox(width: 4),
                                                  Text(
                                                    "${products[i].creatorName}",
                                                    overflow: TextOverflow.fade,
                                                    style: const TextStyle(
                                                      color: Colors.black,
                                                      fontSize: 15,
                                                      fontFamily: styles.currentFontFamily,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              title: Text(
                                                products[i].title,
                                                style: TextStyle(
                                                  fontFamily: styles.currentFontFamily,
                                                  fontWeight: FontWeight.normal,
                                                ),
                                              ),
                                              trailing: selected ? Icon(Icons.check_circle, color: Colors.green) : null,
                                              onTap: () {
                                                if (!selected) {
                                                  mystate(() {
                                                    selectedProducts.add(products[i]);
                                                  });
                                                } else {
                                                  mystate(() {
                                                    selectedProducts.removeWhere((element) => element.id == products[i].id);
                                                  });
                                                }
                                              },
                                            ),
                                          );
                                        },
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                            Positioned(
                              bottom: 30,
                              right: 30,
                              child: Card(
                                elevation: 10,
                                color: styles.ghostWhite,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(50),
                                ),
                                margin: EdgeInsets.zero,
                                child: IconButton(
                                  onPressed: () => Navigator.of(context).pop(selectedProducts),
                                  icon: Icon(
                                    Icons.add,
                                    color: Colors.black87,
                                    size: 28,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  });
                },
              );

              if (params == null) {
                return;
              } else {
                for (final product in params) {
                  // todo: change with BATCH write! much more professional. Single atomic write.
                  await Provider.of<ShoppingListProvider>(context, listen: false)
                      .addElementToShoppingList(listId: listId, shoppingListElementTitle: product.title, quantity: 1);
                  //await Future.delayed(Duration(seconds: 3));
                }
              }
            },
            padding: 10.0,
          ),
          CircularMenuItem(
            iconSize: 35,
            enableBadge: true,
            badgeColor: Colors.transparent,
            badgeRadius: 40,
            badgeLabel: "New product",
            badgeTextStyle: styles.subheading,
            badgeLeftOffet: -80,
            badgeTopOffet: -5,
            icon: Icons.add,
            onTap: () async {
              menuKey.currentState!.reverseAnimation();

              String productName = "";
              int quantity = 0;
              List<dynamic>? params = await showModalBottomSheet<List<dynamic>>(
                isScrollControlled: true,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10.0),
                ),
                backgroundColor: styles.primaryColor,
                context: context,
                builder: (context) {
                  return Stack(
                    children: [
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: EdgeInsets.only(left: 25, right: 30, top: 20, bottom: MediaQuery.of(context).viewInsets.bottom),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "Product name:",
                              textAlign: TextAlign.start,
                              style: styles.heading,
                            ),
                            TextField(
                              style: styles.subheading,
                              cursorColor: styles.ghostWhite,
                              decoration: InputDecoration(
                                isDense: true,
                                enabledBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: styles.ghostWhite,
                                  ),
                                ),
                                focusedBorder: UnderlineInputBorder(
                                  borderSide: BorderSide(
                                    color: styles.ghostWhite,
                                  ),
                                ),
                              ),
                              autofocus: true,
                              onChanged: (newValue) {
                                productName = newValue;
                              },
                              onSubmitted: (newValue) {
                                productName = newValue;
                              },
                            ),
                            SizedBox(height: 20),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Product quantity:",
                                      textAlign: TextAlign.start,
                                      style: styles.heading,
                                    ),
                                    SizedBox(width: 8),
                                    SizedBox(
                                      width: 50,
                                      child: TextField(
                                        keyboardType: TextInputType.numberWithOptions(decimal: false),
                                        style: styles.subheading,
                                        cursorColor: styles.ghostWhite,
                                        textAlign: TextAlign.center,
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
                                          isDense: true,
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: styles.ghostWhite,
                                            ),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: styles.ghostWhite,
                                            ),
                                          ),
                                        ),
                                        autofocus: true,
                                        onChanged: (newValue) {
                                          print(newValue);
                                          double? tmp = double.tryParse(newValue);
                                          quantity = tmp == null ? 1 : tmp.round();
                                        },
                                        onSubmitted: (newValue) {
                                          double? tmp = double.tryParse(newValue);
                                          quantity = tmp == null ? 1 : tmp.round();
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                                Card(
                                  elevation: 10,
                                  color: styles.ghostWhite,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(50),
                                  ),
                                  margin: EdgeInsets.zero,
                                  child: IconButton(
                                    onPressed: () {
                                      if (productName == "" || quantity == 0) {
                                        Navigator.of(context).pop();
                                      } else {
                                        Navigator.of(context).pop([productName, quantity]);
                                      }
                                    },
                                    icon: Icon(
                                      Icons.add,
                                      color: Colors.black87,
                                      size: 26,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 30),
                          ],
                        ),
                      ),
                      Positioned(
                        top: 2,
                        right: 4,
                        child: IconButton(
                          onPressed: () {
                            Navigator.of(context).pop();
                          },
                          icon: FaIcon(
                            FontAwesomeIcons.timesCircle,
                            color: styles.ghostWhite,
                            size: 22,
                          ),
                        ),
                      ),
                    ],
                  );
                },
              );

              if (params == null) {
                return;
              } else {
                Provider.of<ShoppingListProvider>(context, listen: false)
                    .addElementToShoppingList(listId: listId, shoppingListElementTitle: params[0], quantity: params[1]);
              }
            },
            padding: 10.0,
          ),
        ],
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }
}
