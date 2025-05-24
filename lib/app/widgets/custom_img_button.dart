import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

class CustomImgButton extends StatelessWidget {
  final String imagePath; // 이미지 경로
  final VoidCallback onPressed; // 터치 이벤트 콜백
  final double? size; // 선택적 크기 조정
  final double? borderRadius; // 선택적 테두리 둥글기

  const CustomImgButton({
    super.key,
    required this.imagePath,
    required this.onPressed,
    this.size,
    this.borderRadius,
  });

  @override
  Widget build(BuildContext context) {
    final buttonSize = size ?? 40.w; // 기본 크기 설정
    final roundness = borderRadius ?? 20.r; // 기본 둥글기 설정

    return InkWell(
      onTap: onPressed, // 외부에서 전달받은 함수 사용
      borderRadius: BorderRadius.circular(roundness),
      child: Container(
        width: buttonSize,
        height: buttonSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.2),
              spreadRadius: 1,
              blurRadius: 3,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(roundness),
          child: Image.asset(
            imagePath, // 외부에서 전달받은 이미지 경로 사용
            fit: BoxFit.cover,
          ),
        ),
      ),
    );
  }
}
