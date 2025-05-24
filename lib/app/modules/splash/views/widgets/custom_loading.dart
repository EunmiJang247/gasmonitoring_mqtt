import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meditation_friend/app/constant/app_color.dart';

class EllipsisLoadingIndicatorCustom extends StatefulWidget {
  const EllipsisLoadingIndicatorCustom({super.key});

  @override
  State<EllipsisLoadingIndicatorCustom> createState() =>
      _EllipsisLoadingIndicatorCustomState();
}

class _EllipsisLoadingIndicatorCustomState
    extends State<EllipsisLoadingIndicatorCustom> {
  late Timer _timer;
  int _dotCount = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _dotCount = (_dotCount % 3) + 1;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String dots = '.' * _dotCount;
    return Column(
      mainAxisSize: MainAxisSize.min, // 내용 크기만큼만 차지하도록 변경
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // 첫 번째 줄
        Text(
          '내면을',
          style: TextStyle(
            color: Color(0xFF5244F3), // 원하는 색상
            fontSize: 52,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          '들여다보는',
          style: TextStyle(
            color: AppColors.kWhite, // 원하는 색상
            fontSize: 52.sp,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          '자는',
          style: TextStyle(
            color: Color(0xFF5244F3), // 원하는 색상
            fontSize: 52.sp,
          ),
          textAlign: TextAlign.center,
        ),
        // 두 번째 줄 (점들과 함께)
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '깨어난다',
              style: TextStyle(
                color: AppColors.kWhite, // 원하는 색상
                fontSize: 52.sp,
              ),
            ),
            // 고정 너비 사용 (OverflowBox 대신)
            SizedBox(
              width: 40.sp,
              child: Text(
                dots,
                style: const TextStyle(
                  color: AppColors.kWhite, // 원하는 색상
                  fontSize: 48,
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
