import 'package:flutter/material.dart';

class BottomNavigationBarSizeProvider extends ChangeNotifier {
  double _height = 75.0;
  double _bottomPadding = 20.0;
  double _mainButtonInternalPadding = 15;
  double _iconSizeOffset = 0;
  OutlinedBorder _outlineBorder = RoundedRectangleBorder(borderRadius: BorderRadius.circular(300)); //const CircleBorder();
  BoxDecoration _decoration = const BoxDecoration(
    boxShadow: [
      BoxShadow(
        color: Colors.black26,
        blurRadius: 7,
        spreadRadius: 4,
        offset: Offset(0, 5),
      ),
    ],
    color: Colors.white,
    borderRadius: BorderRadius.all(
      Radius.circular(10.0),
    ),
  );

  double get height {
    return _height;
  }

  double get bottomPadding {
    return _bottomPadding;
  }

  double get mainButtonInternalPadding {
    return _mainButtonInternalPadding;
  }

  double get iconSizeOffset {
    return _iconSizeOffset;
  }

  OutlinedBorder get outlineBorder {
    return _outlineBorder;
  }

  BoxDecoration get decoration {
    return _decoration;
  }

  void notifyShrink() {
    _height = 65.0;
    _bottomPadding = 10;
    _mainButtonInternalPadding = 13;
    _iconSizeOffset = 3;
    _outlineBorder = RoundedRectangleBorder(borderRadius: BorderRadius.circular(500));
    _decoration = BoxDecoration(
      boxShadow: const [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 7,
          spreadRadius: 2,
          offset: Offset(0, 2),
        ),
      ],
      color: Colors.white.withOpacity(0.8),
      borderRadius: const BorderRadius.all(
        Radius.circular(10.0),
      ),
    );
    notifyListeners();
  }

  void notifyGrow() {
    _height = 75.0;
    _bottomPadding = 20;
    _mainButtonInternalPadding = 15;
    _iconSizeOffset = 0;
    _outlineBorder = RoundedRectangleBorder(borderRadius: BorderRadius.circular(300)); //CircleBorder();
    _decoration = const BoxDecoration(
      boxShadow: [
        BoxShadow(
          color: Colors.black26,
          blurRadius: 7,
          spreadRadius: 4,
          offset: Offset(0, 5),
        ),
      ],
      color: Colors.white,
      borderRadius: BorderRadius.all(
        Radius.circular(10.0),
      ),
    );
    notifyListeners();
  }
}
