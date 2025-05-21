import 'dart:async';
import 'package:flutter/material.dart';

class EllipsisLoadingIndicatorCustom extends StatefulWidget {
  const EllipsisLoadingIndicatorCustom({super.key});

  @override
  State<EllipsisLoadingIndicatorCustom> createState() =>
      _EllipsisLoadingIndicatorCustomState();
}

class _EllipsisLoadingIndicatorCustomState
    extends State<EllipsisLoadingIndicatorCustom> {
  late Timer _timer;
  int _dotCount = 0;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(milliseconds: 500), (timer) {
      setState(() {
        _dotCount = (_dotCount % 3) + 1;
      });
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String dots = '.' * _dotCount;
    return RichText(
      text: TextSpan(
        children: [
          const TextSpan(
            text: '내면을 들여다보는 자는 깨어난다',
            style: TextStyle(
              color: Color(0xFFFFFF00), // Namaste 텍스트 색상
              fontSize: 16,
            ),
          ),
          TextSpan(
            text: dots,
            style: const TextStyle(
              color: Color(0xFFFFFF00), // 형광노랑색 도트
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }
}
