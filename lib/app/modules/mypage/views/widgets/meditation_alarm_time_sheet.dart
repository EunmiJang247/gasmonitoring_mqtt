import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:meditation_friend/app/constant/app_color.dart';
import 'package:meditation_friend/app/modules/mypage/controllers/mypage_controller.dart';
import 'package:meditation_friend/app/modules/mypage/views/widgets/custom_time_picker.dart';
import 'package:meditation_friend/app/modules/mypage/views/widgets/week_day_select_buttons.dart';

Future<dynamic> meditationAlramTimeBottomSheet(BuildContext context) {
  // 선택된 요일과 시간을 저장할 변수
  int selectedDays = 0;
  int selectedHour = 12;
  int selectedMinute = 30;

  // 컨트롤러 가져오기
  final mypageController = Get.find<MypageController>();

  return showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: AppColors.kDark,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '알람 시간',
                style: TextStyle(
                  fontSize: 20.sp,
                  fontWeight: FontWeight.bold,
                  color: AppColors.kWhite,
                ),
              ),
              SizedBox(height: 4.h),
              Text(
                '해당 시간에 알람을 드려요',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 14.sp,
                  color: AppColors.kWhite.withOpacity(0.7),
                ),
              ),
              SizedBox(height: 15.h),
              WeekDaySelectButtons(
                onChanged: (selectedDays) {
                  print(
                    "선택된 요일 비트마스크: ${selectedDays.toRadixString(2).padLeft(7, '0')}",
                  );
                },
              ),
              CustomTimePicker(),
            ],
          ),
        ),
      );
    },
  );
}
