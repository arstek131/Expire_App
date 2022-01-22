/* flutter  */
import 'package:expire_app/models/shopping_list.dart';
import 'package:expire_app/widgets/shopping_lists_container.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/* provider */
import 'package:provider/provider.dart';
import '../providers/shopping_list_provider.dart';

/* widgets */
import '../widgets/options_bar.dart';
import '../widgets/product_list_tile_placeholder.dart';

/* styles */
import '../app_styles.dart' as styles;

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen();

  @override
  _ShoppingListScreenState createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> with AutomaticKeepAliveClientMixin<ShoppingListScreen> {
  // Keep page state alive
  @override
  bool get wantKeepAlive => true;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: styles.primaryColor,
      child: SafeArea(
        child: Column(
          //mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Column(
              children: [
                Container(
                  margin: EdgeInsets.only(top: MediaQuery.of(context).orientation == Orientation.portrait ? 30.0 : 10.0),
                  width: double.infinity,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        styles.primaryColor,
                        styles.primaryColor.withOpacity(0.6),
                      ],
                      stops: [0.9, 1],
                    ),
                    shape: BoxShape.rectangle,
                    color: Colors.pinkAccent,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.indigo.shade700,
                        offset: const Offset(0, 10),
                        blurRadius: 5.0,
                        spreadRadius: 1,
                      )
                    ],
                  ),
                  child: Padding(
                    padding: EdgeInsets.only(
                      top: MediaQuery.of(context).orientation == Orientation.portrait ? 56 : 0,
                      left: 20,
                      right: 30,
                      bottom: MediaQuery.of(context).orientation == Orientation.portrait ? 30 : 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Shopping lists",
                          style: styles.title,
                        ),
                        GestureDetector(
                          onTap: () async {
                            int uniqueId = Provider.of<ShoppingListProvider>(context, listen: false).getUniqueNameId();
                            String? title = await showModalBottomSheet<String>(
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              backgroundColor: styles.primaryColor,
                              context: context,
                              builder: (context) {
                                return Padding(
                                  padding: EdgeInsets.only(
                                      left: 40, right: 40, top: 20, bottom: 10 + MediaQuery.of(context).viewInsets.bottom),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "List name:",
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
                                        onSubmitted: (newValue) {
                                          Navigator.of(context).pop(newValue);
                                        },
                                      ),
                                    ],
                                  ),
                                );
                              },
                            );

                            if (title == "") {
                              Provider.of<ShoppingListProvider>(context, listen: false)
                                  .addShoppingList(title: "Shopping list (${uniqueId})");
                            } else {
                              Provider.of<ShoppingListProvider>(context, listen: false).addShoppingList(title: title!);
                            }
                          },
                          child: Card(
                            elevation: 10,
                            color: styles.ghostWhite,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Padding(
                              padding: EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                              child: Row(
                                children: [
                                  Text(
                                    "Add list",
                                    style: TextStyle(
                                      fontFamily: styles.currentFontFamily,
                                      fontSize: 15,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  SizedBox(width: 2),
                                  Icon(
                                    Icons.add,
                                    color: Colors.black87,
                                    size: 26,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 20),
            FutureBuilder(
                future: Provider.of<ShoppingListProvider>(context, listen: false).fetchShoppingLists(),
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
                    return ShoppingListsContainer(); //ProductsContainer(_productsViewMode);
                  }
                }),
          ],
        ),
      ),
    );
  }
}
