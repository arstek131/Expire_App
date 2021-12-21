/* dart */
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
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 7,
              spreadRadius: 3,
              offset: Offset(0, 5),
            ),
          ],
          color: Colors.white,
          borderRadius: BorderRadius.all(
            Radius.circular(12.0),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            CustomBottomNavigationBarItem(
              selected: widget.pageIndex == 0,
              icon: const Icon(Icons.restaurant_menu),
              selectedSize: _selectedIconSize,
              unselectedSize: _unselectedIconSize,
              onTap: () {
                widget.setIndex(0);
              },
            ),
            CustomBottomNavigationBarItem(
              selected: widget.pageIndex == 1,
              icon: const Icon(Icons.format_list_bulleted),
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
                /*=> Provider.of<ProductsProvider>(context, listen: false).addProduct(
                          Product(
                              id: DateTime.now().toString(),
                              title: 'Porzella esplosiva',
                              expiration: DateTime.now(),
                              image: null),
                        ),*/ //Navigator.of(context).pushNamed(AddProductScreen.routeName),
                child: widget.pageIndex == 2
                    ? const FittedBox(
                        child: Icon(
                          Icons.add,
                        ),
                      )
                    : const FittedBox(
                        child: Icon(Icons.home_filled),
                      ),
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(bottomNavigationSize.outlineBorder),
                  padding: MaterialStateProperty.all(EdgeInsets.all(bottomNavigationSize.mainButtonInternalPadding)),
                  backgroundColor: widget.pageIndex == 2
                      ? MaterialStateProperty.all(Colors.indigoAccent)
                      : MaterialStateProperty.all(Colors.indigo[400]), // <-- Button color
                ),
              ),
            ),
            CustomBottomNavigationBarItem(
              selected: widget.pageIndex == 3,
              icon: const Icon(Icons.auto_graph),
              selectedSize: _selectedIconSize,
              unselectedSize: _unselectedIconSize,
              onTap: () {
                widget.setIndex(3);
              },
            ),
            CustomBottomNavigationBarItem(
              selected: widget.pageIndex == 4,
              icon: const Icon(Icons.supervisor_account),
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
