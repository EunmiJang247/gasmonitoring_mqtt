import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meditation_friend/app/constant/app_color.dart';

class GradientBtn extends StatelessWidget {
  const GradientBtn({
    super.key,
    this.onTap,
    this.btnWidth,
    required this.text,
    this.btnHieght,
    this.textSize,
    this.borderColor,
    this.radius,
    this.btnColor,
    this.textColor,
  });

  final void Function()? onTap;
  final double? btnWidth;
  final double? btnHieght;
  final double? radius;
  final String text;
  final double? textSize;
  final Color? borderColor;
  final Color? btnColor;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    return Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(radius ?? 30),
          child: Container(
            width: btnWidth ?? ScreenUtil().screenWidth / 2,
            height: btnHieght ?? 60.h,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(radius ?? 30),
              color: btnColor ?? AppColors.kOrange,
              border: borderColor != null
                  ? Border.all(
                      color: borderColor!,
                      width: 1.0,
                    )
                  : null,
            ),
            child: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 3.w),
                child: Text(
                  text,
                  style: TextStyle(
                    color: textColor ?? Colors.white, // 기본값은 흰색
                    fontSize: textSize,
                  ),
                ),
              ),
            ),
          ),
        ));
  }
}
