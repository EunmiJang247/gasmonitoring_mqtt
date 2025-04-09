import 'package:flutter/material.dart';

import '../constant/gaps.dart';

Widget faultField (String? title, Widget child, {bool needPadding = true, double? height = 36, double minHeight = 36}) {
  return Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Visibility(
        visible: title!=null,
        child: Text(
          title??"",
          style: TextStyle(
            fontFamily: "Pretendard",
            // fontWeight: FontWeight.bold,
            fontSize: 14,
            color: Colors.black
          ),
        ),
      ),
      Visibility(
          visible: title!=null,
          child: Gaps.h4
      ),
      Container(
        constraints: BoxConstraints(minHeight: minHeight),
        height: height,
        padding: needPadding ? EdgeInsets.symmetric(horizontal: 12): EdgeInsets.zero,
        decoration: BoxDecoration(
            color: Colors.white,
            // // border: Border.all(color: Colors.grey),
            borderRadius: BorderRadius.circular(4)),
        child: Align(
            alignment: Alignment.centerLeft,
            child: SizedBox(
              width: double.infinity,
              child: child,
            )
        )
      )
    ],
  );
}