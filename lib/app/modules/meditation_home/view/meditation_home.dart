import 'package:flutter/material.dart';
import 'package:safety_check/app/constant/app_color.dart';
import 'package:get/get.dart';
import 'package:safety_check/app/modules/meditation_home/controllers/home_controller.dart';
import 'package:safety_check/app/modules/meditation_home/view/widgets/quote_slider.dart';
import 'package:safety_check/app/modules/meditation_home/view/widgets/start_meditation_player_btn.dart';
import 'package:safety_check/app/modules/meditation_home/view/widgets/top_image.dart';
import 'package:safety_check/app/widgets/under_tab_bar.dart';

class MeditationHome extends GetView<HomeController> {
  const MeditationHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.kSkyBlue,
      body: PopScope(
        canPop: true,
        onPopInvoked: (didPop) {
          if (didPop) return;

          controller.appService.onPop(context);
        },
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand, // Stack이 전체 화면을 차지하도록
            children: [
              SingleChildScrollView(
                // 하단 패딩으로 탭바 영역 확보
                padding: const EdgeInsets.only(bottom: 80),
                child: Column(
                  children: const [
                    TopImage(),
                    SizedBox(height: 10),
                    QuoteSlider(),
                    SizedBox(height: 10),
                    StartMeditationPlayerBtn(),
                    StartMeditationPlayerBtn(),
                    StartMeditationPlayerBtn(),
                    StartMeditationPlayerBtn(),
                    SizedBox(height: 10),
                    // AttendanceCheck(),
                    // SizedBox(height: 100),
                  ],
                ),
              ),
              const UnderTabBar(),
            ],
          ),
        ),
      ),
    );
  }
}
