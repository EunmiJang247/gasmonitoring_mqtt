import 'package:flutter/material.dart';
import 'package:meditation_friend/app/constant/app_color.dart';
import 'package:get/get.dart';
import 'package:meditation_friend/app/modules/meditation_home/controllers/home_controller.dart';
import 'package:meditation_friend/app/modules/meditation_home/view/widgets/attendance_check.dart';
import 'package:meditation_friend/app/modules/meditation_home/view/widgets/quote_slider.dart';
import 'package:meditation_friend/app/modules/meditation_home/view/widgets/recommend_sessions.dart';
import 'package:meditation_friend/app/modules/meditation_home/view/widgets/start_meditation_player_btn.dart';
import 'package:meditation_friend/app/modules/meditation_home/view/widgets/top_image.dart';
import 'package:meditation_friend/app/widgets/custom_app_bar.dart';
import 'package:meditation_friend/app/widgets/under_tab_bar.dart';

class MeditationHome extends GetView<HomeController> {
  const MeditationHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(
        leftSide: IconButton(
          icon: Icon(Icons.menu),
          onPressed: () {},
        ),
        rightSide: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.notifications),
              onPressed: () {},
            ),
            IconButton(
              icon: Icon(Icons.settings),
              onPressed: () {},
            ),
          ],
        ),
      ),
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
              Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.topLeft, // 오른쪽 중앙
                    radius: 2,
                    colors: [
                      Color(0xFFF7FF00), // 형광 노랑
                      Color(0xFF000000), // 블랙 배경
                    ],
                    stops: [0.0, .3],
                  ),
                ),
              ),
              Container(
                decoration: const BoxDecoration(
                  gradient: RadialGradient(
                    center: Alignment.centerRight, // 오른쪽 중앙
                    radius: 2,
                    colors: [
                      Color(0xFFF7FF00), // 형광 노랑
                      Color(0xFF000000), // 블랙 배경
                    ],
                    stops: [0.0, .3],
                  ),
                ),
              ),
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
                    SizedBox(height: 10),
                    RecommendSessions(),
                    AttendanceCheck(),
                    SizedBox(height: 100),
                  ],
                ),
              ),
              UnderTabBar(),
            ],
          ),
        ),
      ),
    );
  }
}
