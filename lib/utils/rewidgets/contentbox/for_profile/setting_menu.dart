import 'package:flutter/material.dart';
import 'package:seedina/utils/rewidgets/global/mynav.dart';
import 'package:seedina/utils/style/gcolor.dart';

class SettingMenu extends StatelessWidget {
  final String illustration;
  final String title;
  final Widget navigate; // Bisa jadi tidak digunakan jika customOnTap ada
  final VoidCallback? customOnTap;

  const SettingMenu({
    super.key,
    required this.illustration,
    required this.title,
    required this.navigate,
    this.customOnTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: InkWell(
        onTap: customOnTap ?? () { // Prioritaskan customOnTap
          GNav.slideNavStateless(context, navigate);
        },
        child: Row(
          children: [
            Row(
              children: [
                SizedBox(
                  height: 42,
                  width: 42,
                  child: Image.asset(illustration),
                ),
                const SizedBox(width: 12),
                Text(
                  title,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w400),
                ),
              ],
            ),
            const Spacer(),
            Icon(
              Icons.navigate_next,
              color: GColors.myBiru,
            )
          ],
        ),
      ),
    );
  }
}