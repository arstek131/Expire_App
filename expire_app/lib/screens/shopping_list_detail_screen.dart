import 'package:flutter/material.dart';

import '../widgets/shopping_list_detail_container.dart';

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
