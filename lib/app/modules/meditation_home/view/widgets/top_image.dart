import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meditation_friend/app/constant/app_color.dart';
import 'package:meditation_friend/app/constant/constants.dart';

class TopImage extends StatelessWidget {
  const TopImage({super.key});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 270,
      child: Stack(
        children: [
          Positioned(
            top: 20,
            right: -50,
            child: Image.asset(
              ASSETS_IMAGES_SPLASHSCREEN_PNG,
              height: 250,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            top: 10,
            left: 50,
            child: Image.asset(
              ASSETS_IMAGES_SPLASHSCREEN_DOTDOT_PNG,
              height: 80,
              fit: BoxFit.contain,
            ),
          ),
          Positioned(
            top: 100,
            left: 12,
            child: Text(
              'Namaste, \nJenny',
            ),
          ),
        ],
      ),
    );
  }
}
