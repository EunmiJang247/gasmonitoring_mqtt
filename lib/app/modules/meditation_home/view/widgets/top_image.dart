import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meditation_friend/app/constant/app_color.dart';
import 'package:meditation_friend/app/constant/constants.dart';

class TopImage extends StatelessWidget {
  const TopImage({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        Text(
          'Namaste, \nJenny',
          style: TextStyle(
            color: Color(0xFFFFFF00),
            fontSize: 24,
            fontWeight: FontWeight.bold,
          ),
        ),
        Image.asset(
          ASSETS_IMAGES_SPLASHSCREEN_PNG,
          width: ScreenUtil().screenWidth / 3,
          fit: BoxFit.contain,
        ),
      ],
    );
  }
}
