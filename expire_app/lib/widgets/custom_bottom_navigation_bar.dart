/* dart */
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

/* providers */
import '../providers/products_provider.dart';
import '../providers/bottom_navigator_bar_size_provider.dart';

/* widgets */
import '../widgets/custom_bottom_navigation_bar_item.dart';
import '../widgets/add_item_modal.dart';

/* models */
import '../models/product.dart';

/* style */
import '../app_styles.dart' as styles;

/* screens */

class CustomBottomNavigationBar extends StatefulWidget {
  final Function setIndex;
  final int pageIndex;

  CustomBottomNavigationBar({
    required this.setIndex,
    required this.pageIndex,
  });

  @override
  State<CustomBottomNavigationBar> createState() => _CustomBottomNavigationBarState();
}

class _CustomBottomNavigationBarState extends State<CustomBottomNavigationBar> {
  final double _selectedIconSize = 37;
  final double _unselectedIconSize = 35;

  @override
  Widget build(BuildContext context) {
    final bottomNavigationSize = Provider.of<BottomNavigationBarSizeProvider>(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 25),
      margin: EdgeInsets.only(bottom: bottomNavigationSize.bottomPadding),
      height: bottomNavigationSize.height,
      child: Container(
        width: double.infinity,
        decoration: bottomNavigationSize.decoration,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomBottomNavigationBarItem(
              selected: widget.pageIndex == 0,
              icon: const FaIcon(FontAwesomeIcons.utensils), //Icon(Icons.restaurant_menu),
              selectedSize: _selectedIconSize,
              unselectedSize: _unselectedIconSize,
              onTap: () {
                widget.setIndex(0);
              },
            ),
            CustomBottomNavigationBarItem(
              selected: widget.pageIndex == 1,
              icon: const FaIcon(FontAwesomeIcons.elementor),
              selectedSize: _selectedIconSize,
              unselectedSize: _unselectedIconSize,
              onTap: () {
                widget.setIndex(1);
              },
            ),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: widget.pageIndex != 2 ? 70 : 100,
              child: ElevatedButton(
                onPressed: widget.pageIndex != 2
                    ? () => widget.setIndex(2)
                    : () {
                        showModalBottomSheet<void>(
                          isScrollControlled: true,
                          enableDrag: true,
                          context: context,
                          shape: const RoundedRectangleBorder(
                            borderRadius: BorderRadius.vertical(
                              top: Radius.circular(20),
                            ),
                          ),
                          clipBehavior: Clip.antiAliasWithSaveLayer,
                          builder: (BuildContext ctx) {
                            return AddItemModal(modalContext: ctx);
                          },
                        );
                      },
                child: widget.pageIndex == 2
                    ? const FittedBox(
                        child: FaIcon(
                          FontAwesomeIcons.plus,
                        ),
                      )
                    : const FittedBox(
                        child: FaIcon(FontAwesomeIcons.home),
                      ),
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(bottomNavigationSize.outlineBorder),
                  padding: MaterialStateProperty.all(EdgeInsets.all(bottomNavigationSize.mainButtonInternalPadding)),
                  backgroundColor: widget.pageIndex == 2
                      ? MaterialStateProperty.all(styles.primaryColor)
                      : MaterialStateProperty.all(Colors.indigo[400]), // <-- Button color
                ),
              ),
            ),
            CustomBottomNavigationBarItem(
              selected: widget.pageIndex == 3,
              icon: const FaIcon(FontAwesomeIcons.chartPie),
              selectedSize: _selectedIconSize,
              unselectedSize: _unselectedIconSize,
              onTap: () {
                widget.setIndex(3);
              },
            ),
            CustomBottomNavigationBarItem(
              selected: widget.pageIndex == 4,
              icon: const FaIcon(FontAwesomeIcons.users),
              selectedSize: _selectedIconSize,
              unselectedSize: _unselectedIconSize,
              onTap: () {
                widget.setIndex(4);
              },
            ),
          ],
        ),
      ),
    );
  }
}
