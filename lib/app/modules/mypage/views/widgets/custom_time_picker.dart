import 'package:flutter/material.dart';

class CustomTimePicker extends StatefulWidget {
  const CustomTimePicker({super.key});

  @override
  _CustomTimePickerState createState() => _CustomTimePickerState();
}

class _CustomTimePickerState extends State<CustomTimePicker> {
  int selectedHour = 12; // 기본 시
  int selectedMinute = 30; // 기본 분

  final List<int> hours = List.generate(24, (index) => index); // 0~23 시간 리스트
  final List<int> minutes = List.generate(6, (index) => index * 10);

  late FixedExtentScrollController _hourController;
  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    // 시간과 분을 초기화한 후 컨트롤러에 설정
    _hourController = FixedExtentScrollController(initialItem: selectedHour);
    _minuteController = FixedExtentScrollController(
      initialItem: minutes.indexOf(selectedMinute),
    );
  }

  @override
  void dispose() {
    _hourController.dispose();
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 20),
        Text(
          '선택된 시간: $selectedHour 시 $selectedMinute 분',
          style: const TextStyle(fontSize: 20),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 시 스크롤
            _buildWheelPicker(
              list: hours,
              controller: _hourController,
              onSelectedItemChanged: (index) {
                setState(() {
                  selectedHour = index;
                });
              },
            ),
            const SizedBox(width: 4),
            const Text(
              "시", // "시" 텍스트
              style: TextStyle(fontSize: 18),
            ),
            const SizedBox(width: 10),
            // 분 스크롤
            _buildWheelPicker(
              list: minutes,
              controller: _minuteController,
              onSelectedItemChanged: (index) {
                setState(() {
                  selectedMinute = index;
                });
              },
            ),
            const SizedBox(width: 4),
            const Text(
              "분", // "분" 텍스트
              style: TextStyle(fontSize: 18),
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
      height: 120,
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
                style: const TextStyle(fontSize: 24),
              ),
            );
          },
          childCount: list.length,
        ),
      ),
    );
  }
}
