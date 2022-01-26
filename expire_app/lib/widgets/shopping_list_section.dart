import 'package:expire_app/widgets/shopping_list_tile.dart';
import 'package:flutter/material.dart';
import '../app_styles.dart' as styles;

/* providers */
import '../providers/shopping_list_provider.dart';
import 'package:provider/provider.dart';

/* models */
import '../models/shopping_list.dart';

class ShoppingListSection extends StatefulWidget {
  String title;
  ShoppingListSection({required this.title});

  @override
  _ShoppingListDetailState createState() => _ShoppingListDetailState();
}

class _ShoppingListDetailState extends State<ShoppingListSection> {
  bool _isInserting = false;
  late final Future? myFuture;

  @override
  void initState() {
    myFuture = Provider.of<ShoppingListProvider>(context, listen: false).fetchShoppingLists();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: myFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 5),
            height: 200,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                CircularProgressIndicator(
                  strokeWidth: 2,
                  backgroundColor: styles.ghostWhite,
                ),
                SizedBox(
                  height: 10,
                ),
                Text(
                  "Loading shopping lists...",
                  style: styles.heading,
                )
              ],
            ),
          );
        } else {
          return Container(
            padding: EdgeInsets.symmetric(vertical: 5),
            height: 500,
            child: Consumer<ShoppingListProvider>(
              builder: (_, data, __) => ListView.builder(
                  physics: AlwaysScrollableScrollPhysics(parent: BouncingScrollPhysics()),
                  itemCount: data.shoppingLists.length,
                  itemBuilder: (context, index) {
                    ShoppingList shoppingList = data.shoppingLists[index];
                    return Card(
                      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
                      elevation: 10,
                      color: styles.ghostWhite,
                      child: ListTile(
                        leading: Container(
                          height: double.infinity,
                          child: Icon(
                            Icons.receipt_long,
                            size: 32,
                          ),
                        ),
                        title: Text(
                          shoppingList.title,
                          style: TextStyle(
                            fontFamily: styles.currentFontFamily,
                            fontWeight: FontWeight.normal,
                          ),
                        ),
                        subtitle: Text(
                          "List with ${shoppingList.products.length} products",
                          style: TextStyle(
                            fontFamily: styles.currentFontFamily,
                          ),
                        ),
                        trailing: _isInserting
                            ? CircularProgressIndicator()
                            : Icon(
                                Icons.add_circle,
                                color: styles.deepGreen,
                                size: 28,
                              ),
                        onTap: () async {
                          await Provider.of<ShoppingListProvider>(context, listen: false).addElementToShoppingList(
                              listId: shoppingList.id, shoppingListElementTitle: widget.title, quantity: 1);

                          ScaffoldMessenger.of(context).hideCurrentSnackBar();
                          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                              content: Text(
                            "Product ${widget.title} added to list ${shoppingList.title}",
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.fade,
                          )));
                        },
                      ),
                    );
                  }),
            ),
          );
        }
      },
    );
  }
}
