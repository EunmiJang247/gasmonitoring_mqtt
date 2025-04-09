import 'dart:io';

import 'package:dio/dio.dart';
import 'package:dio/io.dart';
import 'package:flutter/cupertino.dart';
// import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:safety_check/app/constant/server.dart';
import 'package:safety_check/app/data/api/app_rest_api.dart';
import 'package:safety_check/app/utils/converter.dart';
import 'package:safety_check/app/utils/log.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:get/get.dart';

import '../../constant/app_color.dart';
import '../../constant/gaps.dart';
import '../../routes/app_pages.dart';
import '../../widgets/one_button_dialog.dart';

class AppAPI extends GetxService {
  late AppRestAPI client;
  final dio = Dio();
  String? cookie;
  String? session;
  String? device;

  Widget logoutNotice = OneButtonDialog(
    content: Column(
      children: [
        Text(
          "안내",
          style: TextStyle(
              fontFamily: "Pretendard",
              color: AppColors.c1,
              fontWeight: FontWeight.bold,
              fontSize: 22),
        ),
        Gaps.h16,
        Text(
          "세션이 만료되어 로그아웃합니다.",
          style: TextStyle(
            fontFamily: "Pretendard",
            fontSize: 18,
          ),
          textAlign: TextAlign.center,
        )
      ],
    ),
    yes: "확인",
    onYes: () => Get.offAllNamed(Routes.LOGIN),
  );

  @override
  void onInit() {
    dio.httpClientAdapter = IOHttpClientAdapter(
      createHttpClient: () {
        final HttpClient client =
            HttpClient(context: SecurityContext(withTrustedRoots: true));
        client.badCertificateCallback = (cert, host, port) => true;
        return client;
      },
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (
          RequestOptions options,
          RequestInterceptorHandler handler,
        ) async {
          options.headers['Content-Type'] = 'application/json; charset=utf-8';
          options.headers['Access-Key'] = getAccessKey();
          // session-id가 설정되어 있다면 요청 헤더에 추가
          if (cookie != null) {
            options.headers['cookie'] = cookie;
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          try {
            // 응답에서 Set-Cookie 헤더가 있는지 확인
            final setCookieHeader = response.headers['set-cookie'];
            if (setCookieHeader != null) {
              for (var cookieHeader in setCookieHeader) {
                if (cookieHeader.contains('ci_session')) {
                  session =
                      _extractSessionId(cookieHeader); // session-id 추출 및 저장
                }
                if (cookieHeader.contains('_device')) {
                  device = _extractDeviceId(cookieHeader); // session-id 추출 및 저장
                }
              }
              cookie = "ci_session=$session; _device=$device";
            }
            response.data = responseConverter(response.data);
          } catch (e) {
            final errorMessage = e.toString();
            if (errorMessage.contains("Access Denied")) {
              cookie = null;
              Get.dialog(logoutNotice, barrierDismissible: false);
            } else {
              logError(e,
                  des: 'InterceptorsWrapper.onResponse.responseConverter');
              response.data = null;
            }
          }

          handler.next(response);
        },
      ),
    );

    // 통신기록 응답보기
    // dio.interceptors.add(
    //   PrettyDioLogger(
    //       requestHeader: true,
    //       request: false,
    //       requestBody: true,
    //       responseHeader: true),
    // );

    if (dotenv.env['ENVIRONMENT'] == 'development') {
      client = AppRestAPI(dio, baseUrl: dotenv.env['DEV_BASE_URL']!);
    } else {
      client = AppRestAPI(dio, baseUrl: dotenv.env['PROD_BASE_URL']!);
    }

    super.onInit();
  }

  // session-id 추출 메서드
  String _extractSessionId(String cookie) {
    final sessionIdPattern = RegExp(r'ci_session=([^;]+)');
    final match = sessionIdPattern.firstMatch(cookie);
    return match != null ? match.group(1)! : '';
  }

  // session-id 추출 메서드
  String _extractDeviceId(String cookie) {
    final deviceIdPattern = RegExp(r'_device=([^;]+)');
    final match = deviceIdPattern.firstMatch(cookie);
    return match != null ? match.group(1)! : '';
  }
}
