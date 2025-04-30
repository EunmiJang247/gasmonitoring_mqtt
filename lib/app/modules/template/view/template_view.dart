import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:safety_check/app/modules/drawing_detail/views/fault_table.dart';
import 'package:safety_check/app/modules/project_info/controllers/project_info_controller.dart';
import 'package:safety_check/app/widgets/custom_app_bar.dart';
import 'package:safety_check/app/widgets/left_menu_bar.dart';

import '../../../constant/constants.dart';

class TemplateView extends GetView<ProjectInfoController> {
  const TemplateView({super.key});
  @override
  Widget build(BuildContext context) {
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
                          controller.goHome();
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
                    children: [],
                  ),
                ),
                Container(
                  padding:
                      EdgeInsets.only(left: leftBarWidth, top: appBarHeight),
                  child: Column(
                    children: [
                      Expanded(
                        child: Container(
                          color: Colors.white,
                          width: double.infinity,
                          child: Obx(
                            () => controller.isFaultListAll.value
                                ? FaultTable(
                                    tableData: controller.tableData,
                                    onTapRow: controller.onTapRow,
                                  )
                                : Row(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [],
                                  ),
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
