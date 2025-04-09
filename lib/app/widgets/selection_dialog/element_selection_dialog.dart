import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:safety_check/app/data/models/10_elem_list.dart';
import 'package:safety_check/app/modules/drawing_detail/controllers/drawing_detail_controller.dart';

import '../../constant/app_color.dart';
import '../../data/models/04_fault.dart';
import '../../data/services/app_service.dart';

class ElementSelectionDialog extends StatefulWidget {
  const ElementSelectionDialog({super.key, this.fault});
  final Fault? fault;

  @override
  State<ElementSelectionDialog> createState() => _ElementSelectionDialogState();
}

class _ElementSelectionDialogState extends State<ElementSelectionDialog> {
  final AppService _appService = Get.find();
  TextEditingController elementController = TextEditingController();

  String selectedElement = "";

  String? get curElement => widget.fault?.elem;

  @override
  void initState() {
    super.initState();
    selectedElement = curElement ?? "";
    if (!(_appService.elements
            ?.map(
              (e) => e.name,
            )
            .contains(curElement) ??
        false)) {
      elementController.text = curElement ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.65,
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
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      GridView.builder(
                        physics: NeverScrollableScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: (_appService.elements?.length ?? 0) + 1,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            mainAxisExtent:
                                MediaQuery.of(context).size.height * 0.125),
                        itemBuilder: (context, index) {
                          if (index < _appService.elements!.length) {
                            return InkWell(
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                setState(() {
                                  if (selectedElement ==
                                      _appService.elements?[index].name) {
                                    selectedElement = "";
                                  } else {
                                    selectedElement =
                                        _appService.elements?[index].name ?? "";
                                    elementController.text = "";
                                  }
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                margin: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                                constraints: BoxConstraints(minWidth: 100),
                                decoration: BoxDecoration(
                                    color: selectedElement ==
                                            _appService.elements?[index].name
                                        ? AppColors.c4
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Center(
                                    child: AutoSizeText(
                                  _appService.elements?[index].name ?? "",
                                  style: TextStyle(
                                      fontFamily: "Pretendard",
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: selectedElement ==
                                              _appService.elements?[index].name
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
                                color: elementController.text != ""
                                    ? AppColors.c4
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: TextField(
                                  controller: elementController,
                                  decoration: InputDecoration(
                                      hintText: "입력",
                                      hintStyle: TextStyle(
                                          color: Colors.black38,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18),
                                      border: InputBorder.none),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: elementController.text != ""
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.w600),
                                  onTap: () {
                                    setState(() {
                                      selectedElement = "";
                                    });
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      selectedElement = value;
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
                              height:
                                  MediaQuery.of(context).size.height * 0.125 -
                                      16,
                              width: MediaQuery.of(context).size.width * 0.165,
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
                            onTap: () async {
                              DrawingDetailController drawingDetailController =
                                  Get.find();
                              _appService.selectedFault.value.elem =
                                  selectedElement;
                              if (selectedElement != "" &&
                                  !_appService.elements!
                                      .map(
                                        (e) => e.name,
                                      )
                                      .contains(selectedElement)) {
                                var newSeq = await _appService.addFaultContent(
                                    type: 3, name: selectedElement);
                                ElementList newElement = ElementList(
                                    name: selectedElement,
                                    seq: newSeq.toString());
                                _appService.elements!.add(newElement);
                              }
                              List<ElementList>? elementList =
                                  drawingDetailController.elements
                                      ?.where(
                                        (element) =>
                                            element.name == selectedElement,
                                      )
                                      .toList();
                              if (elementList != null &&
                                  elementList.isNotEmpty) {
                                _appService.selectedFault.value.elem_seq =
                                    elementList.first.seq;
                              } else {
                                _appService.selectedFault.value.elem_seq = null;
                              }
                              Get.back();
                              _appService.isFaultSelected.value = false;
                              _appService.isFaultSelected.value = true;
                              FocusScope.of(context).unfocus();
                            },
                            child: Container(
                              width: MediaQuery.of(context).size.width * 0.165,
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
