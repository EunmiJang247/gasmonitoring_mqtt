import 'package:flutter/material.dart';
import 'package:meditation_friend/app/constant/app_color.dart';

class GenderSelectButtons extends StatefulWidget {
  @override
  _GenderSelectButtonsState createState() => _GenderSelectButtonsState();
}

class _GenderSelectButtonsState extends State<GenderSelectButtons> {
  String selectedGender = ""; // 선택된 성별

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        // 남성 버튼
        ElevatedButton(
          onPressed: () {
            setState(() {
              selectedGender = "남성";
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: selectedGender == "남성"
                ? AppColors.kOrange
                : Colors.grey, // 선택된 항목 하이라이트
            foregroundColor: Colors.white,
          ),
          child: const Text('남성'),
        ),
        SizedBox(width: 10),
        // 여성 버튼
        ElevatedButton(
          onPressed: () {
            setState(() {
              selectedGender = "여성";
            });
          },
          style: ElevatedButton.styleFrom(
            backgroundColor: selectedGender == "여성"
                ? AppColors.kOrange
                : Colors.grey, // 선택된 항목 하이라이트
            foregroundColor: Colors.white,
          ),
          child: const Text('여성'),
        ),
      ],
    );
  }
}
