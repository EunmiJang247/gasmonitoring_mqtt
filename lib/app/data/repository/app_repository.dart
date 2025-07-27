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

  // 카카오 로그인
  Future<BaseResponse?> signInUsingKakao({
    required id,
    required fcmToken,
    required nickname,
    required profileImageUrl,
    required thumbnailImageUrl,
    connectedAt,
  }) async {
    BaseResponse? response;
    try {
      Map<String, dynamic> body = {
        "id": id,
        "fcmToken": fcmToken,
        "nickname": nickname,
        "profileImageUrl": profileImageUrl,
        "thumbnailImageUrl": thumbnailImageUrl,
        "connectedAt": connectedAt?.toIso8601String(),
      };
      response = await _appAPI.client.signInUsingKakao(body);
    } catch (err) {
      logError(err);
    }
    return response;
  }

  Future<BaseResponse?> saveAlarmSettings({
    required String alarmDays,
    required int alarmHour,
    required int alarmMinute,
  }) async {
    BaseResponse? response;
    try {
      Map<String, dynamic> body = {
        'alarmDays': jsonEncode(alarmDays),
        'alarmHour': alarmHour,
        'alarmMinute': alarmMinute,
      };

      final response = await _appAPI.client.saveAlarmSettings(body);
      logInfo('알람 설정 저장 성공: $response');
    } catch (e) {
      logError(e, des: 'saveAlarmSettings Error!');
      rethrow;
    }
    return response;
  }

  // 출석체크 하기
  Future<BaseResponse?> attendanceCheck() async {
    BaseResponse? response;
    try {
      response = await _appAPI.client.attendanceCheck();
      return response;
    } catch (err) {
      logError(err);
    }
    return response;
  }

  // 출석체크 날짜 가져오기
  Future<BaseResponse?> getAttendanceCheck() async {
    BaseResponse? response;
    try {
      response = await _appAPI.client.getAttendanceCheck();
      return response;
    } catch (err) {
      logError(err);
    }
    return response;
  }

  // 파이어베이스 토큰을 서버에 전송
  Future<String?> sendFirebaseToken({required String fcmToken}) async {
    try {
      final response = await _appAPI.client.sendFirebaseToken({
        'fcmToken': fcmToken,
      });

      logInfo('FCM fcmToken response: $response'); // 디버그용
    } catch (e) {
      // print('FCM 토큰 전송 중 에러: $e');
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
      logInfo(e);
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

  Future<BaseResponse?> getNotificationSettings() async {
    BaseResponse? response;
    try {
      BaseResponse? response = await _appAPI.client.getNotificationSettings();
      return response;
    } catch (e) {
      print("에러 났어요 ${e.toString()}");
      logError(e, des: 'getNotificationSettings Error!');
      rethrow;
    }
    return response;
  }
}
