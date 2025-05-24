import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:meditation_friend/app/constant/app_color.dart';
import '../constant/constants.dart';

class CustomAppBar extends StatefulWidget implements PreferredSizeWidget {
  CustomAppBar({
    super.key,
    required this.leftSide,
    required this.rightSide,
    this.title,
    this.bgColor,
  });

  final Widget leftSide;
  final Widget rightSide;
  String? title;
  Color? bgColor;

  @override
  Size get preferredSize => Size.fromHeight(appBarHeight);

  @override
  State<CustomAppBar> createState() => _CustomAppBarState();
}

class _CustomAppBarState extends State<CustomAppBar> {
  @override
  Widget build(BuildContext context) {
    return Container(
      height: appBarHeight,
      decoration: BoxDecoration(
        color: widget.bgColor ?? AppColors.kDark,
        border: Border(
          bottom: BorderSide(
            color: AppColors.kBrighBlue,
            width: 1.0,
          ),
        ),
      ),
      child: Stack(
        children: [
          // 왼쪽 위젯
          // Positioned(
          //   left: 16,
          //   top: 0,
          //   bottom: 0,
          //   child: Center(child: widget.leftSide),
          // ),
          // 중앙 타이틀
          Center(
            child: Image.asset("assets/images/logo.png", width: 100.w),
          ),
          // 오른쪽 위젯
          // Positioned(
          //   right: 16,
          //   top: 0,
          //   bottom: 0,
          //   child: Center(child: widget.rightSide),
          // ),
        ],
      ),
    );
  }
}
