/* dart */
import 'package:expire_app/helpers/db_helper.dart';
import 'package:expire_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

/* modes */
import '../models/product.dart';

/* provider */
import '../providers/products_provider.dart';

class ProductListTile extends StatefulWidget {
  final Product product;

  ProductListTile(this.product);

  @override
  State<ProductListTile> createState() => _ProductListTileState();
}

class _ProductListTileState extends State<ProductListTile> {
  String _displayName = "";

  /*_ProductListTileState() {
    Provider.of<AuthProvider>(context, listen: false).getDisplayNameFromId(widget.product.id).then((value) {
      setState(() {
        _displayName = value;
      });
    });
  }*/

  @override
  Widget build(BuildContext context) {
    return Dismissible(
      key: UniqueKey(), //ValueKey(product.id), since so far everything has same id for testing
      onDismissed: (direction) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              "Product '${widget.product.title}' deleted",
              textAlign: TextAlign.center,
            ),
          ),
        );
      },
      direction: DismissDirection.endToStart,
      dismissThresholds: const {
        DismissDirection.endToStart: 0.4,
      },
      background: Container(
        color: Colors.red,
        padding: const EdgeInsets.symmetric(horizontal: 20),
        alignment: AlignmentDirectional.centerEnd,
        child: const Icon(
          Icons.delete,
          color: Colors.white,
          size: 35,
        ),
      ),
      confirmDismiss: (DismissDirection direction) async {
        return await showDialog(
          context: context,
          builder: (BuildContext ctx) {
            return AlertDialog(
              title: const Text("Confirm"),
              content: const Text("Are you sure you wish to delete this item?"),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Provider.of<ProductsProvider>(context, listen: false).deleteProduct(widget.product.id); //Todo: not working.
                    Navigator.of(ctx).pop(true);
                  },
                  child: const Text("DELETE"),
                ),
                TextButton(
                  onPressed: () => Navigator.of(ctx).pop(false),
                  child: const Text("CANCEL"),
                ),
              ],
            );
          },
        );
      },
      child: Card(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(15.0),
        ),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Row(children: <Widget>[
            const FlutterLogo(
              size: 70,
            ),
            const SizedBox(
              width: 20,
            ),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    widget.product.title,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  Text(
                    'Expiration: ${DateFormat('dd/MM/yyyy').format(widget.product.expiration)}',
                    style: const TextStyle(color: Colors.indigo, fontWeight: FontWeight.bold),
                  ),
                  Row(
                    children: [
                      const Icon(
                        Icons.person,
                        color: Colors.grey,
                        size: 20,
                      ),
                      FutureBuilder(
                        future: DBHelper.getDisplayNameFromUserId(widget.product.creatorId),
                        initialData: "Loading text..",
                        builder: (BuildContext context, AsyncSnapshot<String?> text) {
                          return Text(
                            text.data ?? "UNKNOWN",
                            style: const TextStyle(color: Colors.grey, fontSize: 14),
                          );
                        },
                      )
                    ],
                  ),
                ],
              ),
            )
          ]),
        ),
      ),
    );
  }
}
