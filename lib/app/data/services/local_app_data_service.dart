// ignore_for_file: non_constant_identifier_names

import 'package:meditation_friend/app/data/models/00_user.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:meditation_friend/app/utils/log.dart';

import '../../utils/converter.dart';
import '../models/update_history.dart';

// 앱의 로컬 데이터베이스(Hive)를 통해 로그인 유저, 프로젝트, 설정 등을 저장하고 불러오는 로컬 캐시 서비스
// LocalAppDataService는 앱에서 자주 쓰이는 데이터들을 로컬에 저장하고 꺼내는 역할을 담당
// Hive라는 NoSQL DB를 기반으로 데이터를 저장함 → 네트워크 없이도 로컬 데이터 읽기 가능

// 전반적인 구조:
// [AppService] ↔ [LocalAppDataService] ↔ [Hive (로컬DB)]
// AppService는 로직을 담당하고,
// LocalAppDataService는 저장소 역할,
// Hive는 실제 데이터가 저장되는 DB

// LocalAppDataService는 Hive를 활용해 유저, 프로젝트, 마커 같은 앱 데이터를 로컬에 저장/관리하고,
// 오프라인 로그인 및 앱 상태 복원에 핵심적인 역할을 하는 전역 서비스야.

class LocalAppDataService extends GetxService {
  // GetxService로 선언되어 있어서 앱 전역에서 사용 가능
  // LocalAppDataService는 “앱의 로컬 캐시 계층”
  late Box<MeditationFriendUser> user_box;
  late Box<String?> setting_box;
  late Box<List> template_box;

  Future<LocalAppDataService> init() async {
    await Hive.initFlutter();
    Hive.registerAdapter(UpdateHistoryItemAdapter());
    Hive.registerAdapter(MeditationFriendUserAdapter());

    setting_box = await Hive.openBox<String?>('setting_box_1_0_0');
    user_box = await Hive.openBox('user_box_1_0_1');
    template_box = await Hive.openBox('template_box_1_0_1');

    return this;
  }

  Future<void> writeLastLoginUser(MeditationFriendUser userData) async {
    // 로그인 성공 시, Hive의 user_box에 유저 정보를 저장함
    await user_box.put('last_logged_in_user', userData);
  }

  MeditationFriendUser? getLastLoginUser() {
    // 저장된 유저 정보를 읽어와서 반환
    // 오프라인 로그인이나 자동 로그인 시 사용됨
    return user_box.get('last_logged_in_user');
  }

  Future<void> clearLastLoginUser() async {
    try {
      await user_box.delete('last_logged_in_user');
    } catch (e) {
      print('로그인 정보 삭제 실패: $e');
    }
  }

  Future<void> setConfigValue(String name, String value) async {
    // 설정값 저장 및 불러오기
    await setting_box.put(name, value);
  }

  String? getConfigValue(String name) {
    return setting_box.get(name);
  }

  Future<void> putLocationList(List<String> location_list) async {
    // 위치, 업데이트 기록 저장
    await template_box.put('location_list', location_list);
  }

  List<String>? getLocationList() {
    return template_box.get('location_list')?.cast<String>();
  }

  Future<void> putUpdateHistory(List<UpdateHistoryItem?> history_list) async {
    await template_box.put('update_history', history_list);
  }

  List<UpdateHistoryItem>? getUpdateHistory() {
    return template_box.get('update_history')?.cast<UpdateHistoryItem>();
  }

// 앱 방문 기록 저장 - 최초 실행 여부 체크에 사용
  Future<void> saveAppVisitState(bool visited) async {
    await setting_box.put('has_visited_before', visited.toString());
  }

// 앱 방문 기록 확인
  bool hasVisitedBefore() {
    final visitState = setting_box.get('has_visited_before');
    // 'true' 문자열이면 true 반환, 그 외에는 false 반환
    logInfo("visitState: ${visitState}");
    return visitState == 'true';
  }

  // 알람 설정 저장
  Future<void> saveAlarmSettings({
    required String alarmDays,
    required int alarmHour,
    required int alarmMinute,
  }) async {
    await setting_box.put('alarm_days', alarmDays.toString());
    await setting_box.put('alarm_hour', alarmHour.toString());
    await setting_box.put('alarm_minute', alarmMinute.toString());
  }

  // 알람 설정 불러오기
  Map<String, dynamic>? getAlarmSettings() {
    final daysString = setting_box.get('alarm_days');
    final hourString = setting_box.get('alarm_hour');
    final minuteString = setting_box.get('alarm_minute');

    if (daysString == null || hourString == null || minuteString == null) {
      return null; // 설정이 없으면 null 반환
    }

    return {
      'alarmDays': daysString.split(','),
      'alarmHour': int.tryParse(hourString) ?? 9,
      'alarmMinute': int.tryParse(minuteString) ?? 0,
    };
  }
}
