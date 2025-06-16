import 'package:flutter/material.dart';
import 'package:seedina/utils/style/gcolor.dart';

InputDecoration GFieldStyle({
  String? hintText,
  Widget? prefixIcon,
  Widget? suffixIcon,
  bool? filled
}) {
  return InputDecoration(
    filled: filled,
    fillColor: Colors.white,
    hintText: hintText ?? '',
    hintStyle: TextStyle(
      fontSize: 12
    ),
    prefixIcon: prefixIcon,
    suffixIcon: suffixIcon,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: BorderSide(color: Colors.grey.shade300),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: GColors.myBiru, width: 2),
    ),
    errorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Colors.red),
    ),
    focusedErrorBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(16),
      borderSide: const BorderSide(color: Colors.red, width: 2),
    ),
  );
}
