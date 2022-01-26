/* dart */
import 'package:expire_app/widgets/shopping_list_tile.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

/* providers */
import '../providers/shopping_list_provider.dart';
import 'package:provider/provider.dart';
import '../providers/bottom_navigator_bar_size_provider.dart';

/* style */
import '../app_styles.dart' as styles;

class ShoppingListsContainer extends StatefulWidget {
  const ShoppingListsContainer({Key? key}) : super(key: key);

  @override
  _ShoppingListsContainerState createState() => _ShoppingListsContainerState();
}

class _ShoppingListsContainerState extends State<ShoppingListsContainer> {
  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey = GlobalKey<RefreshIndicatorState>();

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

  @override
  Widget build(BuildContext context) {
    return Flexible(
      child: NotificationListener<ScrollNotification>(
        onNotification: (ScrollNotification scrollInfo) {
          if (scrollInfo is UserScrollNotification) {
            // scrolling up
            if (scrollInfo.direction == ScrollDirection.forward) {
              Provider.of<BottomNavigationBarSizeProvider>(context, listen: false).notifyGrow();
            } else if (scrollInfo.direction == ScrollDirection.reverse) {
              // scrolling down
              Provider.of<BottomNavigationBarSizeProvider>(context, listen: false).notifyShrink();
            }
          }
          return true;
        },
        child: RefreshIndicator(
          key: _refreshIndicatorKey,
          color: Colors.blue,
          onRefresh: () {
            return Provider.of<ShoppingListProvider>(context, listen: false).fetchShoppingLists();
          },
          child: Consumer<ShoppingListProvider>(builder: (_, data, __) {
            if (!data.shoppingLists.isEmpty) {
              return ListView.builder(
                physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
                itemCount: data.shoppingLists.length + 1,
                itemBuilder: (context, index) => index < data.shoppingLists.length
                    ? ShoppingListTile(
                        shoppingList: data.shoppingLists[index],
                        first: (index == 0),
                        last: (index == data.shoppingLists.length - 1),
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
                    top: 200,
                    child: RichText(
                      textAlign: TextAlign.center,
                      text: TextSpan(
                        children: [
                          TextSpan(
                            text: "Click the  ",
                            style: styles.subheading,
                          ),
                          WidgetSpan(
                            child: FaIcon(
                              FontAwesomeIcons.plusCircle,
                              size: 16,
                              color: Colors.white,
                            ),
                          ),
                          TextSpan(
                            text: "  button to create your first list!",
                            style: styles.subheading,
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
    );
  }
}
