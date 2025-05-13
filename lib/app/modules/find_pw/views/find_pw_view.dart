import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

import 'package:get/get.dart';
import 'package:meditation_friend/app/constant/app_color.dart';

import '../../../constant/gaps.dart';
import '../controllers/find_pw_controller.dart';

class FindPwView extends GetView<FindPwController> {
  const FindPwView({super.key});
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
        appBar: AppBar(
          title: const Text(
            '비밀번호 찾기',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          backgroundColor: AppColors.c4,
          leading: IconButton(
            icon: const Icon(
              Icons.arrow_back_ios,
              color: Colors.white,
            ),
            onPressed: Get.back,
          ),
          centerTitle: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(32),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '이메일 주소를 입력하세요.\n비밀번호 재설정을 위한 이메일을 보내드리겠습니다.',
                  style: TextStyle(fontSize: 16),
                ),
                Gaps.h36,
                const Text(
                  '이메일',
                  style: TextStyle(fontSize: 20),
                ),
                Gaps.h12,
                TextField(
                  controller: controller.emailController,
                  keyboardType: TextInputType.emailAddress,
                ),
                Gaps.h36,
                SizedBox(
                  width: double.infinity,
                  height: 60.h,
                  child: Obx(
                    () => CupertinoButton(
                      color: AppColors.c4,
                      onPressed: controller.isActiveButton.value
                          ? controller.onTapConfirm
                          : null,
                      borderRadius: BorderRadius.circular(15),
                      child: Text(
                        '확인',
                        style: TextStyle(
                          fontFamily: "Pretendard",
                          fontWeight: FontWeight.w600,
                          fontSize: 18,
                          color: controller.isActiveButton.value
                              ? Colors.white
                              : Colors.black54,
                        ),
                      ),
                    ),
                    /*
                      FilledButton(
                        onPressed: controller.isActiveButton.value ? controller.onTapConfirm : null,
                        style: FilledButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                          backgroundColor: const Color(0xFF0068B6),
                        ),
                        child: const Text(
                          '확인',
                          style: TextStyle(
                            fontFamily: "Pretendard",
                            fontWeight: FontWeight.w600,
                            fontSize: 18,
                          ),
                        ),
                      ),
                    */
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
