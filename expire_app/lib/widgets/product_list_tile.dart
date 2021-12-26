/* dart */
import 'package:expire_app/helpers/db_helper.dart';
import 'package:expire_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'dart:math' as math;

/* models */
import '../models/product.dart';

/* provider */
import '../providers/products_provider.dart';

/* helpers */
import '../helpers/expire_status.dart';

class ProductListTile extends StatefulWidget {
  final Product product;
  ExpireStatus? expireStatus;

  ProductListTile(this.product) {
    DateTime today = DateTime.now();

    int dateDifferenceInDays = DateTime(product.expiration.year, product.expiration.month, product.expiration.day)
        .difference(
          DateTime(today.year, today.month, today.day),
        )
        .inDays;

    if (dateDifferenceInDays < 0) {
      expireStatus = ExpireStatus.Expired;
    } else if (dateDifferenceInDays == 0) {
      expireStatus = ExpireStatus.ExpiringToday;
    } else {
      expireStatus = ExpireStatus.NotExpired;
    }
  }

  @override
  State<ProductListTile> createState() => _ProductListTileState();
}

class _ProductListTileState extends State<ProductListTile> {
  String _displayName = "";

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
      child: Stack(
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15.0),
            ),
            elevation: 8,
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Row(
                children: <Widget>[
                  const FlutterLogo(
                    size: 70,
                  ),
                  const SizedBox(
                    width: 20,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Text(
                        widget.product.title,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        'Expiration: ${DateFormat('dd MMMM yyyy').format(widget.product.expiration)}',
                        style: TextStyle(
                            color: widget.expireStatus == ExpireStatus.Expired
                                ? Colors.red
                                : widget.expireStatus == ExpireStatus.ExpiringToday
                                    ? Colors.orange
                                    : Colors.indigo,
                            fontWeight: FontWeight.bold),
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
                ],
              ),
            ),
          ),
          if (widget.expireStatus == ExpireStatus.Expired)
            Positioned(
              top: 10,
              right: 0,
              child: Align(
                alignment: Alignment.center,
                child: Transform.rotate(
                  angle: 40 / 180 * math.pi,
                  child: Container(
                    height: 30,
                    width: 70,
                    alignment: Alignment.center,
                    color: Colors.red,
                    child: Text("EXPIRED"),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
