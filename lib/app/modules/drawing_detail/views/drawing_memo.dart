import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:safety_check/app/constant/app_color.dart';
import 'package:safety_check/app/constant/gaps.dart';

import 'package:safety_check/app/widgets/photo.dart';
import 'package:safety_check/app/widgets/two_button_dialog.dart';
import '../controllers/drawing_detail_controller.dart';

class DrawingMemoView extends GetView<DrawingDetailController> {
  const DrawingMemoView({super.key});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Obx(
        () => AlertDialog(
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          contentPadding: EdgeInsets.zero,
          insetPadding: const EdgeInsets.symmetric(horizontal: 100),
          titlePadding:
              const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
          actionsAlignment: MainAxisAlignment.center,
          actionsPadding: const EdgeInsets.only(bottom: 20),
          actions: [
            MaterialButton(
              onPressed: () {
                controller.submitDrawingMemo();
                Get.back();
              },
              color: Colors.blueAccent,
              child: Text("저장",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            Gaps.w3,
            if (controller.memoPicture.value != null)
              MaterialButton(
                onPressed: () {
                  controller.drawingMemoFocusNode.unfocus();
                  showDialog(
                    context: context,
                    builder: (context) {
                      return TwoButtonDialog(
                        height: 200,
                        content: Column(
                          children: [
                            Text(
                              "확인",
                              style: TextStyle(
                                  fontFamily: "Pretendard",
                                  color: AppColors.c1,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 22),
                            ),
                            Gaps.h16,
                            Text(
                              "메모의 사진을 삭제 하시겠어요?",
                              style: TextStyle(
                                fontFamily: "Pretendard",
                                fontSize: 18,
                              ),
                              textAlign: TextAlign.center,
                            )
                          ],
                        ),
                        yes: "예",
                        no: "아니오",
                        onYes: () {
                          controller.deleteMemoPicture();
                          Get.back();
                        },
                        onNo: () => Get.back(),
                      );
                    },
                  );
                },
                color: Colors.green[500],
                child: Text("사진삭제",
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    )),
              ),
            if (controller.memoPicture.value != null) Gaps.w3,
            MaterialButton(
              onPressed: () {
                controller.drawingMemoFocusNode.unfocus();
                showDialog(
                  context: context,
                  builder: (context) {
                    return TwoButtonDialog(
                      height: 200,
                      content: Column(
                        children: [
                          Text(
                            "확인",
                            style: TextStyle(
                                fontFamily: "Pretendard",
                                color: AppColors.c1,
                                fontWeight: FontWeight.bold,
                                fontSize: 22),
                          ),
                          Gaps.h16,
                          Text(
                            "메모를 삭제 하시겠어요?",
                            style: TextStyle(
                              fontFamily: "Pretendard",
                              fontSize: 18,
                            ),
                            textAlign: TextAlign.center,
                          )
                        ],
                      ),
                      yes: "예",
                      no: "아니오",
                      onYes: () {
                        controller.deleteMemo();
                        Get.back();
                      },
                      onNo: () => Get.back(),
                    );
                  },
                );
              },
              color: Colors.red[400],
              child: Text("삭제",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  )),
            ),
            Gaps.w3,
            MaterialButton(
              onPressed: () {
                controller.closeDrawingMemo();
              },
              color: Colors.grey,
              child: Text("취소",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  )),
            ),
          ],
          content: Container(
            width: 200.w,
            height: 300.h,
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // 왼쪽 - 사진 표시
                Expanded(
                  flex: 1,
                  child: Container(
                    child: controller.memoPicture.value != null
                        ? InkWell(
                            onTap: () {
                              if (controller.drawingMemoFocusNode.hasFocus) {
                                controller.drawingMemoFocusNode.unfocus();
                              } else {
                                FocusScope.of(context).unfocus(); // 키보드 내리기
                                controller.memoPictureView();
                              }
                            },
                            child: SizedBox(
                              height: double.infinity,
                              child: Photo(
                                imageUrl:
                                    controller.memoPicture.value!.file_path,
                                boxFit: BoxFit.cover,
                              ),
                            ),
                          )
                        : InkWell(
                            onTap: () => controller.takeMemoPicture(),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.grey[200],
                                borderRadius: BorderRadius.circular(10.0),
                              ),
                              child: Center(
                                child: FaIcon(
                                  FontAwesomeIcons.camera,
                                  size: 80,
                                  color: Colors.grey[400],
                                ),
                              ),
                            ),
                          ),
                  ),
                ),
                const SizedBox(width: 16.0),
                // 오른쪽 - 메모 TextField
                Expanded(
                  flex: 1,
                  child: Container(
                    decoration: BoxDecoration(
                      border: Border.all(color: Colors.grey[300]!),
                      borderRadius: BorderRadius.circular(10.0),
                    ),
                    height: double.infinity,
                    child: TextField(
                      focusNode: controller.drawingMemoFocusNode,
                      controller: controller.memoTextController,
                      textInputAction: TextInputAction.done,
                      decoration: InputDecoration(
                        contentPadding: EdgeInsets.all(12),
                        hintText: "메모를 입력하세요",
                        border: InputBorder.none,
                      ),
                      style: TextStyle(fontSize: 16),
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
