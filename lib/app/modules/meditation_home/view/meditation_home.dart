import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:meditation_friend/app/constant/app_color.dart';
import 'package:meditation_friend/app/constant/constants.dart';
import 'package:meditation_friend/app/modules/meditation_home/controllers/home_controller.dart';
import 'package:meditation_friend/app/modules/meditation_home/view/widgets/attendance_check.dart';
import 'package:meditation_friend/app/modules/meditation_home/view/widgets/quote_slider.dart';
import 'package:meditation_friend/app/modules/meditation_home/view/widgets/recommend_sessions.dart';
import 'package:meditation_friend/app/modules/meditation_home/view/widgets/start_meditation_player_btn.dart';
import 'package:meditation_friend/app/widgets/under_tab_bar.dart';

class MeditationHome extends GetView<HomeController> {
  const MeditationHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PopScope(
        canPop: false,
        onPopInvoked: (didPop) {
          if (didPop) return;
          controller.appService.onPop(context);
        },
        child: SafeArea(
          child: Stack(
            fit: StackFit.expand, // Stack이 전체 화면을 차지하도록
            children: [
              // 1. 배경 그라데이션
              Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      Color(0xFF161538), // 위쪽 색상
                      Color(0xFF11002A), // 아래쪽 색상
                    ],
                  ),
                ),
              ),

              // 2. 배경 상단 이미지
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Image.asset(
                  HOME_BG,
                  width: ScreenUtil().screenWidth, // 핸드폰 전체 너비로
                  fit: BoxFit.cover, // 너비에 맞추기
                ),
              ),

              // 3. 스크롤 가능한 콘텐츠
              SingleChildScrollView(
                // 하단 패딩으로 탭바 영역 확보
                padding: EdgeInsets.only(bottom: 80.h),
                child: Column(
                  children: [
                    SizedBox(height: 20.h),
                    const QuoteSlider(),
                    SizedBox(height: 10.h),
                    const StartMeditationPlayerBtn(),
                    SizedBox(height: 10.h),
                    const AttendanceCheck(),
                    SizedBox(height: 10.h),
                    const RecommendSessions(),
                  ],
                ),
              ),
              // 4. 하단 탭바 (항상 위에 표시)
              UnderTabBar(),
            ],
          ),
        ),
      ),
    );
  }
}
