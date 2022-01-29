import 'dart:convert';

import 'package:expire_app/enums/expire_status.dart';
import 'package:expire_app/models/product.dart';
import 'package:expire_app/providers/products_provider.dart';
import 'package:expire_app/widgets/eco_product_detail.dart';
import 'package:expire_app/widgets/expire_clip.dart';
import 'package:expire_app/widgets/health_product_detail.dart';
import 'package:expire_app/widgets/image_dispatcher.dart';
import 'package:expire_app/widgets/product_details_container.dart';
import 'package:expire_app/widgets/shopping_list_section.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:path/path.dart';
import 'package:provider/provider.dart';
import 'package:openfoodfacts/openfoodfacts.dart' as opf;
import 'package:openfoodfacts/utils/TagType.dart';
import '../helpers/device_info.dart' as deviceinfo;

/* styles */
import '../app_styles.dart' as styles;

enum Pages { Health, Eco, ShoppingList, Score }

class ProductDetails extends StatefulWidget {
  static const routeName = "/product-details";
  const ProductDetails();

  @override
  _ProductDetailsState createState() => _ProductDetailsState();
}

class _ProductDetailsState extends State<ProductDetails> {
  deviceinfo.DeviceInfo _deviceInfo = deviceinfo.DeviceInfo.instance;

  @override
  Widget build(BuildContext context) {
    String productId = ModalRoute.of(context)?.settings.arguments as String;
    Product _product = Provider.of<ProductsProvider>(context).getItemFromId(productId);

    return Scaffold(
      appBar: AppBar(
        toolbarHeight: _deviceInfo.deviceHeight * (_deviceInfo.isPotrait(context) ? 0.09 : 0.15),
        backgroundColor: Colors.indigoAccent,
        leading: IconButton(
          icon: Icon(
            Icons.arrow_back_ios_new,
            color: styles.ghostWhite,
            size: 25,
          ),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: FaIcon(FontAwesomeIcons.heart),
          ),
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert),
          )
        ],
      ),
      backgroundColor: styles.primaryColor,
      body: ProductDetailsContainer(_product),
    );
  }
}
