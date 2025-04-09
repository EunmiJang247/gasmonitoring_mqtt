import 'package:flutter/material.dart';

class InfoTable extends StatelessWidget {
  final String label;
  final dynamic value;
  final double fontSize;
  final int columnSpan;
  final String? secondLabel;
  final dynamic secondValue;

  const InfoTable({
    super.key,
    required this.label,
    required this.value,
    required this.fontSize,
    this.columnSpan = 1,
    this.secondLabel,
    this.secondValue,
  });

  static const double tableCellPadding = 5;

  @override
  Widget build(BuildContext context) {
    return Table(columnWidths: const {
      0: FixedColumnWidth(100),
      1: FlexColumnWidth(),
      2: FixedColumnWidth(80),
      3: FlexColumnWidth(),
    }, children: [
      TableRow(
        children: [
          TableCell(
            child: Padding(
              padding: EdgeInsets.only(bottom: tableCellPadding),
              child: Text(
                label,
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: fontSize,
                ),
              ),
            ),
          ),
          TableCell(
            child: Padding(
              padding: EdgeInsets.only(bottom: tableCellPadding),
              child: value is String
                  ? Text(
                      value,
                      style: TextStyle(fontSize: fontSize),
                    )
                  : value,
            ),
          ),
          if (secondLabel != null)
            TableCell(
              child: Padding(
                padding: EdgeInsets.only(bottom: tableCellPadding),
                child: Text(
                  secondLabel!,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: fontSize,
                  ),
                ),
              ),
            ),
          if (secondValue != null)
            TableCell(
              child: Padding(
                padding: EdgeInsets.only(bottom: tableCellPadding),
                child: secondValue is String
                    ? Text(
                        secondValue!,
                        style: TextStyle(fontSize: fontSize),
                      )
                    : secondValue,
              ),
            ),
        ],
      )
    ]);
  }
}
