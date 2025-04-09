import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';

import '../../constant/app_color.dart';
import '../../data/models/04_fault.dart';
import '../../data/services/app_service.dart';

class StatusSelectionDialog extends StatefulWidget {
  const StatusSelectionDialog({super.key, this.fault});
  final Fault? fault;

  @override
  State<StatusSelectionDialog> createState() => _StatusSelectionDialogState();
}

class _StatusSelectionDialogState extends State<StatusSelectionDialog> {
  final AppService _appService = Get.find();
  TextEditingController statusController = TextEditingController();

  String selectedStatus = "";

  String? get curStatus => widget.fault?.status;

  @override
  void initState() {
    super.initState();
    selectedStatus = curStatus ?? "";
    if (!(_appService.statusList!.contains(curStatus))) {
      statusController.text = curStatus ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.4,
        decoration: BoxDecoration(
            color: Color(0xffD9D9D9), borderRadius: BorderRadius.circular(16)),
        padding: EdgeInsets.all(8),
        child: Center(
          child: StatefulBuilder(
            builder: (context, setState) {
              return KeyboardVisibilityBuilder(
                  builder: (context, isKeyboardVisible) {
                return SingleChildScrollView(
                  reverse: isKeyboardVisible,
                  child: Column(
                    children: [
                      GridView.builder(
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemCount: _appService.statusList!.length + 1,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 4,
                            mainAxisExtent:
                                MediaQuery.of(context).size.height * 0.125),
                        itemBuilder: (context, index) {
                          if (index < _appService.statusList!.length) {
                            return InkWell(
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                setState(() {
                                  if (selectedStatus ==
                                      _appService.statusList![index]) {
                                    selectedStatus = "";
                                  } else {
                                    selectedStatus =
                                        _appService.statusList![index] ?? "";
                                    statusController.text = "";
                                  }
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                margin: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                                constraints: BoxConstraints(minWidth: 100),
                                decoration: BoxDecoration(
                                    color: selectedStatus ==
                                            _appService.statusList![index]
                                        ? AppColors.c4
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Center(
                                    child: AutoSizeText(
                                  _appService.statusList![index] ?? "",
                                  style: TextStyle(
                                      fontFamily: "Pretendard",
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: selectedStatus ==
                                              _appService.statusList![index]
                                          ? Colors.white
                                          : Colors.black),
                                  maxLines: 1,
                                )),
                              ),
                            );
                          } else {
                            return Container(
                              padding: EdgeInsets.symmetric(horizontal: 10),
                              margin: EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 8),
                              constraints: BoxConstraints(minWidth: 100),
                              decoration: BoxDecoration(
                                color: statusController.text != ""
                                    ? AppColors.c4
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: TextField(
                                  controller: statusController,
                                  decoration: InputDecoration(
                                      hintText: "입력",
                                      hintStyle: TextStyle(
                                          color: Colors.black38,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18),
                                      border: InputBorder.none),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: statusController.text != ""
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.w600),
                                  onTap: () {
                                    setState(() {
                                      selectedStatus = "";
                                    });
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      selectedStatus = value;
                                    });
                                  },
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      SizedBox(
                        height: MediaQuery.of(context).size.height * 0.125,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            InkWell(
                              onTap: () {
                                Get.back();
                                FocusScope.of(context).unfocus();
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.21,
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                margin: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                                constraints: BoxConstraints(minWidth: 100),
                                decoration: BoxDecoration(
                                    color: Colors.grey,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Center(
                                    child: Text(
                                  "취소",
                                  style: TextStyle(
                                      fontFamily: "Pretendard",
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black),
                                  maxLines: 1,
                                )),
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                Get.back();
                                _appService.selectedFault.value.status =
                                    selectedStatus;
                                if (selectedStatus != "" &&
                                    !_appService.statusList!
                                        .contains(selectedStatus)) {
                                  _appService.statusList!.add(selectedStatus);
                                }
                                _appService.isFaultSelected.value = false;
                                _appService.isFaultSelected.value = true;
                                FocusScope.of(context).unfocus();
                              },
                              child: Container(
                                width: MediaQuery.of(context).size.width * 0.21,
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                margin: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                                constraints: BoxConstraints(minWidth: 100),
                                decoration: BoxDecoration(
                                    color: Colors.black,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Center(
                                    child: AutoSizeText(
                                  "확인",
                                  style: TextStyle(
                                      fontFamily: "Pretendard",
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.white),
                                  maxLines: 1,
                                )),
                              ),
                            )
                          ],
                        ),
                      )
                    ],
                  ),
                );
              });
            },
          ),
        ),
      ),
    );
  }
}
