import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:meditation_friend/app/constant/app_color.dart';
import 'package:meditation_friend/app/modules/meditation_home/controllers/home_controller.dart';
import 'package:meditation_friend/app/utils/log.dart';

class AttendanceCheck extends GetView<HomeController> {
  const AttendanceCheck({super.key});

  // 날짜에 해당하는 요일을 가져오는 함수
  String getDayOfWeek(DateTime date) {
    List<String> days = ['월', '화', '수', '목', '금', '토', '일'];
    return days[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      List<String> attendanceListStrings = controller.appService.attendanceList;

      // 문자열을 DateTime 리스트로 변환
      List<DateTime> attendanceList = attendanceListStrings
          .map((dateString) => DateTime.parse(dateString))
          .toList();
      DateTime now = DateTime.now();

      // 현재 날짜 기준으로 -3일 ~ +3일 범위의 날짜 리스트 생성
      List<DateTime> dates = [
        now.subtract(Duration(days: 3)),
        now.subtract(Duration(days: 2)),
        now.subtract(Duration(days: 1)),
        now,
        now.add(Duration(days: 1)),
        now.add(Duration(days: 2)),
        now.add(Duration(days: 3)),
      ];

      return GestureDetector(
        onTap: () {
          // controller.onAttendanceCheck();
        },
        child: Card(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          color: const Color.fromRGBO(47, 47, 79, 0.75),
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: SizedBox(
              width: ScreenUtil().screenWidth - 80,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ...dates.map((date) {
                    bool isPresent = attendanceList.any(
                      (attendanceDate) =>
                          attendanceDate.year == date.year &&
                          attendanceDate.month == date.month &&
                          attendanceDate.day == date.day,
                    );
                    return Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 5.0),
                      child: Column(
                        children: [
                          Icon(
                            isPresent
                                ? Icons.sentiment_very_satisfied
                                : (date == now
                                    ? Icons.sentiment_very_satisfied
                                    : Icons.sentiment_neutral),
                            color: isPresent
                                ? AppColors.kWhite
                                : (date == now
                                    ? AppColors.kWhite
                                    : AppColors.kGray),
                            size: ScreenUtil().screenWidth / 14,
                          ),
                          Text(
                            getDayOfWeek(date),
                            style: TextStyle(color: AppColors.kWhite),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}
