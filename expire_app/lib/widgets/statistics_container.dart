import 'package:expire_app/models/chartdata.dart';
import 'package:expire_app/providers/chart_provider.dart';
import 'package:flutter/material.dart';
import 'package:googleapis/workflowexecutions/v1.dart';
import 'package:syncfusion_flutter_charts/charts.dart';
import 'package:syncfusion_flutter_charts/sparkcharts.dart';

/* helpers */
import '../helpers/firebase_auth_helper.dart';

/* styles */
import '../app_styles.dart' as styles;

class StatisticsContainer extends StatefulWidget {
  StatisticsContainer();

  @override
  _StatisticsContainerState createState() => _StatisticsContainerState();
}

class _StatisticsContainerState extends State<StatisticsContainer> {
  FirebaseAuthHelper _auth = FirebaseAuthHelper.instance;
  late List<GDPData> _chartData = [];

  @override
  void initState() {
    _chartData = getChartData();
    super.initState();
  }

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
    return SafeArea(
        child: Scaffold(
          body: SingleChildScrollView(
            child: SfCircularChart(
              title: ChartTitle(text: 'Lorem Ipsum'),
              legend: Legend(isVisible: true, overflowMode: LegendItemOverflowMode.wrap),
              series: <CircularSeries>[
                DoughnutSeries<GDPData, String>(
                    dataSource: _chartData,
                    xValueMapper: (GDPData data, _) => data.continent,
                    yValueMapper: (GDPData data, _) => data.gdp,
                    dataLabelSettings: DataLabelSettings(isVisible: true))
              ],
            ),
          ),
        ));
  }

  List<GDPData> getChartData() {
    final List<GDPData> charData = [
      GDPData('Oceania', 1600),
      GDPData('Africa', 2490),
      GDPData('S America', 2900),
      GDPData('Europe', 23050),
      GDPData('N America', 24880),
      GDPData('Asia', 34390),
    ];
    return charData;
  }
}

class GDPData {
  GDPData(this.continent, this.gdp);

  final String continent;
  final int gdp;
}
