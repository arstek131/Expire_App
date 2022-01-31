/* dart */
import 'package:expire_app/providers/products_provider.dart';
import 'package:expire_app/screens/product_details.dart';
import 'package:expire_app/widgets/expire_clip.dart';
import 'package:expire_app/widgets/image_dispatcher.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

/* styles */
import '../app_styles.dart' as styles;
/* enums */
import '../enums/expire_status.dart';
import '../helpers/user_info.dart' as userInfo;
/* models */
import '../models/product.dart';

class ProductGridTile extends StatefulWidget {
  final Product product;
  ExpireStatus? expireStatus;
  bool first = true;
  bool second = true;
  bool second_last = true;
  bool last = true;
  bool filteredProductsLengthIsEven;

  ProductGridTile(this.product, this.first, this.second, this.second_last, this.last, this.filteredProductsLengthIsEven) {
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
  _ProductGridTileState createState() => _ProductGridTileState();
}

class _ProductGridTileState extends State<ProductGridTile> {
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: 50,
      child: Stack(
        children: [
          Hero(
            tag: 'produt-image${widget.product.id}',
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(widget.first ? 15.0 : 0.0),
                topRight: Radius.circular(widget.second ? 15.0 : 0.0),
                bottomRight: Radius.circular(
                  widget.last && widget.filteredProductsLengthIsEven ? 15.0 : 0.0,
                ),
                bottomLeft: Radius.circular(
                  widget.second_last && widget.filteredProductsLengthIsEven
                      ? 15.0
                      : widget.last && !widget.filteredProductsLengthIsEven
                          ? 15.0
                          : 0.0,
                ),
              ),
              child: GridTile(
                key: ValueKey(widget.product.id),
                child: ImageDispatcher(widget.product.image),
                footer: GridTileBar(
                  backgroundColor: Colors.black54,
                  title: Center(
                    child: Text(
                      widget.product.title,
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  subtitle: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.person,
                        color: styles.ghostWhite,
                        size: 20,
                      ),
                      Text(
                        userInfo.UserInfo().displayName ?? 'UNKNOWN',
                        style: const TextStyle(color: styles.ghostWhite, fontSize: 14),
                      ),
                    ],
                  ),
                  //trailing: const Icon(Icons.shopping_cart),
                ),
              ),
            ),
          ),
          Positioned(
            top: 5,
            right: 5,
            child: ExpireClip(widget.expireStatus!, widget.product.expiration),
          ),
          /*Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                splashColor: Colors.red.withOpacity(0.6),
                //onTap: () => {}, //Navigator.of(context).pushNamed(ProductDetails.routeName, arguments: widget.product.id),
                onLongPress: () async {
                  await showDialog(
                    context: context,
                    builder: (BuildContext ctx) {
                      return AlertDialog(
                        title: const Text("Confirm"),
                        content: const Text("Are you sure you wish to delete this item?"),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Provider.of<ProductsProvider>(context, listen: false).deleteProduct(widget.product.id!);
                              Navigator.of(ctx).pop();
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
              ),
            ),
          )*/
        ],
      ),
    );
  }
}
