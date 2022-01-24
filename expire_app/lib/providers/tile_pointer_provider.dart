import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:math';

class TilePointerProvider extends ChangeNotifier {
  TilePointerProvider();

  void init() {}

  bool _notifyPointerEvent = false;
  double _horizontalScroll = 0.0;
  double _totalWidth = 0.0;
  bool _flag = true;
  double _offset = 0.0;
  double _initialPos = 0.0;
  bool _overThreshold = false;

  bool get notifyPointerEvent {
    return _notifyPointerEvent;
  }

  double get horizontalScroll {
    return _horizontalScroll;
  }

  bool get overThreshold {
    return _overThreshold;
  }

  bool get flag {
    return _flag;
  }

  double get offset {
    return _offset;
  }

  double get offsetPercentage {
    double perc = _offset / totalWidth;
    return perc.isNaN ? 0.0 : perc;
  }

  double get totalWidth {
    return _totalWidth;
  }

  double get initialPos {
    return _initialPos;
  }

  void set notifyPointerEvent(bool value) {
    _notifyPointerEvent = value;
    notifyListeners();
  }

  void set horizontalScroll(double value) {
    _horizontalScroll = value;
    _offset = (initialPos - _horizontalScroll).abs();
    notifyListeners();
  }

  void set offset(double value) {
    _offset = value;
    notifyListeners();
  }

  void set initialPos(double value) {
    _initialPos = value;
    notifyListeners();
  }

  void set totalWidth(double value) {
    _totalWidth = value;
    notifyListeners();
  }

  void set overThreshold(bool value) {
    _overThreshold = value;
    notifyListeners();
  }

  void set flag(bool value) {
    _flag = value;
    notifyListeners();
  }

  void initProvider({required double initPos, required double totalWidth}) {
    _initialPos = initPos;
    _totalWidth = totalWidth;
  }

  void clearProvider() {
    _notifyPointerEvent = false;
    _horizontalScroll = 0.0;
    _overThreshold = false;
    _flag = true;
    _offset = 0;
    _initialPos = 0;
    _totalWidth = 0;
    notifyListeners();
  }
}
