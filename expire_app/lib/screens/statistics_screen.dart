/* dart */
import 'package:expire_app/widgets/statistics_container.dart';
import 'package:flutter/material.dart';

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

  @override
  Widget build(BuildContext context) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      color: styles.primaryColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              margin: EdgeInsets.only(
                  top: MediaQuery.of(context).orientation == Orientation.portrait
                      ? MediaQuery.of(context).size.height * 0.055
                      : 10.0),
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
                      style: styles.title,
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
      ),
    );
  }
}
