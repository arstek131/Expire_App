/* dart */
import 'package:expire_app/widgets/statistics_container.dart';
import 'package:flutter/material.dart';
import '../helpers/device_info.dart';

/* styles */
import '../app_styles.dart' as styles;

class StatisticsScreen extends StatefulWidget {
  const StatisticsScreen();

  @override
  _StatisticsScreenState createState() => _StatisticsScreenState();
}

class _StatisticsScreenState extends State<StatisticsScreen> with AutomaticKeepAliveClientMixin<StatisticsScreen> {
  // Keep page state alive
  @override
  bool get wantKeepAlive => true;

  DeviceInfo _deviceInfo = DeviceInfo.instance;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: styles.primaryColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Container(
            padding: EdgeInsets.only(
              top: _deviceInfo.sizeDispatcher(
                context: context,
                phonePotrait: MediaQuery.of(context).size.height * 0.055,
                phoneLandscape: 10,
                tabletPotrait: 10,
                tabletLandscape: MediaQuery.of(context).size.height * 0.08,
              ),
              bottom: _deviceInfo.sizeDispatcher(
                context: context,
                phonePotrait: 0,
                phoneLandscape: 0,
                tabletPotrait: 10,
                tabletLandscape: 30,
              ),
            ),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  styles.primaryColor,
                  styles.primaryColor.withOpacity(0.6),
                ],
                stops: [0.9, 1],
              ),
              shape: BoxShape.rectangle,
              color: Colors.pinkAccent,
              boxShadow: [
                BoxShadow(
                  color: Colors.indigo.shade700,
                  offset: const Offset(0, 10),
                  blurRadius: 5.0,
                  spreadRadius: 1,
                )
              ],
            ),
            child: Padding(
              padding: EdgeInsets.only(
                top: MediaQuery.of(context).orientation == Orientation.portrait ? 56 : 0,
                left: 20,
                right: 30,
                bottom: MediaQuery.of(context).orientation == Orientation.portrait ? 30 : 10,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Text(
                    "Statistics",
                    style: _deviceInfo.isPhone ? styles.title : styles.title.copyWith(fontSize: 43),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: Container(
                child: StatisticsContainer(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
