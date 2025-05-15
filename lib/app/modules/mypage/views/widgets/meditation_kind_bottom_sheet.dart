import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meditation_friend/app/modules/mypage/views/widgets/meditation_kind_select_widget.dart';

Future<dynamic> meditationKindBottomSheet(BuildContext context) {
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
                '명상종류 선택',
              ),
              SizedBox(height: 10.h),
              Text(
                '선호하는 명상 종류를 알려주세요',
                textAlign: TextAlign.center,
              ),
              SizedBox(height: 15.h),
              MeditationKindSelectWidget(),
            ],
          ),
        ),
      );
    },
  );
}
