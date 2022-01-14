/* dart */
import 'package:expire_app/helpers/db_helper.dart';
import 'package:expire_app/helpers/firestore_helper.dart';
import 'package:expire_app/providers/auth_provider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
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
  bool first = true;
  bool last = true;

  ProductListTile(this.product, this.first, this.last) {
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
      /*decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(15.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black12,
            blurRadius: 4,
            spreadRadius: 6,
            offset: Offset(0, 3),
          ),
        ],
      ),*/

      //margin: const EdgeInsets.only(bottom: 10.0),
      child: ClipRRect(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(widget.first ? 15.0 : 0.0),
          topRight: Radius.circular(widget.first ? 15.0 : 0.0),
          bottomLeft: Radius.circular(widget.last ? 15.0 : 0.0),
          bottomRight: Radius.circular(widget.last ? 15.0 : 0.0),
        ),
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
                        Provider.of<ProductsProvider>(context, listen: false).deleteProduct(widget.product.id!);
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
          },
          child: Card(
            color: Color(0xFF023e7d).withOpacity(0.754), //styles.ghostWhite,
            margin: EdgeInsets.zero,
            //clipBehavior: Clip.antiAlias,
            shape: RoundedRectangleBorder(
                //borderRadius: BorderRadius.circular(15.0),
                ),
            elevation: 8,
            child: Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10),
                  child: Row(
                    children: <Widget>[
                      Container(
                        height: 120,
                        width: 120,
                        /*decoration: const BoxDecoration(
                          border: Border(
                            right: BorderSide(width: 2.5, color: Colors.black87),
                          ),
                        ),*/
                        child: Hero(
                          tag: 'produt-image${widget.product.id}',
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10.0),
                            child: widget.product.image != null
                                ? widget.product.image is String
                                    ? Image.network(
                                        widget.product.image!,
                                        fit: BoxFit.cover,
                                        color: const Color.fromRGBO(255, 255, 255, 0.85),
                                        colorBlendMode: BlendMode.modulate,
                                      )
                                    : Image.file(
                                        widget.product.image!,
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
                      ),
                      const SizedBox(
                        width: 20,
                      ),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            Text(
                              widget.product.title,
                              style: const TextStyle(
                                fontWeight: FontWeight.w300,
                                fontSize: 17,
                                fontFamily: styles.currentFontFamily,
                                color: styles.ghostWhite, //Colors.black,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                            SizedBox(
                              height: 5,
                            ),
                            Text(
                              'Expiration: ${DateFormat('dd MMMM yyyy').format(widget.product.expiration)}',
                              style: TextStyle(
                                fontFamily: styles.currentFontFamily,
                                fontSize: 14,
                                color: widget.expireStatus == ExpireStatus.Expired
                                    ? Colors.red
                                    : widget.expireStatus == ExpireStatus.ExpiringToday
                                        ? Colors.orange
                                        : Colors.black,
                                fontWeight: FontWeight.bold,
                              ),
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
                Positioned(
                  bottom: 5,
                  right: 5,
                  child: Container(
                    alignment: Alignment.centerRight,
                    width: 200,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.end,
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
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                          color: styles.ghostWhite, fontSize: 15, fontFamily: styles.currentFontFamily),
                                    ),
                        ),
                      ],
                    ),
                  ),
                )
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
