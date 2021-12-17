import 'package:flutter/material.dart';

class CustomBottomNavigationBarItem extends StatelessWidget {
  final Icon icon;
  final VoidCallback onTap;
  final bool selected;

  CustomBottomNavigationBarItem({required this.icon, required this.onTap, required this.selected});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          padding: const EdgeInsets.all(0),
          iconSize: 35,
          color: Colors.indigoAccent,
          icon: icon,
          onPressed: onTap,
        ),
        if (selected)
          Container(
            decoration: const BoxDecoration(
              color: Colors.orange,
              shape: BoxShape.circle,
            ),
            height: 5,
            width: 5,
          )
      ],
    );
  }
}
