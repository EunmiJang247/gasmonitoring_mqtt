import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safety_check/app/constant/app_color.dart';
import 'package:safety_check/app/constant/gaps.dart';
import 'dart:io';
import 'package:safety_check/app/data/models/05_picture.dart';
import 'package:safety_check/app/modules/project_checks/controllers/project_checks_controller.dart';
import 'package:safety_check/app/utils/log.dart';
import 'package:safety_check/app/widgets/two_button_dialog.dart';

class PhotoDetailModal extends StatefulWidget {
  final CustomPicture picture;
  final String? title;
  final String? remark;

  const PhotoDetailModal({
    Key? key,
    required this.picture,
    this.title,
    this.remark,
  }) : super(key: key);

  @override
  State<PhotoDetailModal> createState() => _PhotoDetailModalState();
}

class _PhotoDetailModalState extends State<PhotoDetailModal> {
  late TextEditingController _remarkController;
  final controller = Get.find<ProjectChecksController>();

  @override
  void initState() {
    super.initState();
    _remarkController = TextEditingController(text: widget.remark);
  }

  @override
  void dispose() {
    _remarkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    print('PhotoDetailModal: ${widget.picture.toJson()}');
    return Dialog(
      backgroundColor: Colors.transparent,
      child: SingleChildScrollView(
        child: Container(
          constraints: BoxConstraints(
            maxWidth: MediaQuery.of(context).size.width * 0.9,
            maxHeight: MediaQuery.of(context).size.height * 0.8,
          ),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              SizedBox(height: 20),
              Expanded(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 16,
                    ),
                    Expanded(
                      flex: 2,
                      child: InteractiveViewer(
                        minScale: 0.5,
                        maxScale: 4.0,
                        child: widget.picture.file_path != null
                            ? (widget.picture.file_path!.startsWith('http')
                                ? SizedBox.expand(
                                    child: Image.network(
                                      widget.picture.file_path!,
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(Icons.error);
                                      },
                                    ),
                                  )
                                : SizedBox.expand(
                                    child: Image.file(
                                      File(widget.picture.file_path!),
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        return const Icon(Icons.error);
                                      },
                                    ),
                                  ))
                            : const Icon(Icons.image_not_supported),
                      ),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Text(
                              '메모',
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(height: 8),
                            TextField(
                              controller: _remarkController,
                              minLines: 3,
                              maxLines: 3, // ✅ 최대 3줄까지만 보임
                              keyboardType: TextInputType.multiline,
                              scrollPhysics:
                                  const BouncingScrollPhysics(), // ✅ 스크롤 가능
                              decoration: InputDecoration(
                                hintText: '메모를 입력하세요',
                                border: OutlineInputBorder(),
                                contentPadding: EdgeInsets.all(12),
                              ),
                            ),
                            SizedBox(height: 16),
                            Row(
                              children: [
                                Expanded(
                                  child: MaterialButton(
                                    onPressed: () async {
                                      try {
                                        await controller.onRemarkSubmit(
                                            widget.picture,
                                            _remarkController.text);
                                        Navigator.of(context)
                                            .pop(_remarkController.text);
                                      } catch (e) {
                                        logError(e);
                                      }
                                    },
                                    color: AppColors.button,
                                    child: Text(
                                      "저장",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "Pretendard",
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: 8,
                                ),
                                Expanded(
                                  child: MaterialButton(
                                    onPressed: () {
                                      Navigator.of(context).pop();
                                    },
                                    color: AppColors.button,
                                    child: Text(
                                      "닫기",
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontFamily: "Pretendard",
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(
                              width: double.infinity, // 💥 100% 가로 폭 차지
                              child: MaterialButton(
                                onPressed: () {
                                  _showDeleteConfirmationDialog();
                                },
                                color: AppColors.button,
                                child: Text(
                                  "사진 삭제",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontFamily: "Pretendard",
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            )
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) {
        return TwoButtonDialog(
          height: 200,
          content: Column(
            children: [
              Text(
                "사진 삭제",
                style: TextStyle(
                    fontFamily: "Pretendard",
                    color: AppColors.c1,
                    fontWeight: FontWeight.bold,
                    fontSize: 22),
              ),
              Gaps.h16,
              Text(
                "사진을 삭제하시겠습니까?\n삭제하면 복구 할 수 없습니다.",
                style: TextStyle(
                  fontFamily: "Pretendard",
                  fontSize: 18,
                ),
                textAlign: TextAlign.center,
              )
            ],
          ),
          yes: "삭제",
          no: "취소",
          onYes: () {
            controller.onDeletePicture(widget.picture);
            Get.back();
          },
          onNo: () => Get.back(),
        );
      },
    );
  }
}
