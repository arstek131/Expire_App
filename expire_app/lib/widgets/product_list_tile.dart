/* dart */
import 'package:expire_app/helpers/db_helper.dart';
import 'package:expire_app/helpers/firestore_helper.dart';
import 'package:expire_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shimmer/shimmer.dart';
import 'dart:math' as math;

/* models */
import '../models/product.dart';

/* widgets */
import '../widgets/expire_clip.dart';

/* provider */
import '../providers/products_provider.dart';

/* helpers */
import '../enums/expire_status.dart';

/* style */
import '../app_styles.dart' as styles;

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
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 3,
            spreadRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),

      //margin: const EdgeInsets.only(bottom: 10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(15.0),
        child: Dismissible(
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
          child: Card(
            color: styles.ghostWhite,
            margin: EdgeInsets.zero,
            //clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
                //borderRadius: BorderRadius.circular(15.0),
                ),
            elevation: 8,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    children: <Widget>[
                      Container(
                        height: 100,
                        width: 100,
                        /*decoration: const BoxDecoration(
                          border: Border(
                            right: BorderSide(width: 2.5, color: Colors.black87),
                          ),
                        ),*/
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(10.0),
                          child: widget.product.imageUrl != null
                              ? Image.network(
                                  widget.product.imageUrl!,
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
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                              overflow: TextOverflow.ellipsis,
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
                                              style: const TextStyle(color: Colors.grey, fontSize: 14),
                                            ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 5,
                  right: 5,
                  child: ExpireClip(widget.expireStatus!, widget.product.expiration),
                ),
                /*Positioned(
                    top: 10,
                    right: -5,
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
                  ),*/
              ],
            ),
          ),
        ),
      ),
    );
  }
}
