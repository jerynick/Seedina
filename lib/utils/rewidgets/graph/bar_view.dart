import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:seedina/utils/rewidgets/graph/bar_data.dart';

class MyBarGraph extends StatelessWidget {
  final List sensorData;
  final Color? color;
  final double maxDataGraph;

  const MyBarGraph({
    super.key, 
    required this.sensorData,
    required this.color,
    required this.maxDataGraph
    });

  @override
  Widget build(BuildContext context) {
    BarData myBarData = BarData(
        jamPertama: sensorData[0],
        jamKedua: sensorData[1],
        jamKetiga: sensorData[2],
        jamKeempat: sensorData[3],
        jamKelima: sensorData[4],
        jamKeenam: sensorData[5],
        jamKetujuh: sensorData[6],
        jamKedelapan: sensorData[7]);
    myBarData.initializedBarData();

    return Padding(
      padding: const EdgeInsets.only(top: 20.0, bottom: 20.0),
      child: BarChart(BarChartData(
        minY: 0,
        maxY: maxDataGraph,
        gridData: FlGridData(show: false),
        borderData: FlBorderData(show: false),
        titlesData: FlTitlesData(
          show: true,
          topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
        ),
        barGroups: myBarData.barData
            .map((data) => BarChartGroupData(
                  x: data.x,
                  barRods: [
                    BarChartRodData(
                      toY: data.y,
                      color: color,
                      width: 20,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(10),
                        topRight: Radius.circular(10),
                      ),
                      backDrawRodData: BackgroundBarChartRodData(
                        show: true,
                        toY: maxDataGraph,
                        color: Colors.grey[300]
                      )
                    )
                  ]
                ))
            .toList(),
      )),
    );
  }
}
