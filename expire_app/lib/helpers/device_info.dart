/* dart */
import 'package:flutter/material.dart';

class DeviceInfo {
  /* singleton */
  DeviceInfo._privateConstructor() {
    _windowData = MediaQueryData.fromWindow(WidgetsBinding.instance!.window);

    _deviceWidth = _windowData.size.width;
    _deviceHeight = _windowData.size.height;
    _shortestSide = _windowData.size.shortestSide;

    _isPhone = _shortestSide < 550;
    _isTablet = !_isPhone;
  }

  static final DeviceInfo _instance = DeviceInfo._privateConstructor();

  static DeviceInfo get instance => _instance;

  /* variables */
  late final MediaQueryData _windowData;
  late final double _deviceWidth;
  late final double _deviceHeight;
  late final double _shortestSide;
  late final bool _isTablet;
  late final bool _isPhone;

  /* getters */
  get windowData => this._windowData;
  get deviceWidth => this._deviceWidth;
  get deviceHeight => this._deviceHeight;
  get shortestSide => this._shortestSide;

  get isTablet => this._isTablet;
  get isNotTablet => !this._isTablet;
  get isPhone => this._isPhone;
  get isNotPhone => !this._isPhone;

  /* other */
  bool isPotrait(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.portrait;
  }

  bool isNotPotrait(BuildContext context) {
    return !isPotrait(context);
  }

  bool isLandscape(BuildContext context) {
    return MediaQuery.of(context).orientation == Orientation.landscape;
  }

  bool isNotLandscape(BuildContext context) {
    return !isLandscape(context);
  }

  bool isPhonePotrait(BuildContext context) {
    return this._isPhone && this.isPotrait(context);
  }

  bool isPhoneLandscape(BuildContext context) {
    return this._isPhone && this.isLandscape(context);
  }

  bool isTabletPotrait(BuildContext context) {
    return this._isTablet && this.isPotrait(context);
  }

  bool isTabletLandscape(BuildContext context) {
    return this._isTablet && this.isLandscape(context);
  }
}
