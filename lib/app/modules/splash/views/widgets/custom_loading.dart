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
    return Text(
      'Namaste$dots',
    );
  }
}
