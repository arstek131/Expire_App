/* flutter  */
import 'package:expire_app/models/shopping_list.dart';
import 'package:expire_app/widgets/family_id_choice_modal.dart';
import 'package:expire_app/widgets/shopping_list_title_placeholder.dart';
import 'package:expire_app/widgets/shopping_lists_container.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/* provider */
import 'package:provider/provider.dart';
import '../providers/shopping_list_provider.dart';

/* widgets */
import '../widgets/options_bar.dart';
import '../widgets/product_list_tile_placeholder.dart';

/* styles */
import '../app_styles.dart' as styles;

/* helper */
import '../helpers/device_info.dart' as deviceinfo;

class ShoppingListScreen extends StatefulWidget {
  const ShoppingListScreen();

  @override
  _ShoppingListScreenState createState() => _ShoppingListScreenState();
}

class _ShoppingListScreenState extends State<ShoppingListScreen> with AutomaticKeepAliveClientMixin<ShoppingListScreen> {
  // Keep page state alive
  @override
  bool get wantKeepAlive => true;

  deviceinfo.DeviceInfo _deviceInfo = deviceinfo.DeviceInfo.instance;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: styles.primaryColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              /*padding: EdgeInsets.only(
                top: _deviceInfo.isPhonePotrait(context)
                    ? _deviceInfo.deviceHeight * 0.04
                    : _deviceInfo.isPhoneLandscape(context)
                        ? 10.0
                        : _deviceInfo.isTabletLandscape(context)
                            ? 100.0
                            : 50,
              ),*/
              width: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    styles.primaryColor,
                    styles.primaryColor.withOpacity(0.6),
                  ],
                  stops: [0.9, 1],
                ),
                shape: BoxShape.rectangle,
                color: Colors.pinkAccent,
                boxShadow: [
                  BoxShadow(
                    color: Colors.indigo.shade700,
                    offset: const Offset(0, 10),
                    blurRadius: 5.0,
                    spreadRadius: 1,
                  )
                ],
              ),
              child: Padding(
                padding: EdgeInsets.only(
                  top: _deviceInfo.sizeDispatcher(
                    context: context,
                    phonePotrait: 80,
                    phoneLandscape: 0,
                    tabletPotrait: 90,
                    tabletLandscape: 90,
                  ),
                  left: 20,
                  right: 30,
                  bottom: _deviceInfo.sizeDispatcher(
                    context: context,
                    phonePotrait: 40,
                    phoneLandscape: 10,
                    tabletPotrait: 30,
                    tabletLandscape: 30,
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      "Shopping lists",
                      style: styles.title,
                    ),
                    GestureDetector(
                      onTap: () async {
                        int uniqueId = Provider.of<ShoppingListProvider>(context, listen: false).getUniqueNameId();
                        String? title = await showModalBottomSheet<String>(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10.0),
                          ),
                          backgroundColor: styles.primaryColor,
                          isScrollControlled: true,
                          context: context,
                          builder: (ctx) {
                            return Stack(
                              children: [
                                Padding(
                                  padding: EdgeInsets.only(
                                      left: 25, right: 25, top: 20, bottom: 20 + MediaQuery.of(ctx).viewInsets.bottom),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Text(
                                        "List name:",
                                        textAlign: TextAlign.start,
                                        style: styles.heading,
                                      ),
                                      TextField(
                                        style: styles.subheading,
                                        cursorColor: styles.ghostWhite,
                                        decoration: InputDecoration(
                                          isDense: true,
                                          enabledBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: styles.ghostWhite,
                                            ),
                                          ),
                                          focusedBorder: UnderlineInputBorder(
                                            borderSide: BorderSide(
                                              color: styles.ghostWhite,
                                            ),
                                          ),
                                        ),
                                        autofocus: true,
                                        onSubmitted: (newValue) {
                                          Navigator.of(ctx).pop(newValue);
                                        },
                                      ),
                                    ],
                                  ),
                                ),
                                Positioned(
                                  top: 2,
                                  right: 4,
                                  child: IconButton(
                                    onPressed: () => Navigator.of(context).pop(),
                                    icon: FaIcon(
                                      FontAwesomeIcons.timesCircle,
                                      color: styles.ghostWhite,
                                      size: 22,
                                    ),
                                  ),
                                ),
                              ],
                            );
                          },
                        );
                        if (title == null) {
                          return;
                        } else if (title == "") {
                          Provider.of<ShoppingListProvider>(context, listen: false)
                              .addNewShoppingList(title: "Shopping list (${uniqueId})");
                        } else {
                          Provider.of<ShoppingListProvider>(context, listen: false).addNewShoppingList(title: title);
                        }
                      },
                      child: Card(
                        elevation: 10,
                        color: styles.ghostWhite,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: EdgeInsets.symmetric(horizontal: 11, vertical: 8),
                          child: Row(
                            children: [
                              Text(
                                "Add list",
                                style: TextStyle(
                                  fontFamily: styles.currentFontFamily,
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              SizedBox(width: 2),
                              Icon(
                                Icons.add,
                                color: Colors.black87,
                                size: 26,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(height: 20),
            FutureBuilder(
                future: Provider.of<ShoppingListProvider>(context, listen: false).fetchShoppingLists(),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return _deviceInfo.isPhone
                        ? Expanded(
                            child: ListView(
                              children: [
                                ShoppingListTilePlaceholder(first: true),
                                ShoppingListTilePlaceholder(),
                                ShoppingListTilePlaceholder(last: true),
                              ],
                            ),
                          )
                        : Align(
                            alignment: Alignment.topLeft,
                            child: Container(
                              width: _deviceInfo.deviceWidth / 2.25,
                              child: Column(
                                children: [
                                  ShoppingListTilePlaceholder(),
                                  ShoppingListTilePlaceholder(),
                                  ShoppingListTilePlaceholder(),
                                ],
                              ),
                            ),
                          );
                  } else {
                    return ShoppingListsContainer(); //ProductsContainer(_productsViewMode);
                  }
                }),
          ],
        ),
      ),
    );
  }
}
