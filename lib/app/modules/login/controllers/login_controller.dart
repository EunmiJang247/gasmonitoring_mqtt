import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:flutter_keyboard_visibility/flutter_keyboard_visibility.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../../../data/models/00_user.dart';
import '../../../data/services/app_service.dart';
import '../../../data/services/local_app_data_service.dart';
import '../../../routes/app_pages.dart';

class LoginController extends GetxController {
  final AppService appService;
  final LocalAppDataService _localAppDataService;
  final keyboardVisibilityController = KeyboardVisibilityController();

  LoginController({
    required this.appService,
    required LocalAppDataService localAppDataService,
  })  : _localAppDataService = localAppDataService;

  final List<Image> bannerImages = [
    Image.asset("assets/images/601_Image1.jpg", fit: BoxFit.fill,width: 345.w,),
    Image.asset("assets/images/601_Image2.jpg", fit: BoxFit.fill,width: 345.w,),
    Image.asset("assets/images/601_Image3.jpg", fit: BoxFit.fill,width: 345.w,),
  ];

  TextEditingController idController = TextEditingController();
  TextEditingController pwController = TextEditingController();
  RxBool isSaveLoginInfo = false.obs;
  RxBool isObscureText = true.obs;
  RxInt index = 0.obs;

  Rx<String?> errorText = Rx(null);


  @override
  void onInit() {
    User? savedUser = _localAppDataService.getLastLoginUser();
    String? savedPw = _localAppDataService.getConfigValue('saved_pw');
    if (savedUser != null && savedPw != null && savedPw != "") {
      idController.text = savedUser.email;
      pwController.text = savedPw;
      isSaveLoginInfo.value = true;
    }

    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  @override
  dispose() {
    idController.dispose();
    pwController.dispose();
    super.dispose();
  }

  setIsSaveInfo (bool value) {
    isSaveLoginInfo.value = value;
  }

  onTapLogin(BuildContext context, {required bool offline}) async {
    FocusScope.of(context).unfocus();
    if (EasyLoading.isShow) return;
    String? errorMsg = await appService.signIn(
      email: idController.text,
      password: pwController.text,
      offline: offline,
    );
    if (errorMsg != null) {
      errorText.value = errorMsg;
      await EasyLoading.showError(errorMsg);

      Timer(const Duration(seconds: 1), () {
        if (Get.isDialogOpen == true) Get.back();
      });
    } else {
      // 아이디/비밀번호 저장
      if (isSaveLoginInfo.value) {
        _localAppDataService.setConfigValue('saved_pw', pwController.text);
      } else {
        _localAppDataService.setConfigValue('saved_pw', "");
      }

      // 현장 목록으로 이동
      Get.offAllNamed(Routes.PROJECT_LIST);
    }
  }

  onTapFindPw () {
    Get.toNamed(Routes.FIND_PW);
  }
}
