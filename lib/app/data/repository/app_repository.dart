import 'package:dio/dio.dart';
import 'package:meditation_friend/app/data/models/music.dart';

import '../../utils/log.dart';
import '../api/app_api.dart';
import '../models/base_response.dart';
import 'dart:convert';

// AppRepository 은 API 호출을 전담하는 계층

class AppRepository {
  // AppRepository는 Repository 패턴을 적용한 클래스
  // Service나 Controller와 API 또는 로컬 DB(Hive 등) 사이의 중간 다리 역할
  AppRepository({required AppAPI appAPI}) : _appAPI = appAPI;
  // 생성자에서 AppAPI를 주입받아 _appAPI 필드에 저장.
  final AppAPI _appAPI;

  // Map<String, dynamic> readAndroidBuildData() {
  //   return <String, dynamic>{
  //     'platformVersion': DeviceInformation.platformVersion,
  //     'apiLevel': DeviceInformation.apiLevel,
  //     'cpuName': DeviceInformation.cpuName,
  //     'deviceIMEINumber': DeviceInformation.deviceIMEINumber,
  //     'deviceManufacturer': DeviceInformation.deviceManufacturer,
  //     'deviceModel': DeviceInformation.deviceModel,
  //     'deviceName': DeviceInformation.deviceName,
  //     'hardware': DeviceInformation.hardware,
  //     'productName': DeviceInformation.productName,
  //   };
  // }

  // 카카오 로그인
  Future<BaseResponse?> signInUsingKakao({
    required id,
    required nickname,
    required profileImageUrl,
    required thumbnailImageUrl,
    connectedAt,
  }) async {
    //String sha1Pw = sha1Encode(password);
    BaseResponse? response;
    try {
      Map<String, dynamic> body = {
        "id": id,
        "nickname": nickname,
        "profileImageUrl": profileImageUrl,
        "thumbnailImageUrl": thumbnailImageUrl,
        "connectedAt": connectedAt?.toIso8601String(),
      };
      print("Request body: ${jsonEncode(body)}"); // Safe to print now
      response = await _appAPI.client.signInUsingKakao(body);
      print('갔어요!');
      logInfo(response);
      logInfo(response?.toJson());
    } catch (err) {
      print('에러: $err');
      logError(err);
    }
    return response;
  }

  // 파이어베이스 토큰을 서버에 전송
  Future<String?> sendFirebaseToken({required String fcmToken}) async {
    try {
      print('Sending FCM token: $fcmToken'); // 디버그용

      final response = await _appAPI.client.sendFirebaseToken({
        'fcmToken': fcmToken,
      });

      print('FCM fcmToken response: $response'); // 디버그용
      print(response?.result);
    } catch (e) {
      print('FCM 토큰 전송 중 에러: $e');
      rethrow;
    }
    return null;
  }

  // 파이어베이스 토큰을 서버에 전송
  Future<String?> sendAlarm() async {
    try {
      final response = await _appAPI.client.sendFirebaseAlarm();
    } catch (e) {
      print('FCM 토큰 전송 중 에러: $e');
      rethrow;
    }
    return null;
  }

  // 로그아웃
  Future<BaseResponse?> logOut() async {
    BaseResponse? response;
    try {
      response = await _appAPI.client.logOut();
    } catch (err) {
      logError(err, des: 'AppRepository.logOut()');
    }
    return response;
  }

  // 비밀번호 찾기
  Future<String?> findPw({
    required String email,
  }) async {
    String? result;
    try {
      Map<String, dynamic> body = {
        "email": email,
      };
      BaseResponse? response = await _appAPI.client.findPw(body);
      result = response?.result?.message;
    } catch (err) {
      logError(err, des: 'AppRepository.findPw(email:$email)');
    }
    return result;
  }

  // 음악리스트 불러오기
  Future<List<Music>?> searchMusicList() async {
    try {
      final response = await _appAPI.client.getMusicList();
      final data = response?.data;
      final musicListRaw = data['music_list'] as List<dynamic>;
      final musicList = musicListRaw
          .map((e) => Music.fromJson(e as Map<String, dynamic>))
          .toList();
      return musicList;
    } catch (err, stack) {
      logError(err, des: 'searchMusicList Error!');
      logError(stack);
      return null;
    }
  }
}
