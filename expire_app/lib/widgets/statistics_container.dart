import 'package:expire_app/models/chart_manager.dart';
import 'package:expire_app/providers/products_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/* styles */
import '../app_styles.dart' as styles;
import '../helpers/device_info.dart';
import '../helpers/firebase_auth_helper.dart';

class StatisticsContainer extends StatelessWidget {
  final FirebaseAuthHelper _auth = FirebaseAuthHelper();

  DeviceInfo _deviceInfo = DeviceInfo.instance;

  @override
  Widget build(BuildContext context) {
    if (!_auth.isAuth) {
      return Stack(
        children: [
          Positioned.fill(
              // replace with blurred image
              top: 0,
              bottom: 0,
              child: Container(
                color: Colors.red,
              )),
          AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(
                Radius.circular(10.0),
              ),
            ),
            alignment: Alignment.center,
            title: Text(
              "Premium feature",
              textAlign: TextAlign.center,
            ),
            content: Text(
              "This is a premium feature! Please register to fully unlock the functionalities of the app",
              textAlign: TextAlign.center,
            ),
            titleTextStyle: TextStyle(
              fontFamily: styles.currentFontFamily,
              fontWeight: FontWeight.bold,
              fontSize: 25,
            ),
            contentTextStyle: TextStyle(
              fontFamily: styles.currentFontFamily,
              fontSize: 16,
            ),
            backgroundColor: styles.deepAmber,
          ),
        ],
      );
    }
    return Consumer<ProductsProvider>(
      builder: (context, productprovider, child) {
        return productprovider.items.isEmpty
            ? Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: Text(
                    "No statistics available. Add a new produc in the home screen!",
                    textAlign: TextAlign.center,
                    style: styles.subheading,
                  ),
                ),
              )
            : _deviceInfo.isPhonePotrait(context)
                ? SingleChildScrollView(
                    padding: EdgeInsets.only(bottom: 80),
                    child: Card(
                      color: Colors.transparent,
                      child: Column(
                        children: [
                          buildChart(0, 'Sugar', context),
                          buildChart(1, 'Fat', context),
                          buildChart(2, 'Saturated fat', context),
                          buildChart(3, 'Salt', context),
                        ],
                      ),
                    ))
                : Padding(
                    padding: const EdgeInsets.all(70.0),
                    child: GridView(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: _deviceInfo.isTabletLandscape(context) ? 3 : 2),
                      children: [
                        buildChart(0, 'Sugar', context),
                        buildChart(1, 'Fat', context),
                        buildChart(2, 'Saturated fat', context),
                        buildChart(3, 'Salt', context),
                      ],
                    ),
                  );
      },
    );
  }

  SfCircularChart buildChart(int index, String title, BuildContext context) {
    return SfCircularChart(
      title: ChartTitle(
        text: title,
        textStyle: _deviceInfo.isTablet ? styles.title : styles.subtitle,
        alignment: _deviceInfo.isTablet ? ChartAlignment.near : ChartAlignment.center,
      ),
      legend: Legend(
          isVisible: true,
          overflowMode: LegendItemOverflowMode.wrap,
          textStyle: styles.robotoMedium16.copyWith(color: Colors.white)),
      series: <CircularSeries>[
        DoughnutSeries<dynamic, String>(
            dataSource: getDataSource(index, context),
            xValueMapper: (dynamic data, _) => data.type,
            yValueMapper: (dynamic data, _) => data.value,
            dataLabelSettings: DataLabelSettings(isVisible: false),
            pointColorMapper: (dynamic data, _) => data.color),
      ],
    );
  }

  List<dynamic> getDataSource(int index, BuildContext context) {
    return ChartManager.getChartData(context, index);
  }
}
