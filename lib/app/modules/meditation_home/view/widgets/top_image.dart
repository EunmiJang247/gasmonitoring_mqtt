import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meditation_friend/app/constant/app_color.dart';
import 'package:meditation_friend/app/constant/constants.dart';

class TopImage extends StatelessWidget {
  const TopImage({super.key});

  // @override
  // Widget build(BuildContext context) {
  //   return SizedBox(
  //     height: 270,
  //     child: Row(
  //       children: [
  //         Positioned(
  //           top: 20,
  //           right: 0,
  //           child: Image.asset(
  //             ASSETS_IMAGES_SPLASHSCREEN_PNG,
  //             width: ScreenUtil().screenWidth / 3,
  //             fit: BoxFit.contain,
  //           ),
  //         ),
  //         Positioned(
  //           top: 10,
  //           left: 20,
  //           child: Image.asset(
  //             ASSETS_IMAGES_SPLASHSCREEN_DOTDOT_PNG,
  //             width: ScreenUtil().screenWidth / 4,
  //             fit: BoxFit.contain,
  //           ),
  //         ),
  //         Positioned(
  //           top: 100,
  //           left: 12,
  //           child: Text('Namaste, \nJenny',
  //               style: TextStyle(
  //                 color: Color(0xFFFFFF00), // Namaste 텍스트 색상
  //                 fontSize: 16,
  //               )),
  //         ),
  //       ],
  //     ),
  //   );
  // }

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
