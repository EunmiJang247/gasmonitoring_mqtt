import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:get/get.dart';
import 'package:safety_check/app/data/services/app_service.dart';
import 'package:safety_check/app/modules/drawing_detail/controllers/drawing_detail_controller.dart';

import '../../constant/app_color.dart';
import '../../constant/constants.dart';

class TypeSelectionDialog extends StatefulWidget {
  const TypeSelectionDialog({super.key});

  @override
  State<TypeSelectionDialog> createState() => _TypeSelectionDialogState();
}

class _TypeSelectionDialogState extends State<TypeSelectionDialog> {
  final AppService _appService = Get.find();
  DrawingDetailController drawingDetailController = Get.find();
  String selectedCate1 = "";
  List<String> selectedCate2 = [];
  TextEditingController cate1Controller = TextEditingController();
  TextEditingController cate2Controller = TextEditingController();

  @override
  void initState() {
    selectedCate1 = _appService.selectedFault.value.cate1_seq ?? "";
    selectedCate2 = _appService.selectedFault.value.cate2?.split(", ") ?? [];
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        decoration: BoxDecoration(
            color: Color(0xffD9D9D9), borderRadius: BorderRadius.circular(16)),
        width: MediaQuery.of(context).size.width - leftBarWidth,
        height: MediaQuery.of(context).size.height - appBarHeight,
        padding: EdgeInsets.symmetric(horizontal: 8),
        child: Center(
          child: StatefulBuilder(builder: (context, setState) {
            return SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // 카테1
                  SizedBox(
                    child: GridView.builder(
                      physics: NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                      itemCount: _appService.faultCate1!.length + 1,
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 6, mainAxisExtent: 70),
                      itemBuilder: (context, index) {
                        return InkWell(
                            onTap: () {
                              cate1Controller.clear();
                              FocusScope.of(context).unfocus();
                              setState(
                                () {
                                  // 다른 카테고리가 선택되어 있는 경우
                                  if (selectedCate1 != "" &&
                                      selectedCate1 !=
                                          _appService.faultCate1?.keys
                                              .toList()[index]) {
                                    selectedCate1 = _appService.faultCate1?.keys
                                            .toList()[index] ??
                                        "";
                                  } // 해당 카테고리가 선택되어 있는 경우
                                  else if (selectedCate1 ==
                                      _appService.faultCate1?.keys
                                          .toList()[index]) {
                                    selectedCate1 = "";
                                  } else {
                                    selectedCate1 = _appService.faultCate1?.keys
                                            .toList()[index] ??
                                        "";
                                  }
                                },
                              );
                            },
                            child: index != _appService.faultCate1!.length
                                ? Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 8),
                                    constraints: BoxConstraints(minWidth: 100),
                                    decoration: BoxDecoration(
                                        color: selectedCate1 ==
                                                _appService.faultCate1?.keys
                                                    .toList()[index]
                                            ? AppColors.c4
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Center(
                                        child: AutoSizeText(
                                      _appService.faultCate1?.values
                                              .toList()[index] ??
                                          "",
                                      style: TextStyle(
                                          fontFamily: "Pretendard",
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: selectedCate1 ==
                                                  _appService.faultCate1?.keys
                                                      .toList()[index]
                                              ? Colors.white
                                              : Colors.black),
                                      maxLines: 1,
                                    )),
                                  )
                                : Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 8),
                                    constraints: BoxConstraints(minWidth: 100),
                                    decoration: BoxDecoration(
                                        color: cate1Controller.text.isEmpty
                                            ? Colors.white
                                            : AppColors.c4,
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Center(
                                        child: TextField(
                                      onTap: () {
                                        setState(() {
                                          selectedCate1 = "";
                                        });
                                      },
                                      controller: cate1Controller,
                                      decoration: InputDecoration(
                                          hintText: "입력",
                                          hintStyle: TextStyle(
                                              color: Colors.black38,
                                              fontWeight: FontWeight.w600,
                                              fontSize: 18),
                                          border: InputBorder.none),
                                      textAlign: TextAlign.center,
                                      style: TextStyle(
                                        fontFamily: "Pretendard",
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: cate1Controller.text.isEmpty
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                    )),
                                  ));
                      },
                    ),
                  ),

                  // 가로선
                  Divider(
                    color: Colors.black,
                    thickness: 1,
                  ),

                  // 카테2
                  SizedBox(
                    child: GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: _appService.faultCate2!.length + 1,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 6, mainAxisExtent: 70),
                        itemBuilder: (context, index) {
                          return InkWell(
                            onTap: () {
                              FocusScope.of(context).unfocus();
                              setState(
                                () {
                                  if (selectedCate2.contains(_appService
                                      .faultCate2?.keys
                                      .toList()[index])) {
                                    selectedCate2.remove(_appService
                                        .faultCate2?.keys
                                        .toList()[index]);
                                  } else {
                                    selectedCate2.add(_appService
                                            .faultCate2?.keys
                                            .toList()[index] ??
                                        "");
                                  }
                                },
                              );
                            },
                            child: index != _appService.faultCate2!.length
                                ? Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 8),
                                    constraints: BoxConstraints(minWidth: 100),
                                    decoration: BoxDecoration(
                                        color: selectedCate2.contains(
                                                _appService.faultCate2?.keys
                                                    .toList()[index])
                                            ? AppColors.c4
                                            : Colors.white,
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Center(
                                        child: AutoSizeText(
                                      _appService.faultCate2?.values
                                              .toList()[index] ??
                                          "",
                                      style: TextStyle(
                                          fontFamily: "Pretendard",
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: selectedCate2.contains(
                                                  _appService.faultCate2?.keys
                                                      .toList()[index])
                                              ? Colors.white
                                              : Colors.black),
                                      maxLines: 1,
                                    )),
                                  )
                                : Container(
                                    padding:
                                        EdgeInsets.symmetric(horizontal: 10),
                                    margin: EdgeInsets.symmetric(
                                        horizontal: 8, vertical: 8),
                                    constraints: BoxConstraints(minWidth: 100),
                                    decoration: BoxDecoration(
                                        color: cate2Controller.text.isEmpty
                                            ? Colors.white
                                            : AppColors.c4,
                                        borderRadius: BorderRadius.circular(8)),
                                    child: Center(
                                      child: TextField(
                                        controller: cate2Controller,
                                        decoration: InputDecoration(
                                            hintText: "입력",
                                            hintStyle: TextStyle(
                                                color: Colors.black38,
                                                fontWeight: FontWeight.w600,
                                                fontSize: 18),
                                            border: InputBorder.none),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily: "Pretendard",
                                          fontSize: 20,
                                          fontWeight: FontWeight.w600,
                                          color: cate2Controller.text.isEmpty
                                              ? Colors.black
                                              : Colors.white,
                                        ),
                                      ),
                                    )),
                          );
                        }),
                  ),

                  Align(
                    alignment: Alignment.bottomRight,
                    child: IntrinsicWidth(
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              Get.back();
                              FocusScope.of(context).unfocus();
                            },
                            child: Container(
                              height: 54,
                              width: 114,
                              margin: EdgeInsets.only(
                                  top: 12, left: 8, right: 8, bottom: 8),
                              decoration: BoxDecoration(
                                  color: Colors.grey,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Center(
                                child: Text("취소",
                                    style: TextStyle(
                                        fontFamily: "Pretendard",
                                        fontSize: 20,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.black)),
                              ),
                            ),
                          ),
                          InkWell(
                            onTap: () async {
                              if (selectedCate2.isEmpty &&
                                  cate2Controller.text.isEmpty) {
                                Fluttertoast.showToast(
                                    msg: "결함 유형을 하나 이상 선택해주세요",
                                    toastLength: Toast.LENGTH_SHORT,
                                    gravity: ToastGravity.BOTTOM,
                                    timeInSecForIosWeb: 1,
                                    backgroundColor: Colors.black87,
                                    textColor: Colors.white,
                                    fontSize: 16.0);
                              } else {
                                // Cate1 추가
                                if (cate1Controller.text.isNotEmpty) {
                                  int? newCate1Seq =
                                      await _appService.addFaultContent(
                                          type: 1, name: cate1Controller.text);
                                  if (newCate1Seq != null) {
                                    selectedCate1 = newCate1Seq.toString();
                                  }
                                }

                                // Cate2 추가
                                if (cate2Controller.text.isNotEmpty) {
                                  int? newCate2Seq =
                                      await _appService.addFaultContent(
                                          type: 2, name: cate2Controller.text);
                                  // 새로운 Cate2 가 있을 경우 선택된 Cate2 에 추가
                                  if (newCate2Seq != null) {
                                    selectedCate2.add(newCate2Seq.toString());
                                  }
                                }

                                // 선택된 Cate1 설정
                                _appService.selectedFault.value.cate1_seq =
                                    selectedCate1;

                                // 선택된 Cate2 설정
                                _appService.selectedFault.value.cate2 =
                                    selectedCate2.join(", ");

                                FocusScope.of(context).unfocus();
                                Get.back();
                              }
                            },
                            child: Container(
                              height: 54,
                              width: 114,
                              margin: EdgeInsets.only(
                                  top: 12, left: 8, right: 8, bottom: 8),
                              decoration: BoxDecoration(
                                  color: AppColors.c1,
                                  borderRadius: BorderRadius.circular(8)),
                              child: Center(
                                child: Text("확인",
                                    style: TextStyle(
                                      fontFamily: "Pretendard",
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white,
                                    )),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            );
          }),
        ),
      ),
    );
  }
}
