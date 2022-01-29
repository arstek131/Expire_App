import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expire_app/providers/products_provider.dart';
import 'package:expire_app/widgets/image_dispatcher.dart';
import 'package:expire_app/widgets/shopping_list_element_tile.dart';
import 'package:expire_app/widgets/shopping_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:circular_menu/circular_menu.dart';
import '../widgets/shopping_list_detail_container.dart';

/* providers */
import 'package:provider/provider.dart';
import '../providers/shopping_list_provider.dart';
import '../providers/tile_pointer_provider.dart';

/* models */
import '../models/product.dart';
import '../models/shopping_list_element.dart';

/* styles */
import '../app_styles.dart' as styles;

class ShoppingListDetailScreen extends StatefulWidget {
  static const routeName = "/shopping-list-details";

  const ShoppingListDetailScreen();

  @override
  _ShoppingListDetailScreenState createState() => _ShoppingListDetailScreenState();
}

class _ShoppingListDetailScreenState extends State<ShoppingListDetailScreen> {
  @override
  Widget build(BuildContext context) {
    String listId = ModalRoute.of(context)!.settings.arguments as String;
    return ShoppingListDetailContainer(listId: listId);
  }
}
