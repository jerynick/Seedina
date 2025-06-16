import 'package:flutter/material.dart';

class SettingBox extends StatelessWidget {

  final String title;
  final List<Widget> menu;

  const SettingBox({
    super.key,
    required this.title,
    required this.menu
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: 28,),
        Text(title, style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),),
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
                offset: const Offset(0, 2))
              ]
            ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ...menu
            ],
          ),
        ),
      ],
    );
  }
}
