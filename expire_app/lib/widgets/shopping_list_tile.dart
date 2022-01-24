import 'package:expire_app/helpers/firestore_helper.dart';
import 'package:expire_app/models/shopping_list.dart';
import 'package:expire_app/providers/shopping_list_provider.dart';
import 'package:expire_app/screens/shopping_list_detail_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

/* styles */
import '../app_styles.dart' as styles;

class ShoppingListTile extends StatefulWidget {
  ShoppingListTile({required this.shoppingList}) : numberOfElements = shoppingList.products.length;

  ShoppingList shoppingList;
  final int numberOfElements;

  @override
  _ShoppingListTileState createState() => _ShoppingListTileState();
}

class _ShoppingListTileState extends State<ShoppingListTile> {
  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 10,
      color: widget.shoppingList.completed ? Colors.grey.shade500 : styles.ghostWhite,
      child: Dismissible(
        key: UniqueKey(),
        onDismissed: (direction) {
          if (direction == DismissDirection.endToStart) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(
                  "List '${widget.shoppingList.title}' deleted",
                  textAlign: TextAlign.center,
                ),
              ),
            );
          }
        },
        //direction: DismissDirection.endToStart,
        dismissThresholds: const {
          DismissDirection.endToStart: 0.4,
        },
        secondaryBackground: Container(
          color: Colors.red,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: AlignmentDirectional.centerEnd,
          child: const Icon(
            Icons.delete,
            color: Colors.white,
            size: 30,
          ),
        ),
        background: Container(
          color: widget.shoppingList.completed ? Colors.blue.shade600 : Colors.green,
          padding: const EdgeInsets.symmetric(horizontal: 20),
          alignment: AlignmentDirectional.centerStart,
          child: widget.shoppingList.completed
              ? const FaIcon(
                  FontAwesomeIcons.redo,
                  color: Colors.white,
                  size: 22,
                )
              : const Icon(
                  Icons.check_circle,
                  color: Colors.white,
                  size: 30,
                ),
        ),
        confirmDismiss: (DismissDirection direction) async {
          Vibrate.feedback(FeedbackType.selection);
          if (direction == DismissDirection.endToStart) {
            return await showDialog(
              context: context,
              builder: (BuildContext ctx) {
                return AlertDialog(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10.0),
                    ),
                  ),
                  title: const Text(
                    "Confirm",
                  ),
                  content: const Text(
                    "Are you sure you wish to delete this item?",
                  ),
                  actionsAlignment: MainAxisAlignment.spaceAround,
                  titleTextStyle: TextStyle(
                    fontFamily: styles.currentFontFamily,
                    fontWeight: FontWeight.bold,
                    fontSize: 25,
                  ),
                  contentTextStyle: TextStyle(
                    fontFamily: styles.currentFontFamily,
                    fontSize: 16,
                  ),
                  backgroundColor: styles.primaryColor,
                  actions: <Widget>[
                    TextButton.icon(
                      icon: FaIcon(
                        FontAwesomeIcons.trashAlt,
                        color: Colors.redAccent,
                      ),
                      onPressed: () {
                        Provider.of<ShoppingListProvider>(context, listen: false).deleteShoppingList(widget.shoppingList.id);
                        Navigator.of(ctx).pop(true);
                      },
                      label: Text(
                        "DELETE",
                        style: TextStyle(
                          fontFamily: styles.currentFontFamily,
                          color: Colors.redAccent,
                        ),
                      ),
                    ),
                    TextButton.icon(
                      icon: FaIcon(
                        FontAwesomeIcons.undoAlt,
                        color: styles.ghostWhite,
                      ),
                      onPressed: () => Navigator.of(ctx).pop(false),
                      label: const Text(
                        "CANCEL",
                        style: TextStyle(
                          fontFamily: styles.currentFontFamily,
                          color: styles.ghostWhite,
                        ),
                      ),
                    ),
                  ],
                );
              },
            );
          } else {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
            if (widget.shoppingList.completed) {
              Provider.of<ShoppingListProvider>(context, listen: false)
                  .updateCompletedShoppingList(widget.shoppingList.id, false);
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text("Shopping list restored", textAlign: TextAlign.center)));
            } else {
              Provider.of<ShoppingListProvider>(context, listen: false).updateCompletedShoppingList(widget.shoppingList.id, true);
              ScaffoldMessenger.of(context)
                  .showSnackBar(SnackBar(content: Text("Shopping list completed", textAlign: TextAlign.center)));
            }
          }
        },
        child: ListTile(
          leading: Container(
            height: double.infinity,
            child: Icon(
              Icons.receipt_long,
              size: 32,
            ),
          ),
          title: Text(
            widget.shoppingList.title,
            style: TextStyle(
              fontFamily: styles.currentFontFamily,
              fontWeight: FontWeight.normal,
              decoration: (widget.shoppingList.completed ? TextDecoration.lineThrough : null),
            ),
          ),
          subtitle: Text(
            "List with ${widget.numberOfElements} products",
            style: TextStyle(
              fontFamily: styles.currentFontFamily,
              decoration: (widget.shoppingList.completed ? TextDecoration.lineThrough : null),
            ),
          ),
          trailing: Icon(Icons.arrow_forward_ios),
          onTap: () => Navigator.of(context).pushNamed(ShoppingListDetailScreen.routeName, arguments: widget.shoppingList.id),
        ),
      ),
    );
  }
}
