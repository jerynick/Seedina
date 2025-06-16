import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seedina/menu_page/monitoring/main_charts.dart';
import 'package:seedina/provider/rtdb_handler.dart';
import 'package:seedina/utils/rewidgets/global/mynav.dart';
import 'package:seedina/utils/rewidgets/contentbox/for_monitoring/monitoringbox.dart';
import 'package:seedina/utils/rewidgets/contentbox/for_monitoring/monitoringcard.dart';
import 'package:seedina/utils/style/gcolor.dart';

class MonitoringScreen extends StatefulWidget {
  const MonitoringScreen({super.key});

  @override
  State<MonitoringScreen> createState() => _MonitoringScreenState();
}

class _MonitoringScreenState extends State<MonitoringScreen> {
  Map<String, dynamic> _determineCondition(
      double currentValue, dynamic minIdealVal, dynamic maxIdealVal, String type) {
    String text;
    Color color;
    IconData icon;

    double minIdeal = 0.0;
    if (minIdealVal is int) {
      minIdeal = minIdealVal.toDouble();
    } else if (minIdealVal is double) {
      minIdeal = minIdealVal;
    } else if (minIdealVal is String) {
      minIdeal = double.tryParse(minIdealVal) ?? 0.0;
    }

    double maxIdeal = 0.0;
    if (maxIdealVal is int) {
      maxIdeal = maxIdealVal.toDouble();
    } else if (maxIdealVal is double) {
      maxIdeal = maxIdealVal;
    } else if (maxIdealVal is String) {
      maxIdeal = double.tryParse(maxIdealVal) ?? 0.0;
    }

    double extremeLowThreshold = minIdeal - (maxIdeal - minIdeal) * 0.10;
    double extremeHighThreshold = maxIdeal + (maxIdeal - minIdeal) * 0.10;

    if (type == "temp") {
        if (currentValue < extremeLowThreshold) {
            text = "Sangat Dingin";
            color = Colors.blue.shade800;
            icon = Icons.ac_unit_sharp;
        } else if (currentValue < minIdeal) {
            text = "Dingin";
            color = Colors.lightBlue.shade400;
            icon = Icons.thermostat_auto_rounded;
        } else if (currentValue <= maxIdeal) {
            text = "Normal";
            color = Colors.green.shade600;
            icon = Icons.check_circle_outline_rounded;
        } else if (currentValue <= extremeHighThreshold) {
            text = "Panas";
            color = Colors.orange.shade700;
            icon = Icons.local_fire_department_outlined;
        } else {
            text = "Sangat Panas";
            color = Colors.red.shade700;
            icon = Icons.error_outline_rounded;
        }
    } else if (type == "humi") {
        if (currentValue < extremeLowThreshold) {
            text = "Sangat Kering";
            color = Colors.brown.shade400;
            icon = Icons.grain_rounded;
        } else if (currentValue < minIdeal) {
            text = "Kering";
            color = Colors.yellow.shade700;
            icon = Icons.wb_sunny_outlined;
        } else if (currentValue <= maxIdeal) {
            text = "Lembap Ideal";
            color = Colors.green.shade600;
            icon = Icons.opacity_rounded;
        } else if (currentValue <= extremeHighThreshold) {
            text = "Terlalu Lembap";
            color = Colors.blueGrey.shade500;
            icon = Icons.water_drop_outlined;
        } else {
            text = "Sangat Lembap";
            color = Colors.blue.shade900;
            icon = Icons.flood_outlined;
        }
    } else {
        if (currentValue < minIdeal) {
            text = "Rendah";
            color = Colors.orange;
            icon = Icons.arrow_downward_rounded;
        } else if (currentValue > maxIdeal) {
            text = "Tinggi";
            color = Colors.red;
            icon = Icons.arrow_upward_rounded;
        } else {
            text = "Normal";
            color = Colors.green;
            icon = Icons.check_circle_outline_rounded;
        }
    }
    return {'text': text, 'color': color, 'icon': icon};
  }


