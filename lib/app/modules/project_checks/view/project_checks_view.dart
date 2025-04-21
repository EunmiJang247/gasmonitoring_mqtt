import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:safety_check/app/constant/app_color.dart';
import 'package:safety_check/app/constant/gaps.dart';
import 'package:safety_check/app/data/models/12_building_safety_check.dart';
import 'package:safety_check/app/modules/drawing_detail/views/fault_table.dart';
import 'package:safety_check/app/modules/project_checks/view/widget/photo_box.dart';
import 'package:safety_check/app/modules/project_checks/view/widget/header.dart';
import 'package:safety_check/app/modules/project_checks/view/widget/project_checks_info.dart';
import 'package:safety_check/app/modules/project_checks/view/widget/project_checks_result_cards.dart';
import 'package:safety_check/app/modules/project_info/views/info_table_row.dart';
import 'package:safety_check/app/utils/formatter.dart';
import 'package:safety_check/app/widgets/custom_app_bar.dart';
import 'package:safety_check/app/widgets/left_menu_bar.dart';
import 'package:safety_check/app/widgets/photo.dart';

import '../../../constant/constants.dart';
import '../../project_checks/controllers/project_checks_controller.dart';

BuildingSafetyCheck sample = BuildingSafetyCheck(
    inspectorName: "홍길동",
    inspectionDate: "2023-10-01",
    buildingName: "Sample Building",
    type: "1종",
    inspectionItem: "정기안전점검",
    data: [
      BuildingCardInfo(
        caption: "외부",
        children: [
          BuildingCardChild(
            kind: "외부 점검",
            pictures: [
              BuildingCardPicture(title: "외부 점검 1", pid: "1", remark: "remark"),
            ],
            remark: "",
          ),
        ],
      ),
    ]);

class CheckList extends GetView<ProjectChecksController> {
  const CheckList({super.key});
  @override
  Widget build(BuildContext context) {
    double infoFontSize = 16;

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
                ProjectChecksHeader(),
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
                          child: Column(
                            children: [
                              ProjectChecksInfo(
                                inspectorName: sample.inspectorName,
                                inspectionDate: sample.inspectionDate,
                                buildingName: sample.buildingName,
                                type: sample.type,
                              ),
                              ProjectChecksResultCards(data: sample.data),
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
