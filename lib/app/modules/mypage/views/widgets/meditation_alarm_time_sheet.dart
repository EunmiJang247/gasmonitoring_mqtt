import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:meditation_friend/app/constant/app_color.dart';
import 'package:meditation_friend/app/modules/mypage/controllers/mypage_controller.dart';
import 'package:meditation_friend/app/modules/mypage/views/widgets/custom_time_picker.dart';
import 'package:meditation_friend/app/modules/mypage/views/widgets/week_day_select_buttons.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:permission_handler/permission_handler.dart';

Future<dynamic> meditationAlramTimeBottomSheet(BuildContext context) {
  // 리턴으로 아무 타입(dynamic) 도 가능하다는 뜻

  // 컨트롤러 가져오기
  final mypageController = Get.find<MypageController>();

  return showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext context) {
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        // return 뒤의 화면이 그려진 뒤에 아래 코드를 실행해라! 라는 뜻
        FirebaseMessaging messaging = FirebaseMessaging.instance;
        // Firebase Cloud Messaging(FCM)의 인스턴스를 가져옴.
        // 푸시 알림 관련 작업을 하기 위해 FirebaseMessaging 객체가 필요함

        // Firebase 권한 요청
        NotificationSettings settings = await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );
        // alert: true: 팝업 알림 허용
        // badge: true: 앱 아이콘에 배지 표시 허용
        // sound: true: 알림 사운드 허용
        // 이 줄이 실행되면, 사용자에게 시스템 권한 요청 팝업이 뜰 수 있습니다.

        final status = await Permission.notification.status;
        // permission_handler 패키지를 이용해서 현재 알림 권한 상태를 가져옴

        if (status.isDenied) {
          // 만약 알림 권한이 거부된 상태라면 다시 요청함
          await Permission.notification.request();
        }
      });

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
                  notificationSetting:
                      mypageController.appService.notificationSetting),
              CustomTimePicker(
                  onTimeChanged: (hour, minute) {
                    mypageController.alarmHour.value = hour; // 선택된 시간 저장
                    mypageController.alarmMinute.value = minute; // 선택된 분 저장
                  },
                  notificationSetting:
                      mypageController.appService.notificationSetting),
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
