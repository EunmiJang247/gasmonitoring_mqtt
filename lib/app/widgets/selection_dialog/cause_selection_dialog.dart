import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import '../../constant/app_color.dart';
import '../../data/models/04_fault.dart';
import '../../data/services/app_service.dart';

class CauseSelectionDialog extends StatefulWidget {
  const CauseSelectionDialog({super.key, this.fault});
  final Fault? fault;

  @override
  State<CauseSelectionDialog> createState() => _CauseSelectionDialogState();
}

class _CauseSelectionDialogState extends State<CauseSelectionDialog> {
  final AppService _appService = Get.find();
  TextEditingController causeController = TextEditingController();

  String selectedCause = "";

  String? get curCause => widget.fault?.cause;

  @override
  void initState() {
    super.initState();
    selectedCause = curCause ?? "";
    if (!(_appService.causeList!.contains(curCause))) {
      causeController.text = curCause ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.85,
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
                        itemCount: (_appService.causeList!.length) + 1,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisExtent:
                                MediaQuery.of(context).size.height * 0.125),
                        itemBuilder: (context, index) {
                          if (index < _appService.causeList!.length) {
                            return InkWell(
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                setState(() {
                                  if (selectedCause ==
                                      _appService.causeList![index]) {
                                    selectedCause = "";
                                  } else {
                                    selectedCause =
                                        _appService.causeList![index];
                                    causeController.text = "";
                                  }
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                margin: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                                constraints: BoxConstraints(minWidth: 100),
                                decoration: BoxDecoration(
                                    color: selectedCause ==
                                            _appService.causeList![index]
                                        ? AppColors.c4
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Center(
                                    child: AutoSizeText(
                                  _appService.causeList![index],
                                  style: TextStyle(
                                      fontFamily: "Pretendard",
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: selectedCause ==
                                              _appService.causeList![index]
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
                                color: causeController.text != ""
                                    ? AppColors.c4
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: TextField(
                                  controller: causeController,
                                  decoration: InputDecoration(
                                      hintText: "입력",
                                      hintStyle: TextStyle(
                                          color: Colors.black38,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18),
                                      border: InputBorder.none),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: causeController.text != ""
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.w600),
                                  onTap: () {
                                    setState(() {
                                      selectedCause = "";
                                    });
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      selectedCause = value;
                                    });
                                  },
                                ),
                              ),
                            );
                          }
                        },
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          InkWell(
                            onTap: () {
                              Get.back();
                              FocusScope.of(context).unfocus();
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.287,
                              height:
                                  MediaQuery.of(context).size.height * 0.125 -
                                      16,
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
                              _appService.selectedFault.value.cause =
                                  selectedCause;
                              if (selectedCause != "" &&
                                  !_appService.causeList!
                                      .contains(selectedCause)) {
                                _appService.causeList!.add(selectedCause);
                              }
                              _appService.isFaultSelected.value = false;
                              _appService.isFaultSelected.value = true;
                              FocusScope.of(context).unfocus();
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.287,
                              height:
                                  MediaQuery.of(context).size.height * 0.125 -
                                      16,
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
