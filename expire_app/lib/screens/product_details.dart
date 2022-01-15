import 'package:expire_app/models/product.dart';
import 'package:flutter/material.dart';

/* styles */
import '../app_styles.dart' as styles;

class ProductDetails extends StatefulWidget {
  static const routeName = "/product-details";
  const ProductDetails();

  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  @override
  Widget build(BuildContext context) {
    Product? _product = ModalRoute.of(context)?.settings.arguments as Product;

    return Container(
      height: double.infinity,
      width: double.infinity,
      color: styles.primaryColor,
      child: SafeArea(
        child: Container(
          height: 120,
          width: 120,
          color: Colors.red,
          /*child: Hero(
          tag: 'produt-image${_product.id}',
          child: ClipRRect(
            borderRadius: BorderRadius.circular(10.0),
            child: _product.image != null
                ? _product.image is String
                    ? Image.network(
                        _product.image!,
                        fit: BoxFit.cover,
                        color: const Color.fromRGBO(255, 255, 255, 0.85),
                        colorBlendMode: BlendMode.modulate,
                      )
                    : Image.file(
                        _product.image!,
                        fit: BoxFit.cover,
                        color: const Color.fromRGBO(255, 255, 255, 0.85),
                        colorBlendMode: BlendMode.modulate,
                      )
                : Image.asset(
                    "assets/images/missing_image_placeholder.png",
                    fit: BoxFit.cover,
                  ),
          ),
        ),*/
        ),
      ),
    );
  }
}