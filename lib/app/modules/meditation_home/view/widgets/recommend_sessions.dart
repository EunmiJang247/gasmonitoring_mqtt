import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meditation_friend/app/constant/app_color.dart';
import 'package:get/get.dart';
import 'package:meditation_friend/app/modules/meditation_home/controllers/home_controller.dart';
import 'package:meditation_friend/app/modules/meditation_home/view/widgets/meditation_tile.dart';

class RecommendSessions extends GetView<HomeController> {
  const RecommendSessions({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding:
              EdgeInsets.only(left: 20.w, right: 20.w, top: 0.h, bottom: 16.h),
          child: Text(
            "추천 명상",
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.sp,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),

        // 개별 타일들
        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: MeditationTile(
            title: "Affirmations to close your day",
            tags: ["15 min", "Evening", "Relax"],
            backgroundColor: Color.fromRGBO(47, 47, 79, 0.9),
          ),
        ),
        SizedBox(height: 16.h),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: MeditationTile(
            title: "Meditation for deep sleep",
            tags: ["10 min", "Sleep", "Evening"],
            backgroundColor: Colors.white,
            textColor: Colors.black,
            tagColor: Color(0xFF6C63FF),
            playButtonColor: Color(0xFF6C63FF),
            transformTilt: true,
          ),
        ),
        SizedBox(height: 16.h),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: MeditationTile(
            title: "A daily mindfulness practice",
            tags: ["20 min", "Nature"],
            backgroundColor: Color.fromRGBO(30, 30, 30, 0.9),
          ),
        ),
      ],
    );
  }
}
