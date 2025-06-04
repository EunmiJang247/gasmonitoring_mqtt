import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:meditation_friend/app/constant/app_color.dart';
import 'package:meditation_friend/app/modules/mypage/controllers/mypage_controller.dart';
import 'package:meditation_friend/app/modules/mypage/views/widgets/custom_time_picker.dart';
import 'package:meditation_friend/app/modules/mypage/views/widgets/week_day_select_buttons.dart';

Future<dynamic> meditationAlramTimeBottomSheet(BuildContext context) {
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
                onChanged: (days) {
                  mypageController.alarmDays.value = days;
                },
              ),
              CustomTimePicker(
                onTimeChanged: (hour, minute) {
                  mypageController.alarmHour.value = hour; // 선택된 시간 저장
                  mypageController.alarmMinute.value = minute; // 선택된 분 저장
                },
              ),
              Container(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () async {
                    // ✅ 수정: 컨트롤러 메서드 직접 호출
                    await mypageController.saveAlarmSettings();
                    // Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.kBrighBlue,
                    padding: EdgeInsets.symmetric(vertical: 8.h),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10.r),
                    ),
                  ),
                  child: Text(
                    '알람 설정',
                    style: TextStyle(
                      fontSize: 16.sp,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}
