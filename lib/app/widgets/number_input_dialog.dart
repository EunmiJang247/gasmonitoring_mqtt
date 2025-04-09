import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safety_check/app/constant/app_color.dart';
import 'package:safety_check/app/constant/gaps.dart';
import 'package:safety_check/app/data/services/app_service.dart';
import 'package:safety_check/app/modules/drawing_detail/controllers/drawing_detail_controller.dart';

class NumberInputDialog extends StatefulWidget {
  const NumberInputDialog({super.key, required this.attribute});
  final String attribute;
  @override
  State<NumberInputDialog> createState() => _NumberInputDialogState();
}

class _NumberInputDialogState extends State<NumberInputDialog> {
  AppService appService = Get.find();
  final DrawingDetailController drawingDetailController = Get.find();
  List<int> nums = [0, 0, 0, 0];
  String degree = "00.00";

  int cursor = 1;
  double inputFieldWidth = 100;
  double inputFieldHeight = 150;

  @override
  void initState() {
    if (widget.attribute == "폭") {
      if (appService.selectedFault.value.width?.isNotEmpty ?? false) {
        degree = double.parse(appService.selectedFault.value.width!).toString();
      } else {
        degree = "00.00";
      }
    } else if (widget.attribute == "길이") {
      if (appService.selectedFault.value.length?.isNotEmpty ?? false) {
        degree =
            double.parse(appService.selectedFault.value.length!).toString();
      } else {
        degree = "00.00";
      }
    }
    if (degree.length < 5) {
      if (degree[1] == ".") {
        degree = "0$degree";
      }
      if (degree.length == 4) {
        degree += "0";
      }
    }
    nums[0] = int.parse(degree[0]);
    nums[1] = int.parse(degree[1]);
    nums[2] = int.parse(degree[3]);
    nums[3] = int.parse(degree[4]);
    // print(nums);
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      insetPadding: EdgeInsets.zero,
      child: Container(
        width: 600,
        height: 450,
        decoration: BoxDecoration(
            color: Color(0xffD9D9D9), borderRadius: BorderRadius.circular(16)),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Text("${widget.attribute}을(를) 지정해주세요.",
                  style: TextStyle(
                      fontFamily: "Pretendard",
                      fontSize: 18,
                      fontWeight: FontWeight.w600)),
            ),
            Expanded(
              flex: 3,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  InkWell(
                    onTap: () => setState(() {
                      cursor = 0;
                    }),
                    child: Container(
                      height: inputFieldHeight,
                      width: inputFieldWidth,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        // // border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        children: [
                          Center(
                              child: Text(
                            nums[0].toString(),
                            style: TextStyle(
                              fontFamily: "Pretendard",
                              fontSize: 50,
                            ),
                          )),
                          Visibility(
                            visible: cursor == 0,
                            child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Divider(
                                  thickness: 4,
                                  color: AppColors.c4,
                                  indent: 8,
                                  endIndent: 8,
                                )),
                          )
                        ],
                      ),
                    ),
                  ),
                  Gaps.w12,
                  InkWell(
                    onTap: () => setState(() {
                      cursor = 1;
                    }),
                    child: Container(
                      height: inputFieldHeight,
                      width: inputFieldWidth,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        // // border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        children: [
                          Center(
                              child: Text(
                            nums[1].toString(),
                            style: TextStyle(
                              fontFamily: "Pretendard",
                              fontSize: 50,
                            ),
                          )),
                          Visibility(
                            visible: cursor == 1,
                            child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Divider(
                                  thickness: 4,
                                  color: AppColors.c4,
                                  indent: 8,
                                  endIndent: 8,
                                )),
                          )
                        ],
                      ),
                    ),
                  ),
                  Gaps.w12,
                  Align(
                    alignment: Alignment.bottomCenter,
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 60.0),
                      child: Text(
                        ".",
                        style: TextStyle(
                            fontFamily: "Pretendard",
                            fontSize: 50,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  Gaps.w12,
                  InkWell(
                    onTap: () => setState(() {
                      cursor = 2;
                    }),
                    child: Container(
                      height: inputFieldHeight,
                      width: inputFieldWidth,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        // // border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        children: [
                          Center(
                              child: Text(
                            nums[2].toString(),
                            style: TextStyle(
                              fontFamily: "Pretendard",
                              fontSize: 50,
                            ),
                          )),
                          Visibility(
                            visible: cursor == 2,
                            child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Divider(
                                  thickness: 4,
                                  color: AppColors.c4,
                                  indent: 8,
                                  endIndent: 8,
                                )),
                          )
                        ],
                      ),
                    ),
                  ),
                  Gaps.w12,
                  InkWell(
                    onTap: () => setState(() {
                      cursor = 3;
                    }),
                    child: Container(
                      height: inputFieldHeight,
                      width: inputFieldWidth,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        // // border: Border.all(color: Colors.grey),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Stack(
                        children: [
                          Center(
                              child: Text(
                            nums[3].toString(),
                            style: TextStyle(
                              fontFamily: "Pretendard",
                              fontSize: 50,
                            ),
                          )),
                          Visibility(
                            visible: cursor == 3,
                            child: Align(
                                alignment: Alignment.bottomCenter,
                                child: Divider(
                                  thickness: 4,
                                  color: AppColors.c4,
                                  indent: 8,
                                  endIndent: 8,
                                )),
                          )
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.only(left: 16.0, right: 16),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // InkWell(
                    //   onTap: () {
                    //     if (cursor>0) {
                    //       setState(() {
                    //         cursor -= 1;
                    //       });
                    //     }
                    //   },
                    //   child: Container(
                    //     width: 50,
                    //     height: 110,
                    //     decoration: BoxDecoration(
                    //         color: Colors.white,
                    //         // border: Border.all(color: Colors.grey),
                    //         borderRadius: BorderRadius.circular(5),
                    //     ),
                    //     child: Center(child: Icon(Icons.keyboard_arrow_left_outlined)
                    //     ),
                    //   ),
                    // ),
                    // Gaps.w12,
                    Expanded(
                      child: GridView.builder(
                        shrinkWrap: true,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            mainAxisExtent: 50,
                            crossAxisSpacing: 12,
                            mainAxisSpacing: 12),
                        itemCount: 10,
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              setState(() {
                                nums[cursor] = index;
                                if (cursor < 3) {
                                  cursor += 1;
                                }
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                // border: Border.all(color: Colors.grey),
                                borderRadius: BorderRadius.circular(5),
                              ),
                              child: Center(
                                  child: Text(
                                index.toString(),
                                style: TextStyle(
                                  fontFamily: "Pretendard",
                                  fontSize: 30,
                                ),
                              )),
                            ),
                          );
                        },
                      ),
                    ),
                    // Gaps.w12,
                    // InkWell(
                    //   onTap: () {
                    //     if (cursor<3) {
                    //       setState(() {
                    //         cursor += 1;
                    //       });
                    //     }
                    //   },
                    //   child: Container(
                    //     width: 50,
                    //     height: 110,
                    //     decoration: BoxDecoration(
                    //         color: Colors.white,
                    //         // border: Border.all(color: Colors.grey),
                    //         borderRadius: BorderRadius.circular(5),
                    //     ),
                    //     child: Center(child: Icon(Icons.keyboard_arrow_right_rounded)
                    //     ),
                    //   ),
                    // ),
                  ],
                ),
              ),
            ),
            InkWell(
              onTap: () {
                // print(nums);
                if (widget.attribute == "폭") {
                  appService.selectedFault.value.width =
                      double.parse("${nums[0]}${nums[1]}.${nums[2]}${nums[3]}")
                          .toString();
                  // print(drawingDetailController.selectedFault.value.width);
                } else if (widget.attribute == "길이") {
                  appService.selectedFault.value.length =
                      double.parse("${nums[0]}${nums[1]}.${nums[2]}${nums[3]}")
                          .toString();
                  // print(drawingDetailController.selectedFault.value.length);
                }
                Get.back();
                appService.isFaultSelected.value = false;
                appService.isFaultSelected.value = true;
                FocusScope.of(context).unfocus();
              },
              child: Container(
                height: 38,
                decoration: BoxDecoration(
                  color: Colors.black,
                  // border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(5),
                ),
                margin: EdgeInsets.all(16),
                child: Center(
                    child: Text(
                  "확인",
                  style: TextStyle(
                      fontFamily: "Pretendard",
                      fontSize: 16,
                      color: Colors.white),
                )),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
