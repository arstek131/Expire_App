import 'package:expire_app/providers/chart_provider.dart';
import 'package:expire_app/providers/products_provider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:syncfusion_flutter_charts/charts.dart';

/* helpers */
import '../helpers/firebase_auth_helper.dart';

/* styles */
import '../app_styles.dart' as styles;


class StatisticsContainer extends StatelessWidget {
  final FirebaseAuthHelper _auth = FirebaseAuthHelper.instance;


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
    return SingleChildScrollView(
      padding: EdgeInsets.only(bottom: 80),
            child: Consumer<ProductsProvider>(
              builder: (context, productprovider, child){
                return  Column(
                  children: [
                    buildChart(0, 'Sugar', context),
                    buildChart(1, 'Fat', context),
                    buildChart(2, 'Saturated fat', context),
                    buildChart(3, 'Salt', context),
                  ],
                );
              }

            ),

        );
  }

  SfCircularChart buildChart(int index, String title, BuildContext context) {
    return SfCircularChart(
            title: ChartTitle(text: title),
            legend: Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
            series: <CircularSeries>[
              DoughnutSeries<dynamic, String>(
                  dataSource: getDataSource(index, context),
                  xValueMapper: (dynamic data, _) => data.type,
                  yValueMapper: (dynamic data, _) => data.value,
                  dataLabelSettings: DataLabelSettings(isVisible: true))
            ],
          );
  }

  List<dynamic> getDataSource(int index, BuildContext context){
    List<dynamic> source = ChartManager.getChartData(context, index);
    print(source.toString());
     return source;

  }


}


