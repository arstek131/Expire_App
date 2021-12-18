import 'package:flutter/material.dart';

import 'products_provider.dart';

class BottomNavigationBarSizeProvider extends ChangeNotifier {
  double _height = 75.0;
  double _bottomPadding = 40.0;
  double _mainButtonInternalPadding = 15;
  double _iconSizeOffset = 0;
  OutlinedBorder _outlineBorder = const CircleBorder();

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

  void notifyShrink() {
    _height = 60.0;
    _bottomPadding = 20;
    _mainButtonInternalPadding = 13;
    _iconSizeOffset = 3;
    _outlineBorder = RoundedRectangleBorder(borderRadius: BorderRadius.circular(500));
    notifyListeners();
  }

  void notifyGrow() {
    _height = 75.0;
    _bottomPadding = 40;
    _mainButtonInternalPadding = 15;
    _iconSizeOffset = 0;
    _outlineBorder = RoundedRectangleBorder(borderRadius: BorderRadius.circular(300)); //CircleBorder();
    notifyListeners();
  }
}
