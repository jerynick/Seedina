// ignore_for_file: prefer_const_constructors

import 'package:flutter/material.dart';
import 'package:seedina/utils/style/gcolor.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget title;
  final List<Widget> actions;
  final bool showBackButton;

  const CustomAppBar({
    super.key,
    required this.title,
    required this.actions,
    required this.showBackButton
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      //padding: EdgeInsets.only(left: 4, right: 4),
      child: AppBar(
        automaticallyImplyLeading: false,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(bottomLeft: Radius.circular(16), bottomRight: Radius.circular(16))
        ),
        backgroundColor: Color(0xFF5B913B).withOpacity(0.98),
        leading: showBackButton
        ? IconButton(
          onPressed: (){Navigator.pop(context);},
          icon: Icon(Icons.arrow_back, color: GColors.myKuning,)
        )
        : null,
        title: title,
        actions: actions,
      ),
    );
  }

  @override
  // TODO: implement preferredSize
  Size get preferredSize => const Size.fromHeight(kToolbarHeight + 12);
}