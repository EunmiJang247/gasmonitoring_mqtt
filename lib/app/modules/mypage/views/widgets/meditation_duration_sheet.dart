import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meditation_friend/app/modules/mypage/views/widgets/time_duration_select.dart';

Future<dynamic> meditationDurationBottomSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    builder: (BuildContext context) {
      return Container(
        height: MediaQuery.of(context).size.height * 0.7,
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20.0)),
        ),
        child: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '영상길이 선택',
              ),
              SizedBox(height: 10.h),

              // Information Section
              Text(
                '선호하시는 영상 길이를 설정해주세요',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15.h),
              TimeDurationSelect(),
            ],
          ),
        ),
      );
    },
  );
}
