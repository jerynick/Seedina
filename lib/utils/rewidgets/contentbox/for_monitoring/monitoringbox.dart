import "package:flutter/material.dart";
import "package:seedina/utils/style/gcolor.dart";

class MonitoringBox extends StatelessWidget {

  final String title;
  final String value;
  final double textTitleSize;
  final double textValueSize;
  final String unit;

  const MonitoringBox({
    super.key,
    required this.title,
    required this.value,
    required this.textTitleSize,
    required this.textValueSize,
    required this.unit
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 100,
      width: 100,
      decoration: BoxDecoration(
        color: Colors.white,
        //border: Border.all(color: Colors.black, width: 0.2),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: GColors.shadowColor,
              blurRadius: 2,
              spreadRadius: 1,
              offset: Offset(0, 2))
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              title,
              style: TextStyle(fontSize: textTitleSize, fontWeight: FontWeight.w600),
            ),
            Text(
              value,
              style: TextStyle(fontSize: textValueSize, fontWeight: FontWeight.w100),
            ),
            Text(
              unit,
              style: TextStyle(fontSize: 10, fontWeight: FontWeight.w600),
            ),
          ],
        ),
      ),
    );
  }
}