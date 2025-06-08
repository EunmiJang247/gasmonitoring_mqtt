import 'package:flutter/material.dart';
import 'package:meditation_friend/app/constant/app_color.dart';
import 'package:meditation_friend/app/data/models/notification_setting.dart';

class WeekDaySelectButtons extends StatefulWidget {
  final ValueChanged<String> onChanged;
  final NotificationSetting notificationSetting;

  const WeekDaySelectButtons(
      {super.key, required this.onChanged, required this.notificationSetting});

  @override
  _WeekDaySelectButtonsState createState() => _WeekDaySelectButtonsState();
}

class _WeekDaySelectButtonsState extends State<WeekDaySelectButtons> {
  int selectedDays = 0;
  final List<String> days = ["월", "화", "수", "목", "금", "토", "일"];

  @override
  void initState() {
    super.initState();
    selectedDays = _parseNotifyDays(widget.notificationSetting.notifyDays);
  }

  String _selectedDayBits() {
    return List.generate(7, (i) {
      final bitIndex = 6 - i;
      return ((selectedDays & (1 << bitIndex)) != 0) ? '1' : '0';
    }).join();
  }

  int _parseNotifyDays(String dayBits) {
    // 예: '1111100' → int 비트마스크
    int value = 0;
    for (int i = 0; i < dayBits.length; i++) {
      if (dayBits[i] == '1') {
        value |= (1 << (6 - i));
      }
    }
    return value;
  }

  void toggleDay(int index) {
    setState(() {
      selectedDays ^= (1 << (6 - index)); // toggle
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
