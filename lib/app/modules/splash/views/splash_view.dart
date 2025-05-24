import 'package:meditation_friend/app/constant/constants.dart';
import 'package:meditation_friend/app/modules/splash/controllers/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:meditation_friend/app/modules/splash/views/widgets/custom_loading.dart';

import '../../../constant/app_color.dart';

class SplashView extends GetView<SplashController> {
  const SplashView({super.key});

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF161538), // 위쪽 색상
              AppColors.kDark, // 아래쪽 색상
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand, // Stack이 전체 화면을 차지하도록
            children: [
              // 배경 이미지
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Image.asset(
                  ASSETS_IMAGES_SPLASHSCREEN_PNG,
                  width: ScreenUtil().screenWidth, // 핸드폰 전체 너비로
                  fit: BoxFit.fitWidth, // 너비에 맞추기
                ),
              ),

              // 텍스트 및 로딩 인디케이터 (화면 높이의 50%에 배치)
              // 텍스트 및 로딩 인디케이터 (화면 높이의 50%에 배치)
              Positioned(
                top: screenHeight * 0.5, // 화면 높이의 50% 위치
                left: 0,
                right: 0,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start, // 왼쪽 정렬
                  children: [
                    Container(
                      padding: const EdgeInsets.only(left: 20), // 왼쪽에 패딩 추가
                      alignment: Alignment.centerLeft,
                      child: const EllipsisLoadingIndicatorCustom(),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
