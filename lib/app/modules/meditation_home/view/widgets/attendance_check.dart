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
    return days[date.weekday - 1];
  }

  @override
  Widget build(BuildContext context) {
    List<String> attendanceListStrings = ["2025-05-15", "2025-05-14"];
    bool isPresent = false;

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
      now, // 오늘
      now.add(Duration(days: 1)),
      now.add(Duration(days: 2)),
      now.add(Duration(days: 3)),
    ];

    return GestureDetector(
      onTap: () {
        controller.onAttendanceCheck();
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
                // 현재 날짜 기준으로 -3일 ~ +3일 범위의 날짜 리스트를 돌면서 각각의 날짜에 대한 아이콘과 요일 표시
                ...dates.map((date) {
                  // 해당 날짜가 출석 리스트에 포함되어 있는지 확인
                  isPresent = attendanceList.any(
                    (attendanceDate) =>
                        attendanceDate.year == date.year &&
                        attendanceDate.month == date.month &&
                        attendanceDate.day == date.day,
                  );
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: Column(
                      children: [
                        // 출석 여부에 따라 아이콘을 다르게 표시
                        Icon(
                          isPresent
                              ? Icons.sentiment_very_satisfied // 출석한 날
                              : (date == now
                                  ? Icons.sentiment_satisfied // 오늘 (출석 안함)
                                  : Icons.sentiment_neutral), // 출석 안한날
                          color: isPresent
                              ? const Color.fromARGB(
                                  255, 78, 91, 235) // 출석한날 파란색
                              : (date == now
                                  ? AppColors.kOrange
                                  : // 오늘은 주황색
                                  null), // 나머지는 기본 색
                        ),
                        Text(getDayOfWeek(date)), // 요일 표시
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
