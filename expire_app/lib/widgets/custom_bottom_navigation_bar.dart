import 'package:flutter/material.dart';
import '../widgets/custom_bottom_navigation_bar_item.dart';

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
              icon: const Icon(Icons.restaurant_menu, size: 40),
              onTap: () {
                widget.setIndex(0);
              },
            ),
            CustomBottomNavigationBarItem(
              selected: widget.pageIndex == 1,
              icon: const Icon(Icons.format_list_bulleted, size: 40),
              onTap: () {
                widget.setIndex(1);
              },
            ),
            Container(
              margin: widget.pageIndex == 2 ? EdgeInsets.only(bottom: 10) : null,
              child: ElevatedButton(
                onPressed: () => widget.pageIndex != 2
                    ? widget.setIndex(2)
                    : () {
                        showDialog<String>(
                          context: context,
                          builder: (BuildContext context) => AlertDialog(
                            title: const Text('AlertDialog Title'),
                            content: const Text('AlertDialog description'),
                            actions: <Widget>[
                              TextButton(
                                onPressed: () => Navigator.pop(context, 'Cancel'),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, 'OK'),
                                child: const Text('OK'),
                              ),
                            ],
                          ),
                        );
                      },
                child: widget.pageIndex == 2
                    ? const Icon(
                        Icons.add,
                        size: 30,
                      )
                    : const Icon(
                        Icons.home_filled,
                        size: 30,
                      ),
                style: ButtonStyle(
                  shape: MaterialStateProperty.all(const CircleBorder()),
                  padding: MaterialStateProperty.all(const EdgeInsets.all(15)),
                  backgroundColor: MaterialStateProperty.all(Colors.indigoAccent), // <-- Button color
                ),
              ),
            ),
            CustomBottomNavigationBarItem(
              selected: widget.pageIndex == 3,
              icon: const Icon(Icons.auto_graph, size: 40),
              onTap: () {
                widget.setIndex(3);
              },
            ),
            CustomBottomNavigationBarItem(
              selected: widget.pageIndex == 4,
              icon: const Icon(Icons.supervisor_account, size: 40),
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
