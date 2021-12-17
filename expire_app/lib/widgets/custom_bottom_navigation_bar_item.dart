import 'package:flutter/material.dart';

class CustomBottomNavigationBarItem extends StatelessWidget {
  final Icon icon;
  final double selectedSize;
  final double unselectedSize;
  final VoidCallback onTap;
  final bool selected;

  CustomBottomNavigationBarItem(
      {required this.icon, required this.onTap, required this.selected, this.selectedSize = 50, this.unselectedSize = 35});

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        IconButton(
          padding: const EdgeInsets.all(0),
          iconSize: selected ? selectedSize : unselectedSize,
          color: selected ? Colors.indigoAccent : Colors.grey,
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
