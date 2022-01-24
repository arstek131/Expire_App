import 'package:expire_app/providers/tile_pointer_provider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:flutter_vibrate/flutter_vibrate.dart';

/* models */
import '../models/shopping_list_element.dart';

/* providers */
import 'package:provider/provider.dart';
import '../providers/shopping_list_provider.dart';

/* styles */
import '../app_styles.dart' as styles;

class ShoppingListElementTile extends StatefulWidget {
  ShoppingListElementTile(this.listId, this.shoppingListElement);

  ShoppingListElement shoppingListElement;
  String listId;

  @override
  _ShoppingListElementTileState createState() => _ShoppingListElementTileState();
}

class _ShoppingListElementTileState extends State<ShoppingListElementTile> {
  @override
  Widget build(BuildContext context) {
    final _tilePointerProvider = Provider.of<TilePointerProvider>(context, listen: false);
    return Card(
      margin: EdgeInsets.symmetric(horizontal: 10, vertical: 3),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10.0)),
      elevation: 10,
      color: (widget.shoppingListElement.checked ? Colors.grey.shade500 : styles.ghostWhite),
      child: Listener(
        onPointerMove: (PointerMoveEvent event) {
          _tilePointerProvider.horizontalScroll = event.position.dx;

          if (_tilePointerProvider.offsetPercentage > 0.5) {
            _tilePointerProvider.overThreshold = true;
            if (_tilePointerProvider.flag) {
              _tilePointerProvider.flag = false;
              Vibrate.feedback(FeedbackType.selection);
            }
          } else {
            _tilePointerProvider.overThreshold = false;
            _tilePointerProvider.flag = true;
          }
        },
        //onPointerUp: (_) => _tilePointerProvider.clearProvider(),
        onPointerDown: (event) => _tilePointerProvider.initProvider(
          initPos: event.position.dx,
          totalWidth: MediaQuery.of(context).size.width,
        ),
        child: Dismissible(
          key: UniqueKey(),
          onDismissed: (direction) {
            if (direction == DismissDirection.endToStart) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "List element '${widget.shoppingListElement.title}' deleted",
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }
          },
          //direction: DismissDirection.endToStart,
          dismissThresholds: const {
            DismissDirection.endToStart: 0.2,
          },
          secondaryBackground: Consumer<TilePointerProvider>(
            builder: (_, data, __) {
              return AnimatedContainer(
                duration: Duration(milliseconds: 300),
                color: data.overThreshold ? Colors.red : Colors.grey.shade400,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                alignment: AlignmentDirectional.centerEnd,
                child: Icon(
                  data.overThreshold ? Icons.delete : Icons.exposure_minus_1_outlined,
                  color: Colors.white,
                  size: 30,
                ),
              );
            },
          ),
          background: Container(
              color: Colors.blue.shade300,
              padding: const EdgeInsets.symmetric(horizontal: 20),
              alignment: AlignmentDirectional.centerStart,
              child: const Icon(
                Icons.plus_one,
                color: Colors.white,
                size: 30,
              )),
          confirmDismiss: (DismissDirection direction) async {
            Vibrate.feedback(FeedbackType.selection);
            if (direction == DismissDirection.endToStart) {
              if (_tilePointerProvider.overThreshold || (widget.shoppingListElement.quantity - 1) <= 0) {
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
                            Provider.of<ShoppingListProvider>(context, listen: false)
                                .deleteShoppingListElement(widget.listId, widget.shoppingListElement.id);
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
                Provider.of<ShoppingListProvider>(context, listen: false)
                    .decrementProductQuantity(listId: widget.listId, productId: widget.shoppingListElement.id);
                ScaffoldMessenger.of(context).hideCurrentSnackBar();
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      "Subtracted -1 to ${widget.shoppingListElement.title} quantity!",
                      textAlign: TextAlign.center,
                    ),
                  ),
                );
                return null;
              }
            } else {
              Provider.of<ShoppingListProvider>(context, listen: false)
                  .incrementProductQuantity(listId: widget.listId, productId: widget.shoppingListElement.id);
              ScaffoldMessenger.of(context).hideCurrentSnackBar();
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    "Added +1 to ${widget.shoppingListElement.title} quantity!",
                    textAlign: TextAlign.center,
                  ),
                ),
              );
            }

            _tilePointerProvider.clearProvider();
          },
          child: ListTile(
            contentPadding: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            leading: Container(
              margin: EdgeInsets.only(left: 10),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  FaIcon(
                    FontAwesomeIcons.elementor,
                    size: 29,
                  ),
                ],
              ),
            ),
            title: Text(
              widget.shoppingListElement.title,
              style: TextStyle(
                fontFamily: styles.currentFontFamily,
                fontWeight: FontWeight.bold,
                decoration: (widget.shoppingListElement.checked ? TextDecoration.lineThrough : null),
              ),
            ),
            subtitle: Text(
              "Quantity: x ${widget.shoppingListElement.quantity}",
              style: TextStyle(
                fontFamily: styles.currentFontFamily,
                decoration: (widget.shoppingListElement.checked ? TextDecoration.lineThrough : null),
              ),
            ),
            trailing: Checkbox(
              value: widget.shoppingListElement.checked,
              onChanged: (newValue) {
                Provider.of<ShoppingListProvider>(context, listen: false)
                    .updateShoppingListElementChecked(widget.listId, widget.shoppingListElement.id, newValue!);
              },
            ),
          ),
        ),
      ),
    );
  }
}
