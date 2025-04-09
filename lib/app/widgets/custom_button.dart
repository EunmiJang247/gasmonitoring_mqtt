import 'package:flutter/material.dart';

import '../constant/app_color.dart';

Widget customButton(
  BuildContext context,
  String text,
  VoidCallback onTap, {
  double width = 0,
  double height = 48,
  double fontSize = 20,
  Color color = AppColors.c4,
}) {
  return InkWell(
    onTap: onTap,
    child: Container(
      width: width == 0 ? MediaQuery.of(context).size.width : width,
      height: height,
      decoration:
          BoxDecoration(color: color, borderRadius: BorderRadius.circular(8)),
      child: Center(
        child: Text(
          text,
          style: TextStyle(
              color: Colors.white,
              fontSize: fontSize,
              fontWeight: FontWeight.bold),
        ),
      ),
    ),
  );
}