  @override
  Widget build(BuildContext context) {
    final provider = context.watch<HandlingProvider>();
    double ecAir = provider.ecAir;
    int tdsAir = provider.tdsAir;
    double tinggiAir = provider.tinggiAir;
    double suhuAir = provider.suhuAir;
    double suhuLing = provider.suhuLing;
    int humiLing = provider.humiLing;


    final Map<String, dynamic> paramsForCondition = provider.activeParameters.isNotEmpty
                                      ? provider.activeParameters
                                      : provider.parameters['Kustom']!; // Fallback if ActiveParameters is Empty

    final Map<String, dynamic> suhuAirCondition = _determineCondition(
        suhuAir,
        paramsForCondition['min_suhuair'] ?? 0.0,
        paramsForCondition['max_suhuair'] ?? 0.0,
        "temp");

    final Map<String, dynamic> suhuLingCondition = _determineCondition(
        suhuLing,
        paramsForCondition['min_suhuling'] ?? 0.0,
        paramsForCondition['max_suhuling'] ?? 0.0,
        "temp");

    final Map<String, dynamic> humiLingCondition = _determineCondition(
        humiLing.toDouble(),
        paramsForCondition['min_humiling'] ?? 0.0,
        paramsForCondition['max_humiling'] ?? 0.0,
        "humi");


    return Scaffold(
      backgroundColor: GColors.myHijau,
      body: SingleChildScrollView(
          child: Stack(children: [
        Column(
          children: [
            const SizedBox(
              height: 200,
            ),
            Container(
              width: MediaQuery.of(context).size.width,
              constraints: BoxConstraints(minHeight: MediaQuery.of(context).size.height - 44),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(20),
                    topRight: Radius.circular(20)),
              ),
            ),
          ],
        ),
        Padding(
            padding: EdgeInsets.only(left: 16, right: 16, bottom: 80),
            child: Align(
                alignment: Alignment.topCenter,
                child: Padding(
                    padding: EdgeInsets.only(top: 120),
                    child: Column(
                      children: [
                        Container(
                          width: MediaQuery.of(context).size.width,
                          decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(16),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.black.withOpacity(0.25),
                                    blurRadius: 4,
                                    spreadRadius: 0,
                                    offset: Offset(0, 4))
                              ]),
                          child: Padding(
                            padding: const EdgeInsets.all(12.0),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  'Monitoring Sistem Aeroponik',
                                  style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w700),
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(16)),
                                      backgroundColor: GColors.myBiru),
                                  onPressed: () {
                                    GNav.slideNavStateless(
                                        context, MainCharts());
                                  },
                                  child: const Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(
                                        Icons.bar_chart,
                                        color: Colors.white,
                                      ),
                                      SizedBox(width: 8),
                                      Text(
                                        'Lihat Grafik Data Historis',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    MonitoringBox(
                                        title: 'EC Air',
                                        value: ecAir.toStringAsFixed(1),
                                        textTitleSize: 12,
                                        textValueSize: 32,
                                        unit: 'mS/cm'),
                                    MonitoringBox(
                                        title: 'Nutrisi Air',
                                        value: '$tdsAir',
                                        textTitleSize: 12,
                                        textValueSize: 32,
                                        unit: 'ppm'),
                                    MonitoringBox(
                                        title: 'Tinggi Air',
                                        value: tinggiAir.toStringAsFixed(1),
                                        textTitleSize: 12,
                                        textValueSize: 32,
                                        unit: 'cm')
                                  ],
                                ),
                                SizedBox(
                                  height: 12,
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        MonitoringCard(
                          title: 'Suhu Air',
                          value: suhuAir.toStringAsFixed(1),
                          textTitleSize: 12,
                          textValueSize: 32,
                          unit: '°C',
                          conditionText: suhuAirCondition['text'],
                          conditionColor: suhuAirCondition['color'],
                          conditionIcon: suhuAirCondition['icon'],
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        MonitoringCard(
                          title: 'Suhu Lingk.',
                          value: suhuLing.toStringAsFixed(1),
                          textTitleSize: 11,
                          textValueSize: 32,
                          unit: '°C',
                          conditionText: suhuLingCondition['text'],
                          conditionColor: suhuLingCondition['color'],
                          conditionIcon: suhuLingCondition['icon'],
                        ),
                        SizedBox(
                          height: 24,
                        ),
                        MonitoringCard(
                          title: 'Kelembaban',
                          value: '$humiLing',
                          textTitleSize: 12,
                          textValueSize: 32,
                          unit: ' %',
                          conditionText: humiLingCondition['text'],
                          conditionColor: humiLingCondition['color'],
                          conditionIcon: humiLingCondition['icon'],
                        ),
                         SizedBox(
                          height: 24,
                        ),
                      ],
                    ))))
      ])),
    );
  }
}