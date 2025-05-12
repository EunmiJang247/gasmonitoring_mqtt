// ignore_for_file: non_constant_identifier_names

import 'package:safety_check/app/data/models/00_user.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';

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
  late Box<User> user_box;
  late Box<String?> setting_box;
  late Box<List> template_box;
  late Box<List> project_box;
  late Box<List> drawing_box;
  late Box<List> fault_box;
  late Box<List> picture_box;
  late Box<List> engineer_box;
  late Box<List> fault_cate1_box;
  late Box<List> fault_cate2_box;

  @override
  Future<void> onInit() async {
    // Hive 초기화하고, 각 모델마다 Adapter 등록해서 직렬화 가능하게 설정
    await Hive.initFlutter();

    Hive.registerAdapter(UpdateHistoryItemAdapter());
    Hive.registerAdapter(UserAdapter());
    // 실제로 Box들을 열어서 읽고 쓸 수 있게 준비함

    setting_box = await Hive.openBox<String?>('setting_box_1_0_0');
    user_box = await Hive.openBox('user_box_1_0_1');
    template_box = await Hive.openBox('template_box_1_0_1');
    project_box = await Hive.openBox('project_box_1_0_1');
    fault_box = await Hive.openBox('fault_box_1_0_1');
    engineer_box = await Hive.openBox('engineer_box_1_0_0');
    fault_cate1_box = await Hive.openBox('fault_cate1_box_1_0_1');
    fault_cate2_box = await Hive.openBox('fault_cate2_box_1_0_1');

    super.onInit();
  }

  Future<void> writeLastLoginUser(User userData) async {
    // 로그인 성공 시, Hive의 user_box에 유저 정보를 저장함
    await user_box.put('last_logged_in_user', userData);
  }

  User? getLastLoginUser() {
    // 저장된 유저 정보를 읽어와서 반환
    // 오프라인 로그인이나 자동 로그인 시 사용됨
    return user_box.get('last_logged_in_user');
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
}
