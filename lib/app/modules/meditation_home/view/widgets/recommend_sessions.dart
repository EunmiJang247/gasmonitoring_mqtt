import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
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
              EdgeInsets.only(left: 20.w, right: 20.w, top: 0.h, bottom: 10.h),
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
            onTap: () async {
              controller.appService.currentIndex.value = 1;
              Get.toNamed('/music-detail', arguments: {
                'category': '동기부여',
                'continue_current': false,
              });
            },
            title: "성공을 위한 동기부여명상",
            tags: ["10 min", "아침", "Motivation"],
            backgroundColor: Color.fromRGBO(47, 47, 79, 0.9),
          ),
        ),
        SizedBox(height: 16.h),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: MeditationTile(
            onTap: () async {
              controller.appService.currentIndex.value = 1;
              Get.toNamed('/music-detail', arguments: {
                'category': '스트레스해소',
                'continue_current': false,
              });
            },
            title: "일끝낸 후 스트레스해소명상",
            tags: ["10 min", "Cheer", "Evening"],
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
            onTap: () async {
              controller.appService.currentIndex.value = 1;
              Get.toNamed('/music-detail', arguments: {
                'category': '상상',
                'continue_current': false,
              });
            },
            title: "파워 N이 만든 상상명상",
            tags: ["10 min", "Nature"],
            backgroundColor: Color.fromRGBO(30, 30, 30, 0.9),
          ),
        ),
        SizedBox(height: 16.h),

        Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: MeditationTile(
            onTap: () async {
              controller.appService.currentIndex.value = 1;
              Get.toNamed('/music-detail', arguments: {
                'category': '질문',
                'continue_current': false,
              });
            },
            title: "나를 알아가는 질문명상",
            tags: ["10 min", "애프터눈", "Question"],
            backgroundColor: Color.fromRGBO(47, 47, 79, 0.9),
          ),
        ),
        SizedBox(height: 16.h),
      ],
    );
  }
}
