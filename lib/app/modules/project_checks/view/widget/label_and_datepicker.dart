import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:safety_check/app/constant/app_color.dart';
import 'package:safety_check/app/utils/log.dart';

class LabelAndDatePicker extends StatefulWidget {
  const LabelAndDatePicker(
      {super.key,
      required this.label,
      this.text,
      this.onDateTap,
      required this.onDateChange});

  final String label;
  final String? text; // 서버에서 받은 초기 날짜 (nullable)
  final VoidCallback? onDateTap; // 👈 포커스 해제 콜백 추가
  final Function onDateChange;

  @override
  State<LabelAndDatePicker> createState() => _LabelAndDatePickerState();
}

class _LabelAndDatePickerState extends State<LabelAndDatePicker> {
  late DateTime? _selectedDate;
  @override
  void initState() {
    super.initState();

    // 초기 날짜 세팅 (유효한 경우), 아니면 오늘 날짜
    final parsed = DateTime.tryParse(widget.text ?? '');
    logInfo("widget.text 날짜 : ${widget.text}");
    logInfo("parsed 날짜 : ${parsed}");
    // _selectedDate = parsed ?? DateTime.now();
    if (parsed != null) {
      _selectedDate = parsed;
    } else {
      _selectedDate = null; // 아무 날짜도 안 보이게
    }
  }

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Text(
        widget.label,
        style: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      const SizedBox(width: 8),
      Container(
        decoration: const BoxDecoration(
          border: Border(
            bottom: BorderSide(
              color: Colors.grey, // 원하는 색상
              width: 1.0, // 원하는 두께
            ),
          ),
        ),
        child: TextButton(
          onPressed: () async {
            final picked = await showDatePicker(
                locale: const Locale('ko'),
                context: context,
                initialDate: _selectedDate,
                firstDate: DateTime(1950),
                lastDate: DateTime.now()
                    .add(const Duration(days: 365 * 3)), // ⬅️ 지금부터 3년 후
                builder: (BuildContext context, Widget? child) {
                  return Theme(
                    data: Theme.of(context).copyWith(
                      colorScheme: ColorScheme.light(
                        primary: AppColors.button, // ✅ 포인트 색상
                        onPrimary: Colors.white, // 선택된 날짜 텍스트 색상
                        onSurface: Colors.black, // 기본 텍스트 색상
                      ),
                      dialogTheme: const DialogTheme(
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.zero, // ✅ 네모 모양
                        ),
                      ),
                    ),
                    child: child!,
                  );
                });

            widget.onDateTap!(); // ✅ 부모에서 전달한 unfocus 실행

            if (picked != null) {
              logInfo(picked);
              setState(() {
                _selectedDate = picked;
              });
              widget.onDateChange(_selectedDate);
            }
          },
          style: TextButton.styleFrom(
            padding:
                const EdgeInsets.only(left: 4, right: 10, bottom: 3), // 여기서 조절!
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: _selectedDate != null
              ? Text(
                  DateFormat('yyyy-MM-dd').format(_selectedDate!),
                  style: const TextStyle(
                    fontSize: 14,
                    color: Colors.black,
                    fontWeight: FontWeight.normal,
                  ),
                )
              : Row(
                  children: [
                    Text(
                      "날짜 선택",
                      style: const TextStyle(
                        fontSize: 14,
                        color: Colors.black,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    const SizedBox(width: 20), // 텍스트와 아이콘 사이 간격
                    const Icon(
                      Icons.calendar_today,
                      size: 18,
                      color: Colors.grey,
                    ),
                  ],
                ), // ✅ 아무 날짜 없으면 이 텍스트 보임
        ),
      ),
    ]);
  }
}
