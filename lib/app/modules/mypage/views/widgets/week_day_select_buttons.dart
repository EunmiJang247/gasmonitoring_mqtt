import 'package:flutter/material.dart';
import 'package:meditation_friend/app/constant/app_color.dart';

class WeekDaySelectButtons extends StatefulWidget {
  final Function(int) onChanged;

  const WeekDaySelectButtons({super.key, required this.onChanged});

  @override
  _WeekDaySelectButtonsState createState() => _WeekDaySelectButtonsState();
}

class _WeekDaySelectButtonsState extends State<WeekDaySelectButtons> {
  int selectedDays = 0;

  final List<String> days = ["월", "화", "수", "목", "금", "토", "일"];

  void toggleDay(int index) {
    setState(() {
      selectedDays ^= (1 << (6 - index)); // 해당 비트 토글
    });
    widget.onChanged(selectedDays); // 변경된 값 전달
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
