/* dart */
import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

/* styles */
import '../app_styles.dart' as styles;
/* enums */
import '../enums/expire_status.dart';
/* helpers */
import '../helpers/firestore_helper.dart';
/* models */
import '../models/product.dart';

class ProductSingleGridTile extends StatefulWidget {
  final Product product;
  ExpireStatus? expireStatus;

  ProductSingleGridTile(this.product) {
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
  State<ProductSingleGridTile> createState() => _ProductSingleGridTileState();
}

class _ProductSingleGridTileState extends State<ProductSingleGridTile> {
  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: 10),
      child: Card(
        elevation: 6,
        child: GridTile(
          header: GridTileBar(
            backgroundColor: styles.ghostWhite,
            leading: CircleAvatar(
              backgroundColor: Colors.deepOrange,
              child: FutureBuilder(
                future: FirestoreHelper().getDisplayNameFromUserId(userId: widget.product.creatorId),
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
                            snapshot.data != null ? snapshot.data![0] : "U",
                            style: const TextStyle(color: styles.ghostWhite, fontSize: 30),
                          ),
              ),
            ),
            title: Text(
              widget.product.title,
              style: TextStyle(color: Colors.black),
            ),
            subtitle: FutureBuilder(
              future: FirestoreHelper().getDisplayNameFromUserId(userId: widget.product.creatorId),
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
                          style: const TextStyle(color: Colors.black, fontSize: 14),
                        ),
            ),
            trailing: IconButton(
                onPressed: () => showModalBottomSheet<void>(
                      context: context,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                      backgroundColor: styles.primaryColor,
                      builder: (BuildContext modalContext) {
                        return Container(
                          margin: EdgeInsets.all(20.0),
                          //alignment: Alignment.bottomCenter,
                          //height: MediaQuery.of(context).size.height * 0.3,
                          //height: 80,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: EdgeInsets.all(10.0),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10.0),
                                  color: Colors.white,
                                ),
                                child: TextButton.icon(
                                  onPressed: () async {
                                    final answer = await showDialog(
                                      context: modalContext,
                                      builder: (BuildContext ctx) {
                                        return AlertDialog(
                                          title: const Text("Confirm"),
                                          content: const Text("Are you sure you wish to delete this item?"),
                                          actions: <Widget>[
                                            TextButton(
                                              onPressed: () {
                                                FirestoreHelper().deleteProduct(widget.product.id!);

                                                Navigator.of(ctx).pop(true);
                                                Navigator.of(modalContext).pop(true);
                                              },
                                              child: const Text("DELETE"),
                                            ),
                                            TextButton(
                                              onPressed: () {
                                                Navigator.of(ctx).pop(false);
                                                Navigator.of(modalContext).pop(true);
                                              },
                                              child: const Text("CANCEL"),
                                            ),
                                          ],
                                        );
                                      },
                                    );
                                  },
                                  icon: Icon(
                                    Icons.delete,
                                    size: 32,
                                    color: Colors.red,
                                  ),
                                  label: Text(
                                    "Delete product",
                                    style: TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'SanFrancisco',
                                      fontSize: 18,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: Colors.black54,
                )),
          ),
          child: widget.product.image != null
              ? Image.network(
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
    ); /*Stack(
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
                    future: FirestoreHelper().getDisplayNameFromUserId(userId: widget.product.creatorId),
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
                            FirestoreHelper().deleteProduct(widget.product.id); //Todo: not working.
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
    );*/
  }
}
