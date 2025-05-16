import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:meditation_friend/app/constant/app_color.dart';
import 'package:flutter/material.dart';
import 'package:meditation_friend/app/modules/meditation_home/controllers/home_controller.dart';

class AttendanceCheck extends GetView<HomeController> {
  const AttendanceCheck({super.key});

  // 날짜에 해당하는 요일을 가져오는 함수
  String getDayOfWeek(DateTime date) {
    List<String> days = ['월', '화', '수', '목', '금', '토', '일'];
    return days[date.weekday - 1]; // DateTime의 weekday는 1 (월요일)부터 7 (일요일)
  }

  @override
  Widget build(BuildContext context) {
    List<String> attendanceListStrings = ["2025-03-23", "2025-03-24"];
    List<DateTime> attendanceList = attendanceListStrings
        .map((dateString) => DateTime.parse(dateString))
        .toList();
    DateTime now = DateTime.now();
    List<DateTime> dates = [
      now.subtract(Duration(days: 3)),
      now.subtract(Duration(days: 2)),
      now.subtract(Duration(days: 1)),
      now, // 오늘
      now.add(Duration(days: 1)),
      now.add(Duration(days: 2)),
      now.add(Duration(days: 3)),
    ];

    return GestureDetector(
      onTap: () {
        controller.onMusicListen();
      },
      child: Card(
        color: AppColors.kWhite,
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: SizedBox(
            width: ScreenUtil().screenWidth - 100, // ← 여기서 너비 제한
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
                                  ? Icons.sentiment_satisfied
                                  : Icons.sentiment_neutral),
                          color: isPresent
                              ? const Color.fromARGB(255, 78, 91, 235)
                              : (date == now ? AppColors.kOrange : null),
                        ),
                        Text(getDayOfWeek(date)),
                      ],
                    ),
                  );
                }).toList(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
