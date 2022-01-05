/* dart */
import 'package:expire_app/widgets/expire_clip.dart';
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import 'package:intl/intl.dart';

/* models */
import '../models/product.dart';

/* helpers */
import '../helpers/firestore_helper.dart';

/* enums */
import '../enums/expire_status.dart';

/* styles */
import '../app_styles.dart' as styles;

class ProductGridTile extends StatefulWidget {
  final Product product;
  ExpireStatus? expireStatus;

  ProductGridTile(this.product) {
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
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10.0),
          child: GridTile(
            key: ValueKey(widget.product.id),
            child: widget.product.imageUrl != null
                ? Image.network(
                    widget.product.imageUrl!,
                    fit: BoxFit.fill,
                    color: const Color.fromRGBO(255, 255, 255, 0.85),
                    colorBlendMode: BlendMode.modulate,
                  )
                : Image.asset(
                    "assets/images/missing_image_placeholder.png",
                    fit: BoxFit.cover,
                  ),
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
                  FutureBuilder(
                    future: FirestoreHelper.instance.getDisplayNameFromUserId(userId: widget.product.creatorId),
                    builder: (BuildContext context, AsyncSnapshot<String?> snapshot) =>
                        snapshot.connectionState == ConnectionState.waiting
                            ? Shimmer.fromColors(
                                baseColor: Colors.grey.shade300,
                                highlightColor: Colors.grey.shade100,
                                direction: ShimmerDirection.ltr,
                                child: Container(
                                  width: 40.0,
                                  height: 15.0,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(10.0),
                                    color: Colors.white,
                                  ),
                                ),
                              )
                            : Text(
                                snapshot.data ?? "UNKNOWN",
                                style: const TextStyle(color: styles.ghostWhite, fontSize: 14),
                              ),
                  )
                ],
              ),
              //trailing: const Icon(Icons.shopping_cart),
            ),
          ),
        ),
        Positioned(
          top: 5,
          right: 5,
          child: ExpireClip(widget.expireStatus!, widget.product.expiration),
        ),
        Positioned.fill(
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              splashColor: Colors.red.withOpacity(0.6),
              onLongPress: () async {
                final answer = await showDialog(
                  context: context,
                  builder: (BuildContext ctx) {
                    return AlertDialog(
                      title: const Text("Confirm"),
                      content: const Text("Are you sure you wish to delete this item?"),
                      actions: <Widget>[
                        TextButton(
                          onPressed: () {
                            FirestoreHelper.instance.deleteProduct(widget.product.id); //Todo: not working.
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
            ),
          ),
        )
      ],
    );
  }
}
