import 'package:auto_size_text/auto_size_text.dart';
import 'package:flutter/material.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:get/get.dart';
import 'package:safety_check/app/data/models/05_picture.dart';
import 'package:safety_check/app/modules/check_image/controllers/check_image_controller.dart';

import '../../constant/app_color.dart';
import '../../data/models/04_fault.dart';
import '../../data/services/app_service.dart';

class LocationSelectionDialog extends StatefulWidget {
  const LocationSelectionDialog({super.key, this.picture, this.fault});
  final CustomPicture? picture;
  final Fault? fault;

  @override
  State<LocationSelectionDialog> createState() =>
      _LocationSelectionDialogState();
}

class _LocationSelectionDialogState extends State<LocationSelectionDialog> {
  final AppService _appService = Get.find();
  TextEditingController locationController = TextEditingController();

  String selectedLocation = "";

  bool get isPicture => widget.picture != null;
  String? get curLocation =>
      isPicture ? widget.picture?.location : widget.fault?.location;

  @override
  void initState() {
    super.initState();
    selectedLocation = curLocation ?? "";
    if (!(_appService.locationList?.contains(curLocation) ?? false)) {
      locationController.text = curLocation ?? "";
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: Container(
        height: MediaQuery.of(context).size.height * 0.8,
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
                        itemCount: (_appService.locationList?.length ?? 0) + 1,
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 5,
                            mainAxisExtent:
                                MediaQuery.of(context).size.height * 0.125),
                        itemBuilder: (context, index) {
                          if (index < _appService.locationList!.length) {
                            return InkWell(
                              onTap: () {
                                FocusScope.of(context).unfocus();
                                setState(() {
                                  if (selectedLocation ==
                                      _appService.locationList?[index]) {
                                    selectedLocation = "";
                                  } else {
                                    selectedLocation =
                                        _appService.locationList?[index];
                                    locationController.text = "";
                                  }
                                });
                              },
                              child: Container(
                                padding: EdgeInsets.symmetric(horizontal: 10),
                                margin: EdgeInsets.symmetric(
                                    horizontal: 8, vertical: 8),
                                constraints: BoxConstraints(minWidth: 100),
                                decoration: BoxDecoration(
                                    color: selectedLocation ==
                                            _appService.locationList?[index]
                                        ? AppColors.c4
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(8)),
                                child: Center(
                                    child: AutoSizeText(
                                  _appService.locationList?[index] ?? "",
                                  style: TextStyle(
                                      fontFamily: "Pretendard",
                                      fontSize: 20,
                                      fontWeight: FontWeight.w600,
                                      color: selectedLocation ==
                                              _appService.locationList?[index]
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
                                color: locationController.text != ""
                                    ? AppColors.c4
                                    : Colors.white,
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Center(
                                child: TextField(
                                  controller: locationController,
                                  decoration: InputDecoration(
                                      hintText: "입력",
                                      hintStyle: TextStyle(
                                          color: Colors.black38,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 18),
                                      border: InputBorder.none),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      color: locationController.text != ""
                                          ? Colors.white
                                          : Colors.black,
                                      fontWeight: FontWeight.w600),
                                  onTap: () {
                                    setState(() {
                                      selectedLocation = "";
                                    });
                                  },
                                  onChanged: (value) {
                                    setState(() {
                                      selectedLocation = value;
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
                                width:
                                    MediaQuery.of(context).size.width * 0.165,
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
                                if (isPicture) {
                                  CheckImageController checkImageController =
                                      Get.find();
                                  checkImageController
                                      .changeLocation(selectedLocation);
                                } else {
                                  _appService.selectedFault.value.location =
                                      selectedLocation;
                                  _appService.isFaultSelected.value = false;
                                  _appService.isFaultSelected.value = true;
                                }
                                if (selectedLocation != "" &&
                                    !_appService.locationList!
                                        .contains(selectedLocation)) {
                                  _appService.locationList!
                                      .add(selectedLocation);
                                }
                                FocusScope.of(context).unfocus();
                              },
                              child: Container(
                                width:
                                    MediaQuery.of(context).size.width * 0.165,
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
