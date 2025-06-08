import 'package:flutter/material.dart';
import 'package:meditation_friend/app/constant/app_color.dart';
import 'package:meditation_friend/app/data/models/alaram_time.dart';

class CustomTimePicker extends StatefulWidget {
  final Function(int hour, int minute)? onTimeChanged; // 콜백 함수 추가
  final NotificationSetting notificationSetting;

  const CustomTimePicker(
      {super.key,
      this.onTimeChanged, // 콜백 함수 매개변수
      required this.notificationSetting});

  @override
  _CustomTimePickerState createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  final List<int> hours = List.generate(24, (index) => index); // 0~23 시간 리스트
  final List<int> minutes = List.generate(6, (index) => index * 10);

  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  int selectedHour = 12;
  int selectedMinute = 30;

  @override
  void initState() {
    super.initState();

    // ✅ 서버에서 받은 값으로 초기값 설정
    selectedHour = widget.notificationSetting.notifyHour ?? 12;
    selectedMinute = widget.notificationSetting.notifyMinute ?? 30;

    // 시간과 분을 초기화한 후 컨트롤러에 설정
    _hourController = FixedExtentScrollController(initialItem: selectedHour);
    _minuteController = FixedExtentScrollController(
      initialItem: minutes.contains(selectedMinute)
          ? minutes.indexOf(selectedMinute)
          : 0, // fallback
    );

    // ✅ 초기값 콜백도 해당 값으로 호출
    WidgetsBinding.instance.addPostFrameCallback((_) {
      widget.onTimeChanged?.call(selectedHour, selectedMinute);
    });
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  // 시간 변경 시 콜백 호출하는 헬퍼 메서드
  void _updateTime(int hour, int minute) {
    setState(() {
      selectedHour = hour;
      selectedMinute = minute;
    });
    // 콜백 함수 호출
    widget.onTimeChanged?.call(hour, minute);
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text(
          '선택된 시간: $selectedHour 시 $selectedMinute 분',
          style: TextStyle(fontSize: 20, color: AppColors.kWhite),
        ),
        const SizedBox(height: 10),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 시 스크롤
            _buildWheelPicker(
              list: hours,
              controller: _hourController,
              onSelectedItemChanged: (index) {
                _updateTime(index, selectedMinute);
              },
            ),
            const SizedBox(width: 4),
            const Text(
              "시", // "시" 텍스트
              style: TextStyle(fontSize: 16, color: AppColors.kWhite),
            ),
            const SizedBox(width: 10),
            // 분 스크롤
            _buildWheelPicker(
              list: minutes,
              controller: _minuteController,
              onSelectedItemChanged: (index) {
                _updateTime(selectedHour, minutes[index]);
              },
            ),
            const SizedBox(width: 4),
            const Text(
              "분", // "분" 텍스트
              style: TextStyle(fontSize: 16, color: AppColors.kWhite),
            ),
          ],
        ),
      ],
    );
  }

  // Wheel Picker를 만드는 함수
  Widget _buildWheelPicker({
    required List<int> list,
    required FixedExtentScrollController controller,
    required ValueChanged<int> onSelectedItemChanged,
  }) {
    return SizedBox(
      height: 140,
      width: 60,
      child: ListWheelScrollView.useDelegate(
        controller: controller,
        itemExtent: 40,
        onSelectedItemChanged: onSelectedItemChanged,
        physics: const FixedExtentScrollPhysics(),
        childDelegate: ListWheelChildBuilderDelegate(
          builder: (context, index) {
            return Center(
              child: Text(
                list[index].toString(),
                style: const TextStyle(fontSize: 16, color: AppColors.kWhite),
              ),
            );
          },
          childCount: list.length,
        ),
      ),
    );
  }
}
