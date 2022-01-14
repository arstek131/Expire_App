import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ProductListTilePlaceholder extends StatelessWidget {
  bool first;
  bool last;

  ProductListTilePlaceholder({this.first = false, this.last = false});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 0.6, horizontal: 10),
      child: Card(
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(first ? 15.0 : 0.0),
            topRight: Radius.circular(first ? 15.0 : 0.0),
            bottomLeft: Radius.circular(last ? 15.0 : 0.0),
            bottomRight: Radius.circular(last ? 15.0 : 0.0),
          ),
        ),
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Shimmer.fromColors(
            baseColor: Colors.grey.shade300,
            highlightColor: Colors.grey.shade100,
            direction: ShimmerDirection.ltr,
            child: Stack(
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Container(
                      decoration: const BoxDecoration(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10.0),
                        ),
                        color: Colors.white,
                      ),
                      width: 120.0,
                      height: 120.0,
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 8.0),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Container(
                            width: 160,
                            height: 15.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.white,
                            ),
                          ),
                          Container(
                            margin: EdgeInsets.only(top: 10),
                            width: 80,
                            height: 15.0,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10.0),
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    )
                  ],
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 70.0,
                    height: 15.0,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10.0),
                      color: Colors.white,
                    ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
