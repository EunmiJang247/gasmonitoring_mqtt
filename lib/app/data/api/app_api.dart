import 'dart:io';
// dart:io는 HTTP 클라이언트를 커스터마이징할 때 사용돼. 여기선 SSL 인증 무시 같은 설정할 때 사용돼

import 'package:dio/dio.dart';
// HTTP 요청을 실제로 처리하는 Dio 인스턴스
import 'package:dio/io.dart';
// Dio에서 HttpClientAdapter를 커스터마이징할 수 있게 해줘. SSL 우회 등을 설정할 때 사용
import 'package:flutter/cupertino.dart';
// iOS 스타일 위젯들을 쓸 수 있게 해주는 기본 Flutter 패키지
// import 'package:pretty_dio_logger/pretty_dio_logger.dart';
import 'package:meditation_friend/app/constant/server.dart';
// 서버 주소, 키 같은 상수값들을 정의한 파일
import 'package:meditation_friend/app/data/api/app_rest_api.dart';
// 실제 API 메서드들을 정의해둔 Dio 래퍼 클래스.
import 'package:meditation_friend/app/utils/log.dart';
// 에러 로그 찍는 유틸.
import 'package:flutter_dotenv/flutter_dotenv.dart';
// .env 환경변수 파일을 읽기 위한 패키지. dev/prod 서버 분기 처리할 때 유용.
import 'package:get/get.dart';
// GetX의 핵심 패키지. 상태관리, 라우팅, 의존성 주입, 서비스 관리 등 다양한 기능을 제공.

import '../../constant/app_color.dart';
import '../../constant/gaps.dart';
import '../../routes/app_pages.dart';
import '../../widgets/one_button_dialog.dart';
// 스타일 상수, 간격 상수, 라우트 설정, 커스텀 다이얼로그 위젯 등 UI 관련 의존성들.

class AppAPI extends GetxService {
  // GetxService를 상속한 클래스. 앱 실행 시 딱 한 번 생성되어 주입되며 앱 전역에서 공유되는 서비스 객체
  late AppRestAPI client; // 	Dio를 래핑해서 API 메서드들을 명확히 정의해둔 추상화 객체
  final dio = Dio();

  // 세션 유지를 위한 헤더 관리 필드
  String? cookie;
  String? session;
  String? device;
  // 서버에서 발급된 쿠키에서 ci_session과 _device 값을 저장해 요청마다 포함시킬 수 있도록 관리

  // 세션 만료 시 사용자에게 보여줄 다이얼로그
  Widget logoutNotice = OneButtonDialog(
    // 세션이 만료되었을 때 사용자에게 보여줄 커스텀 다이얼로그
    // 확인 누르면 로그인 화면으로 이동.
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

  String? extractCookieValue(String rawCookie, String key) {
    try {
      final cookies = rawCookie.split(';');
      for (var cookie in cookies) {
        if (cookie.trim().startsWith('$key=')) {
          return cookie.trim().substring('$key='.length);
        }
      }
    } catch (e) {
      print('쿠키 파싱 오류: $e');
    }
    return null;
  }

  @override
  void onInit() {
    // GetxService가 초기화될 때 호출되는 메서드
    // Dio 세팅, 인터셉터 구성, API 엔드포인트 선택
    dio.httpClientAdapter = IOHttpClientAdapter(
      // SSL 인증서 무시 설정 (badCertificateCallback)
      // 로컬 개발 환경에서 테스트 서버 인증서가 self-signed일 때 필요
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
          // 요청 전 헤더에 필요한 정보 삽입하는 과정이 포함됨
          options.headers['Content-Type'] = 'application/json; charset=utf-8';
          options.headers['Access-Key'] = getAccessKey();

          if (cookie != null) {
            // logInfo("cookie는요 ${cookie}");
            options.headers['cookie'] = cookie;
            final csrf = extractCookieValue(cookie!, 'csrftoken');
            if (csrf != null) {
              options.headers['X-CSRFToken'] = csrf;
            }
          }
          handler.next(options);
        },
        onResponse: (response, handler) {
          try {
            String? sessionId;
            String? csrfToken;

            final setCookieHeader = response.headers['set-cookie'];
            if (setCookieHeader != null) {
              for (String cookieHeader in setCookieHeader) {
                if (cookieHeader.contains('sessionid')) {
                  sessionId = extractCookieValue(cookieHeader, 'sessionid');
                }
                if (cookieHeader.contains('csrftoken')) {
                  csrfToken = extractCookieValue(cookieHeader, 'csrftoken');
                }
              }

              // logInfo('🟢 추출된 sessionId: $sessionId');
              // logInfo('🟡 추출된 csrfToken: $csrfToken');
              // ✅ 요청에 사용될 쿠키 문자열 구성하여 저장
              if (sessionId != null && csrfToken != null) {
                cookie = "sessionid=$sessionId; csrftoken=$csrfToken";
              }
            }
          } catch (e) {
            final errorMessage = e.toString();
            if (errorMessage.contains("Access Denied")) {
              // 만약 "Access Denied" 오류가 발생하면 세션 만료로 간주하고 로그아웃 다이얼로그를 띄움
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

    if (dotenv.env['ENVIRONMENT'] == 'development') {
      // .env 파일을 기반으로 dev / prod 서버를 자동으로 분기
      client = AppRestAPI(dio, baseUrl: dotenv.env['DEV_BASE_URL']!);
    } else {
      client = AppRestAPI(dio, baseUrl: dotenv.env['PROD_BASE_URL']!);
    }

    super.onInit();
  }
}
