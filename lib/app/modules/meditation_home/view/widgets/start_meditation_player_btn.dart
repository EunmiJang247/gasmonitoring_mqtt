import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safety_check/app/constant/app_color.dart';
import 'package:get/get.dart';
import 'package:safety_check/app/constant/constants.dart';
import 'package:safety_check/app/modules/meditation_home/controllers/home_controller.dart';

class StartMeditationPlayerBtn extends GetView<HomeController> {
  const StartMeditationPlayerBtn({super.key});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () {
        controller.onMusicListen();
      },
      child: Card(
        color: AppColors.kWhite,
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text("오늘의 명상 시작하기"),
              const SizedBox(height: 16),
              Image.asset(
                ASSETS_MUSIC_BAR,
                width: ScreenUtil().screenWidth - 100,
              ),
              const SizedBox(height: 16),
              Image.asset(ASSETS_PLAY_BUTTON, width: 150),
            ],
          ),
        ),
      ),
    );
  }
}
