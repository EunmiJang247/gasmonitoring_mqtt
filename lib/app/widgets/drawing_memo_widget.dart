import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:safety_check/app/constant/constants.dart';
import 'package:safety_check/app/data/models/11_drawing_memo.dart';
import 'package:safety_check/app/modules/drawing_detail/controllers/drawing_detail_controller.dart';

class DrawingMemoWidget extends StatefulWidget {
  final DrawingMemo memo;
  final DrawingDetailController controller;
  final double verticalPadding;
  final double currentScale;
  final double scaleStd;
  final double touchRange;
  final double fixRange;
  final Offset topLeftOffset;
  final Function({String? x, String? y}) convertDBtoDV;
  final Function({double? x, double? y}) convertDVtoDB;

  const DrawingMemoWidget({
    super.key,
    required this.memo,
    required this.controller,
    required this.verticalPadding,
    required this.currentScale,
    required this.scaleStd,
    required this.touchRange,
    required this.fixRange,
    required this.topLeftOffset,
    required this.convertDBtoDV,
    required this.convertDVtoDB,
  });

  @override
  State<DrawingMemoWidget> createState() => _DrawingMemoWidgetState();
}

class _DrawingMemoWidgetState extends State<DrawingMemoWidget> {
  GlobalKey globalKey = GlobalKey();
  Map<String, String> bfMemoPosition = {};
  double touchWeightX = 0;
  double touchWeightY = 0;

  // 메모 아이콘 크기
  final double memoSize = 24.0;

  @override
  Widget build(BuildContext context) {
    // 메모 위치 계산
    Offset mPosition = widget.convertDBtoDV(x: widget.memo.x, y: widget.memo.y);

    return Positioned(
      left: mPosition.dx - memoSize / 2 - widget.touchRange,
      top: mPosition.dy -
          memoSize / 2 -
          widget.touchRange +
          widget.verticalPadding,
      child: GestureDetector(
        onTap: () {
          // 메모 선택 처리
          widget.controller.curDrawingMemo.value = widget.memo;
          widget.controller.memoView(widget.memo.seq!);
        },
        onLongPressStart: (details) {
          if (widget.currentScale >= widget.scaleStd) {
            widget.controller.isMovingNumOrFault.value = true;
            widget.controller.curDrawingMemo.value = widget.memo;

            // 현재 위치 저장
            bfMemoPosition["x"] = widget.memo.x!;
            bfMemoPosition["y"] = widget.memo.y!;

            // 터치 가중치 계산
            Offset memoCenter = Offset(memoSize / 2 + widget.touchRange,
                memoSize / 2 + widget.touchRange);
            touchWeightX = details.localPosition.dx - memoCenter.dx;
            touchWeightY = details.localPosition.dy - memoCenter.dy;
          }
        },
        onLongPressMoveUpdate: (details) {
          if (widget.currentScale >= widget.scaleStd) {
            // 새로운 위치 계산
            double nextDx = widget.topLeftOffset.dx -
                widget.controller.drawingX +
                (details.globalPosition.dx - leftBarWidth) /
                    widget.currentScale -
                touchWeightX;
            double nextDy = widget.topLeftOffset.dy -
                widget.controller.drawingY +
                (details.globalPosition.dy - appBarHeight) /
                    widget.currentScale -
                touchWeightY;

            if (nextDx < 0 || nextDy < 0) {
              widget.controller.refreshScreen();
              return;
            }

            // 위치 업데이트
            setState(() {
              widget.memo.x = widget.convertDVtoDB(x: nextDx).first;
              widget.memo.y = widget.convertDVtoDB(y: nextDy).first;
            });
          }
        },
        onLongPressEnd: (details) {
          if (widget.currentScale >= widget.scaleStd) {
            widget.controller.isMovingNumOrFault.value = false;

            // 위치 변경되면 수정 사항 업로드
            if (widget.memo.x != bfMemoPosition["x"] ||
                widget.memo.y != bfMemoPosition["y"]) {
              widget.controller.submitDrawingMemo();
            }

            bfMemoPosition.remove("x");
            bfMemoPosition.remove("y");
          }
        },
        child: SizedBox(
          width: memoSize + widget.touchRange * 2,
          height: memoSize + widget.touchRange * 2,
          child: Stack(
            children: [
              // 터치 영역 확장을 위한 투명한 컨테이너
              Center(
                child: Container(
                  width: memoSize + widget.touchRange * 2,
                  height: memoSize + widget.touchRange * 2,
                  decoration: BoxDecoration(
                    color: Colors.transparent,
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
              ),
              // 실제 메모 아이콘
              Center(
                child: SizedBox(
                  key: globalKey,
                  width: memoSize,
                  height: memoSize,
                  // decoration: BoxDecoration(
                  //   color: Colors.amber,
                  //   borderRadius: BorderRadius.circular(memoSize / 2),
                  //   boxShadow: [
                  //     BoxShadow(
                  //       color: Colors.black.withOpacity(0.2),
                  //       blurRadius: 2,
                  //       offset: Offset(0, 1),
                  //     ),
                  //   ],
                  // ),
                  child: Center(
                    child: FaIcon(
                      FontAwesomeIcons.squarePen,
                      size: memoSize * 0.85,
                      color: Colors.teal,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
