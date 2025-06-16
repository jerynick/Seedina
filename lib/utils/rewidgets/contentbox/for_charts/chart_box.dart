import 'package:flutter/material.dart';
import 'package:seedina/utils/rewidgets/graph/bar_view.dart';

class BarGraphBox extends StatefulWidget {
  
  final String title;
  final num dataPertama;
  final num dataKedua;
  final num dataKetiga;
  final num dataKeempat;
  final num dataKelima;
  final num dataKeenam;
  final num dataKetujuh;
  final num dataKedelapan;
  final Color? graphColor;
  final String description;
  final double maxDataGraph;

  const BarGraphBox({
    super.key,
    required this.title,
    required this.dataPertama,
    required this.dataKedua,
    required this.dataKetiga,
    required this.dataKeempat,
    required this.dataKelima,
    required this.dataKeenam,
    required this.dataKetujuh,
    required this.dataKedelapan,
    required this.graphColor,
    required this.description,
    required this.maxDataGraph
  });

  @override
  State<BarGraphBox> createState() => _BarGraphBoxState();
}

class _BarGraphBoxState extends State<BarGraphBox> {
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Container(
        padding: const EdgeInsets.all(16.0),
        //height: 375,
        width: MediaQuery.of(context).size.width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 10,
              offset: Offset(0, 5),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Judul Grafik
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),

            // Grafik batang (Bar Graph)
            SizedBox(
              height: 225,
              child: MyBarGraph(
                maxDataGraph: widget.maxDataGraph,
                sensorData: [
                  widget.dataPertama, 
                  widget.dataKedua, 
                  widget.dataKetiga, 
                  widget.dataKeempat, 
                  widget.dataKelima, 
                  widget.dataKeenam, 
                  widget.dataKetujuh, 
                  widget.dataKedelapan,
                ],
                color: widget.graphColor,
              ),
            ),

            const SizedBox(height: 8),

            // Keterangan
            Text(
              widget.description,
              style: TextStyle(
                fontSize: 14,
                color: Colors.black54,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
