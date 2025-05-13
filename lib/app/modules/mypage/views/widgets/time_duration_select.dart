import 'package:flutter/material.dart';

class TimeDurationSelect extends StatefulWidget {
  const TimeDurationSelect({super.key});

  @override
  _TimeDurationSelectState createState() => _TimeDurationSelectState();
}

class _TimeDurationSelectState extends State<TimeDurationSelect> {
  int selectedMinute = 10; // 기본 분

  final List<int> hours = List.generate(24, (index) => index); // 0~23 시간 리스트
  final List<int> minutes = List.generate(60, (index) => index); // 0~59 분 리스트

  late FixedExtentScrollController _minuteController;

  @override
  void initState() {
    super.initState();
    _minuteController = FixedExtentScrollController(
      initialItem: selectedMinute,
    );
  }

  @override
  void dispose() {
    _minuteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      children: [
        const SizedBox(height: 10),
        Text('$selectedMinute 분', style: const TextStyle(fontSize: 20)),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
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
