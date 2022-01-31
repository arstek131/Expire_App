/* dart */
import 'package:expire_app/helpers/firebase_auth_helper.dart';
import 'package:expire_app/screens/shopping_list_detail_screen.dart';
import 'package:expire_app/widgets/shopping_list_detail_container.dart';
import 'package:expire_app/widgets/shopping_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';

/* style */
import '../app_styles.dart' as styles;
/* helper */
import '../helpers/device_info.dart' as deviceinfo;
import '../providers/bottom_navigator_bar_size_provider.dart';
/* providers */
import '../providers/shopping_list_provider.dart';

class ShoppingListsContainer extends StatefulWidget {
  const ShoppingListsContainer({Key? key}) : super(key: key);

  @override
  _ShoppingListsContainerState createState() => _ShoppingListsContainerState();
}

class _ShoppingListsContainerState extends State<ShoppingListsContainer> {
  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();
  deviceinfo.DeviceInfo _deviceInfo = deviceinfo.DeviceInfo.instance;

  String? _chosenShoppingList;

  List<BoxShadow> customShadow = [
    BoxShadow(
      color: Colors.indigoAccent.withOpacity(0.5),
      spreadRadius: -5,
      offset: Offset(-5, -5),
      blurRadius: 30,
    ),
    BoxShadow(
      color: Colors.indigo.shade900.withOpacity(0.2),
      spreadRadius: 2,
      offset: Offset(7, 7),
      blurRadius: 20,
    )
  ];

  void _resetState() {
    setState(() {
      _chosenShoppingList = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo.metrics.pixels > 10) {
            Provider.of<BottomNavigationBarSizeProvider>(context, listen: false).notifyShrink();
          } else {
            Provider.of<BottomNavigationBarSizeProvider>(context, listen: false).notifyGrow();
          }
          return true;
        },
        child: Row(
          children: [
            Flexible(
              flex: _deviceInfo.isTablet ? 3 : 1,
              child: RefreshIndicator(
                key: _refreshIndicatorKey,
                color: Colors.blue,
                onRefresh: () => Provider.of<ShoppingListProvider>(context, listen: false).fetchShoppingLists(),
                child: Container(
                  decoration: BoxDecoration(
                    color: styles.primaryColor,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black26,
                        offset: const Offset(8, 0),
                        blurRadius: 5.0,
                        spreadRadius: 2,
                      )
                    ],
                  ),
                  child: Consumer<ShoppingListProvider>(builder: (_, data, __) {
                    if (!data.shoppingLists.isEmpty) {
                      return ListView.builder(
                        physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                        itemCount: data.shoppingLists.length + 1,
                        itemBuilder: (context, index) => index < data.shoppingLists.length
                            ? GestureDetector(
                                onTap: () {
                                  if (_deviceInfo.isPhone) {
                                    Navigator.of(context)
                                        .pushNamed(
                                          ShoppingListDetailScreen.routeName,
                                          arguments: data.shoppingLists[index].id,
                                        )
                                        .then(
                                          (value) => !FirebaseAuthHelper().isAuth
                                              ? Provider.of<ShoppingListProvider>(context, listen: false).fetchShoppingLists()
                                              : null,
                                        );
                                  } else {
                                    setState(() {
                                      _chosenShoppingList = _chosenShoppingList == data.shoppingLists[index].id
                                          ? null
                                          : data.shoppingLists[index].id;
                                    });
                                  }
                                },
                                child: ShoppingListTile(
                                  shoppingList: data.shoppingLists[index],
                                  first: (index == 0),
                                  last: (index == data.shoppingLists.length - 1),
                                  resetState: _resetState,
                                ),
                              )
                            : SizedBox(
                                height: 120,
                              ),
                      );
                    } else {
                      return Stack(
                        alignment: Alignment.center,
                        children: [
                          Positioned.fill(
                            right: -300,
                            top: 300,
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: customShadow,
                                shape: BoxShape.circle,
                                color: Colors.white12,
                              ),
                            ),
                          ),
                          Positioned.fill(
                            right: -600,
                            top: -100,
                            child: Container(
                              decoration: BoxDecoration(
                                boxShadow: customShadow,
                                shape: BoxShape.circle,
                                color: Colors.white12,
                              ),
                            ),
                          ),
                          Positioned.fill(
                            top: _deviceInfo.isPhone ? 200 : 250,
                            child: RichText(
                              textAlign: TextAlign.center,
                              text: TextSpan(
                                children: [
                                  TextSpan(
                                    text: "Click the  ",
                                    style: _deviceInfo.isPhone ? styles.subheading : styles.subtitle,
                                  ),
                                  WidgetSpan(
                                    child: FaIcon(
                                      FontAwesomeIcons.plusCircle,
                                      size: _deviceInfo.isPhone ? 16 : 22,
                                      color: Colors.white,
                                    ),
                                  ),
                                  TextSpan(
                                    text: "  button to create your first list!",
                                    style: _deviceInfo.isPhone ? styles.subheading : styles.subtitle,
                                  ),
                                ],
                              ),
                            ),
                          )
                        ],
                      );
                    }
                  }),
                ),
              ),
            ),
            if (_deviceInfo.isTablet)
              Flexible(
                flex: 4,
                child: Container(
                  color: Colors.black12.withOpacity(0.2),
                  child: AnimatedOpacity(
                    duration: Duration(milliseconds: 100),
                    opacity: _chosenShoppingList == null ? 0 : 1,
                    child: _chosenShoppingList == null
                        ? Container()
                        : ShoppingListDetailContainer(
                            listId: _chosenShoppingList!,
                          ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
