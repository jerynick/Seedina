import 'package:flutter/material.dart';
import 'package:seedina/utils/rewidgets/contentbox/for_monitoring/monitoringbox.dart';
import 'package:seedina/utils/style/gcolor.dart';

class MonitoringCard extends StatelessWidget {
  final String title;
  final String value;
  final double textTitleSize;
  final double textValueSize;
  final String unit;
  final String conditionText;
  final Color conditionColor;
  final IconData conditionIcon;

  const MonitoringCard({
    super.key,
    required this.title,
    required this.value,
    required this.textTitleSize,
    required this.textValueSize,
    required this.unit,
    required this.conditionText,
    required this.conditionColor,
    required this.conditionIcon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 136,
      width: MediaQuery.of(context).size.width,
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
                color: GColors.shadowColor.withOpacity(0.2), // Slightly softer shadow
                blurRadius: 6, // Increased blur
                spreadRadius: 1, // Slight spread
                offset: Offset(0, 3) // Adjusted offset
                )
          ]),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            MonitoringBox(
                title: title,
                value: value,
                textTitleSize: textTitleSize,
                textValueSize: textValueSize,
                unit: unit),
            SizedBox(
              width: 24, // Adjusted spacing
            ),
            Expanded( // Allow condition to take remaining space
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Icon(
                    conditionIcon,
                    color: conditionColor,
                    size: 48, // Larger icon
                  ),
                  SizedBox(height: 8),
                  Text(
                    conditionText,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontSize: 15, // Slightly larger text
                        fontWeight: FontWeight.w600, // Bolder
                        color: conditionColor),
                    overflow: TextOverflow.ellipsis, // Handle long text
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}