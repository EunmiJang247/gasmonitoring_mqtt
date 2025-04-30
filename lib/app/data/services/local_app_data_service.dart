// ignore_for_file: non_constant_identifier_names

import 'package:safety_check/app/data/models/00_user.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:safety_check/app/data/models/02_drawing.dart';
import 'package:safety_check/app/data/models/03_marker.dart';
import 'package:safety_check/app/data/models/04_fault.dart';
// import 'package:safety_check/app/data/models/05_picture.dart';
import 'package:safety_check/app/data/models/06_engineer.dart';
import 'package:safety_check/app/data/models/07_fault_cate1_list.dart';
import 'package:safety_check/app/data/models/08_fault_cate2_list.dart';
import 'package:safety_check/app/data/models/11_drawing_memo.dart';

import '../../utils/converter.dart';
import '../models/01_project.dart';
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
  late Box<Marker> marker_box;
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
    Hive.registerAdapter(ProjectAdapter());
    Hive.registerAdapter(DrawingAdapter());
    Hive.registerAdapter(MarkerAdapter());
    Hive.registerAdapter(FaultAdapter());
    Hive.registerAdapter(EngineerAdapter());
    Hive.registerAdapter(FaultCate1ListAdapter());
    Hive.registerAdapter(FaultCate2ListAdapter());
    Hive.registerAdapter(DrawingMemoAdapter());
    // 실제로 Box들을 열어서 읽고 쓸 수 있게 준비함

    setting_box = await Hive.openBox<String?>('setting_box_1_0_0');
    user_box = await Hive.openBox('user_box_1_0_1');
    template_box = await Hive.openBox('template_box_1_0_1');
    project_box = await Hive.openBox('project_box_1_0_1');
    marker_box = await Hive.openBox('marker_box_1_0_1');
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

  Future<void> putProject(String user_seq, Project prj) async {
    // 프로젝트 저장 및 불러오기
    List<Project> previousProjects = getProjectList(user_seq);
    int? index = previousProjects
        .indexWhere((element) => isSameValue(element.seq, prj.seq));
    if (index != -1) {
      previousProjects[index] = prj;
    } else {
      previousProjects.add(prj);
    }
    await project_box.put(user_seq, previousProjects);
  }

  List<Project> getProjectList(String user_seq) {
    return (project_box.get(user_seq) ?? []).cast<Project>();
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

  Future<void> putMarker(Marker marker) async {
    // 마커(mid 기준)를 저장하고, 전체 리스트를 반환하는 getter도 제공
    await marker_box.put(marker.mid, marker);
  }

  List<Marker> get MarkerList => marker_box.values.cast<Marker>().toList();
}
// => 인터넷 없어도 오프라인 로그인 처리 가능

// Hive.registerAdapter()는 왜 필요할까?

// Hive는 Key-Value 기반 DB지만,
// 커스텀 클래스(예: User, Project)는 기본적으로 저장할 수 없어.
// 이유는 Hive는 내부적으로 바이너리 형태로 데이터를 저장함
// 그래서 Dart 객체를 → 바이너리로 바꿔주는 코드가 필요함
// 이걸 직렬화(serialize)라고 한다
// 그래서 필요한 게 TypeAdapter
// Hive.registerAdapter(UserAdapter())는 Hive에게
// “이 User라는 모델을 저장/읽을 때 어떻게 직렬화할지 알려줄게”라고 등록하는 작업이야.

// user.g.dart는 UserAdapter 클래스가 정의되어 있는 파일이 user.g.dart이다