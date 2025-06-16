import 'package:flutter/material.dart';

class InfoColumn extends StatelessWidget {
  final String title;
  final double fontSize;
  final double space;
  final String value;

  const InfoColumn(
      {super.key,
      required this.title,
      required this.fontSize,
      required this.space,
      required this.value});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 12),
          ),
          SizedBox(
            height: space,
          ),
          Text(
            value,
            style: TextStyle(fontSize: fontSize),
          )
        ],
      ),
    );
  }
}