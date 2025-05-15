import 'package:flutter/material.dart';
import 'package:meditation_friend/app/constant/app_color.dart';

class MeditationKindSelectWidget extends StatefulWidget {
  @override
  _MeditationKindSelectWidgetState createState() =>
      _MeditationKindSelectWidgetState();
}

class _MeditationKindSelectWidgetState
    extends State<MeditationKindSelectWidget> {
  List<String> selectedGender = [];
  final List<String> meditationKinds = [
    "마음 챙김 명상",
    "자비 명상",
    "호흡 명상",
    "자기 인식 명상",
    "사마타 명상",
    "통찰 명상",
    "걷기 명상",
    "소리 명상",
    "차크라 명상",
  ];

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      child: Wrap(
        spacing: 10,
        runSpacing: 4, // 행 간격도 10px 설정
        children: [
          // 반복되는 ElevatedButton을 dynamic하게 만들기
          for (var kind in meditationKinds)
            SizedBox(
              child: ElevatedButton(
                onPressed: () {
                  setState(() {
                    if (selectedGender.contains(kind)) {
                      selectedGender.remove(kind); // 이미 선택된 경우 삭제
                    } else {
                      selectedGender.add(kind); // 선택되지 않은 경우 추가
                    }
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: selectedGender.contains(kind)
                      ? AppColors.kOrange
                      : Colors.grey, // 선택된 항목 하이라이트
                  foregroundColor: Colors.white,
                ),
                child: Text(kind),
              ),
            ),
        ],
      ),
    );
  }
}
