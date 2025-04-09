import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:safety_check/app/constant/app_color.dart';
import 'package:safety_check/app/constant/gaps.dart';
import 'package:safety_check/app/modules/drawing_detail/views/fault_table.dart';
import 'package:safety_check/app/modules/project_checks/view/photo_box.dart';
import 'package:safety_check/app/modules/project_info/views/info_table_row.dart';
import 'package:safety_check/app/utils/formatter.dart';
import 'package:safety_check/app/widgets/custom_app_bar.dart';
import 'package:safety_check/app/widgets/left_menu_bar.dart';
import 'package:safety_check/app/widgets/photo.dart';

import '../../../constant/constants.dart';
import '../../project_checks/controllers/project_checks_controller.dart';

class CheckList extends GetView<ProjectChecksController> {
  const CheckList({super.key});
  @override
  Widget build(BuildContext context) {
    double infoFontSize = 16;

    // // 포커스 리스너 설정
    // WidgetsBinding.instance.addPostFrameCallback((_) {
    //   if (!controller.requirementFocus.hasListeners) {

    //   }
    // });

    // dtInfo 계산 로직
    RxString dtInfo = "".obs;
    String? fieldStDt = controller.appService.curProject!.value.field_bgn_dt;
    String? fieldEndDt = controller.appService.curProject!.value.field_end_dt;
    String? bgnDt = fieldStDt?.split("-").join(". ");
    List<String?> temp = [];
    if (controller.appService.curProject!.value.field_end_dt != null) {
      temp = fieldEndDt!.split('-');
      temp.removeAt(0);
    }
    String? endDt = temp.join(". ");
    dtInfo.value = "$bgnDt ~ $endDt";

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          controller.goHome();
        }
      },
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: GestureDetector(
            onTap: () => FocusScope.of(context).unfocus(),
            child: Stack(
              children: [
                CustomAppBar(
                  leftSide: Stack(
                    children: [
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Container(
                          padding: EdgeInsets.only(left: 48),
                          width: 200.w,
                          child: Text(
                            controller.appService.curProject!.value.name ?? "",
                            style: TextStyle(
                              fontFamily: "Pretendard",
                              fontSize: 20,
                              fontWeight: FontWeight.w600,
                            ),
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          FocusScope.of(context).unfocus();
                          Get.back();
                        },
                        child: Container(
                          margin: EdgeInsets.only(right: 44),
                          height: appBarHeight,
                          width: 44,
                          child: Icon(
                            Icons.arrow_back_ios_new,
                            size: 28,
                          ),
                        ),
                      ),
                    ],
                  ),
                  rightSide: Row(
                    children: [
                      MaterialButton(
                        onPressed: () {
                          controller.requirementFocus.unfocus();
                          controller.goDrawingList();
                        },
                        color: AppColors.button,
                        child: Text("도면 목록",
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: "Pretendard",
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            )),
                      ),
                    ],
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.only(left: leftBarWidth, top: appBarHeight),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          padding: EdgeInsets.only(
                            left: 16.w,
                            right: 16.w,
                            top: 16.h,
                            bottom: 16.h,
                          ),
                          color: Colors.white,
                          width: double.infinity,
                          // isFaultListAll 에 따라 UI를 변경하는 부분만 Obx로 감싸기
                          child: Column(
                            children: [
                              Container(
                                alignment: Alignment.centerLeft,
                                margin: EdgeInsets.only(bottom: 10.h),
                                padding: EdgeInsets.only(left: 16.w),
                                child: Text(
                                  '외벽마감재',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    fontSize: 16,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: double.infinity,
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    PhotoBox(),
                                    PhotoBox(),
                                    PhotoBox(),
                                    PhotoBox(),
                                    PhotoBox(),
                                  ],
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                LeftMenuBar(),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
