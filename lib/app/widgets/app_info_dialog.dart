import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../constant/gaps.dart';
import '../constant/sizes.dart';
import '../data/models/update_history.dart';

class AppInfoDialog extends StatefulWidget {
  final List<UpdateHistoryItem>? updateHistory;

  const AppInfoDialog({
    super.key,
    required this.updateHistory,
  });

  @override
  State<AppInfoDialog> createState() => _AppInfoDialog();
}

class _AppInfoDialog extends State<AppInfoDialog> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusScopeNode currentFocus = FocusScope.of(context);
        if (!currentFocus.hasPrimaryFocus) {
          currentFocus.unfocus();
        }
      },
      child: AlertDialog(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        contentPadding: EdgeInsets.zero,
        insetPadding: const EdgeInsets.symmetric(horizontal: 100),
        titlePadding:
            const EdgeInsets.only(top: 20, left: 20, right: 20, bottom: 10),
        title: Column(
          children: [
            Row(
              children: [
                const Text(
                  '업데이트 정보',
                  style: TextStyle(
                      fontFamily: "Pretendard",
                      fontWeight: FontWeight.w600,
                      fontSize: 18,
                      color: Color(0xFF344054)),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: Container(
                      alignment: Alignment.topRight,
                      child: const Icon(
                        Icons.close,
                        size: Sizes.closeIcon,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            Gaps.h10,
          ],
        ),
        content: CupertinoScrollbar(
          child: Container(
            width: Get.size.width - 40,
            height: Get.size.height - 200,
            padding: EdgeInsets.only(left: 10.w, right: 10.w, bottom: 10.h),
            child: ListView.builder(
              itemCount: widget.updateHistory!.length,
              itemBuilder: (context, index) => Column(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 1,
                    // margin: EdgeInsets.only(left: 15.w, right: 15.w),
                    color: const Color(0xFFEAECF0),
                  ),
                  Gaps.h5,
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          width: Get.size.width,
                          margin: EdgeInsets.only(top: 8.h, left: 5.w),
                          child: Text(
                            widget.updateHistory![index].version,
                            style: const TextStyle(
                                fontFamily: "Pretendard",
                                fontWeight: FontWeight.w700,
                                fontSize: 16,
                                color: Color(0xFF5F6262)),
                          ),
                        ),
                      ),
                    ],
                  ),
                  Gaps.h12,
                  Container(
                    margin:
                        EdgeInsets.only(left: 10.w, right: 10.w, bottom: 10.h),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        for (var txt in widget.updateHistory![index].history)
                          Column(
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    '•',
                                    style: TextStyle(
                                        fontFamily: "Pretendard",
                                        fontWeight: FontWeight.w400,
                                        fontSize: 14,
                                        color: Color(0xFF5F6262)),
                                  ),
                                  Gaps.w6,
                                  Expanded(
                                    child: Text(
                                      txt,
                                      style: const TextStyle(
                                          fontFamily: "Pretendard",
                                          fontWeight: FontWeight.w400,
                                          fontSize: 14,
                                          height: 1.2,
                                          color: Color(0xFF5F6262)),
                                    ),
                                  ),
                                ],
                              ),
                              Gaps.h8,
                            ],
                          ),
                      ],
                    ),
                  ),
                  Gaps.h5,
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
