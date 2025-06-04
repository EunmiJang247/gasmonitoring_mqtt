import 'package:flutter/material.dart';
import 'package:meditation_friend/app/constant/app_color.dart';

class WeekDaySelectButtons extends StatefulWidget {
  final ValueChanged<String> onChanged;

  const WeekDaySelectButtons({super.key, required this.onChanged});

  @override
  _WeekDaySelectButtonsState createState() => _WeekDaySelectButtonsState();
}

class _WeekDaySelectButtonsState extends State<WeekDaySelectButtons> {
  int selectedDays = 0;

  final List<String> days = ["월", "화", "수", "목", "금", "토", "일"];

  String _selectedDayBits() {
    return List.generate(7, (i) {
      // 요일 인덱스가 0(월)부터 6(일)까지, 비트 인덱스는 거꾸로 매핑 (6 - i)
      final bitIndex = 6 - i;
      return ((selectedDays & (1 << bitIndex)) != 0) ? '1' : '0';
    }).join();
  }

  void toggleDay(int index) {
    setState(() {
      selectedDays ^= (1 << (6 - index)); // 토글 처리
      widget.onChanged(_selectedDayBits());
    });
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: List.generate(days.length, (index) {
          bool isSelected = (selectedDays & (1 << (6 - index))) != 0;

          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4.0),
            child: ElevatedButton(
              onPressed: () => toggleDay(index),
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    isSelected ? AppColors.kBrighBlue : AppColors.kGray,
                foregroundColor: Colors.white,
              ),
              child: Text(days[index]),
            ),
          );
        }),
      ),
    );
  }
}
