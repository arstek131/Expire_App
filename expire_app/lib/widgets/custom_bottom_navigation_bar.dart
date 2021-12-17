/* dart */
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

/* providers */
import '../providers/products_provider.dart';

/* widgets */
import '../widgets/custom_bottom_navigation_bar_item.dart';

/* models */
import '../models/product.dart';

/* screens */
import '../screens/add_product_screen.dart';

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
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      margin: const EdgeInsets.only(bottom: 20),
      height: 85,
      child: Container(
        width: double.infinity,
        decoration: const BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 7,
              spreadRadius: 1,
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
              selectedSize: 40,
              unselectedSize: 35,
              onTap: () {
                widget.setIndex(0);
              },
            ),
            CustomBottomNavigationBarItem(
              selected: widget.pageIndex == 1,
              icon: const Icon(Icons.format_list_bulleted),
              selectedSize: 40,
              unselectedSize: 35,
              onTap: () {
                widget.setIndex(1);
              },
            ),
            Container(
              margin: widget.pageIndex == 2 ? const EdgeInsets.only(bottom: 10) : EdgeInsets.zero,
              child: ElevatedButton(
                onPressed: widget.pageIndex != 2
                    ? () => widget.setIndex(2)
                    : () => Navigator.of(context).pushNamed(AddProductScreen.routeName),
                child: widget.pageIndex == 2
                    ? const Icon(
                        Icons.add,
                        size: 30,
                      )
                    : const Icon(
                        Icons.home_filled,
                        size: 25,
                      ),
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(const CircleBorder()),
                  padding: MaterialStateProperty.all(const EdgeInsets.all(15)),
                  backgroundColor: widget.pageIndex == 2
                      ? MaterialStateProperty.all(Colors.indigoAccent)
                      : MaterialStateProperty.all(Colors.indigo[400]), // <-- Button color
                ),
              ),
            ),
            CustomBottomNavigationBarItem(
              selected: widget.pageIndex == 3,
              icon: const Icon(Icons.auto_graph),
              selectedSize: 40,
              unselectedSize: 35,
              onTap: () {
                widget.setIndex(3);
              },
            ),
            CustomBottomNavigationBarItem(
              selected: widget.pageIndex == 4,
              icon: const Icon(Icons.supervisor_account),
              selectedSize: 40,
              unselectedSize: 35,
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
