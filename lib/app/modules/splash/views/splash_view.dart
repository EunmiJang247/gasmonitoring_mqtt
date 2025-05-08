import 'package:safety_check/app/constant/constants.dart';
import 'package:safety_check/app/modules/splash/controllers/splash_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:safety_check/app/modules/splash/views/widgets/custom_loading.dart';

import '../../../constant/app_color.dart';

class UpdateScreen extends GetView<SplashController> {
  const UpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kSkyBlue,
      body: SafeArea(
        child: Center(
          child: Stack(
            children: [
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const EllipsisLoadingIndicatorCustom(),
                  const SizedBox(height: 20),
                  Image.asset(
                    ASSETS_IMAGES_SPLASHSCREEN_PNG,
                    width: ScreenUtil().screenWidth - 100,
                  ),
                  const SizedBox(height: 40),
                ],
              ),
              Positioned(
                bottom: 30,
                left: 0,
                child: Image.asset(
                  ASSETS_IMAGES_SPLASHSCREEN_DOTDOT_PNG,
                  width: 80,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
