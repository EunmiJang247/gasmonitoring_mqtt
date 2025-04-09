import 'package:safety_check/app/constant/constants.dart';
import 'package:safety_check/app/constant/gaps.dart';
import 'package:safety_check/app/modules/splash/controllers/splash_controller.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../constant/app_color.dart';

class UpdateScreen extends GetView<SplashController> {
  const UpdateScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Obx(() {
      return controller.needUpdate.value
          ? Scaffold(
              body: SafeArea(
                child: Container(
                  width: MediaQuery.of(context).size.width,
                  color: Colors.white,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Container(
                          margin: EdgeInsets.symmetric(
                              horizontal: 30.sp, vertical: 35.sp),
                          decoration: BoxDecoration(
                            color: AppColors.c4,
                            borderRadius: BorderRadius.circular(34),
                          ),
                          child: Center(
                            child: Image.asset(
                              'assets/images/main_logo.png',
                              width: 100.sp,
                              height: 100.sp,
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(right: 30.sp),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                '업데이트 알림',
                                style: TextStyle(
                                    fontFamily: "Pretendard",
                                    fontWeight: FontWeight.w800,
                                    fontSize: 24,
                                    color: Colors.black),
                              ),
                              Gaps.h24,
                              SizedBox(
                                width: 320.w,
                                child: const Center(
                                  child: Text(
                                    '더 편리한 사용을 위해 서비스 기능을 개선했어요.',
                                    style: TextStyle(
                                        fontFamily: "Pretendard",
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        color: Color(0xFF5F6262)),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                              SizedBox(
                                width: 320.w,
                                child: const Center(
                                  child: Text(
                                    '업데이트 버튼을 클릭해주세요.',
                                    style: TextStyle(
                                        fontFamily: "Pretendard",
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        color: Color(0xFF5F6262)),
                                  ),
                                ),
                              ),
                              Gaps.h24,
                              Container(
                                padding: EdgeInsets.all(10),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  color: const Color(0xFFEEEEEE),
                                ),
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Container(
                                      width: 320.w,
                                      margin: EdgeInsets.only(
                                          top: 10.h, left: 15.w),
                                      child: Text(
                                        controller.lastUpdateHistory.version
                                            .trim(),
                                        style: const TextStyle(
                                            fontFamily: "Pretendard",
                                            fontWeight: FontWeight.w700,
                                            fontSize: 14,
                                            color: Color(0xFF5F6262)),
                                      ),
                                    ),
                                    Gaps.h10,
                                    Padding(
                                      padding: EdgeInsets.only(left: 15.w),
                                      child: SizedBox(
                                        width: 320.w,
                                        height: 200.h,
                                        child: CupertinoScrollbar(
                                          child: SingleChildScrollView(
                                            child: Column(
                                              children: [
                                                for (var txt in controller
                                                    .lastUpdateHistory.history)
                                                  Row(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      const Text(
                                                        '•',
                                                        style: TextStyle(
                                                            fontFamily:
                                                                "Pretendard",
                                                            fontWeight:
                                                                FontWeight.w400,
                                                            fontSize: 14,
                                                            color: Color(
                                                                0xFF5F6262)),
                                                      ),
                                                      Gaps.w6,
                                                      Expanded(
                                                        child: Text(
                                                          txt,
                                                          style: const TextStyle(
                                                              fontFamily:
                                                                  "Pretendard",
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w400,
                                                              fontSize: 14,
                                                              height: 1.2,
                                                              color: Color(
                                                                  0xFF5F6262)),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Gaps.h100,
                    ],
                  ),
                ),
              ),
              floatingActionButton: Container(
                  height: 70.h,
                  width: 300.sp,
                  decoration: BoxDecoration(
                    color: const Color(0xFF0068B6),
                    borderRadius: BorderRadius.circular(28.0),
                  ),
                  child: CupertinoButton(
                    onPressed: () {
                      launchUrl(Uri.parse(updateUrl));
                      SystemNavigator.pop();
                    },
                    color: AppColors.c4,
                    borderRadius: BorderRadius.circular(15),
                    child: const Text(
                      '업데이트',
                      style: TextStyle(
                        fontFamily: "Pretendard",
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                  )),
              floatingActionButtonLocation:
                  FloatingActionButtonLocation.centerFloat,
            )
          : Container(
              child: Image.asset("assets/images/1007_601_Splash_screen.png"),
            ); /*Container(
              alignment: Alignment.center,
              color: const Color(0xFF0068B6),
              width: Get.size.width,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    '업데이트 확인중 ... ${controller.lastUpdateHistory.value!.version}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  Gaps.h36,
                  const CircularProgressIndicator(
                    color: Colors.white,
                  ),
                ],
              ),
            );*/
    });
  }
}
