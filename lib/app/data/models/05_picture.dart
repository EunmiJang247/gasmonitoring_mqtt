// ignore_for_file: non_constant_identifier_names

import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:safety_check/app/constant/data_state.dart';

part '05_picture.g.dart';

@JsonSerializable() // JSON <-> 객체 자동 변환 지원
@HiveType(typeId: 5) // Hive에서 이 타입을 식별할 수 있도록 고유 ID를 부여
class CustomPicture {
  // Hive는 성능 때문에 필드 이름이 아니라 번호로 저장해./
  // 번호가 바뀌면 저장된 데이터와 매칭이 안 돼서 ❌ 문제 생길 수 있어!
  // 이 박스는 key-value 형태로 데이터를 저장해.
  // 이 Dart 클래스는 Hive와 json_serializable을 활용해서 로컬 DB 모델 + JSON 변환이 가능한 데이터 클래스를 만든 거야
  // Hive는 Flutter의 경량 Key-Value DB야. (SQLite 대체 가능)
  // @HiveType, @HiveField 어노테이션은 Hive가 이 객체를 박스에 저장할 수 있도록 구조화하는 용도야.
  @HiveField(0) // Hive는 성능 때문에 필드 이름이 아니라 번호로 저장해.
  String? seq;
  @HiveField(1)
  String? project_seq; // 어떤 프로젝트에 속한 사진인지
  @HiveField(2)
  String? drawing_seq;
  @HiveField(3)
  String? fault_seq;
  @HiveField(4)
  String? file_path; // 사진의 실제 경로
  @HiveField(5)
  String? file_name;
  @HiveField(6)
  String? file_size;
  @HiveField(7)
  String? thumb;
  @HiveField(8)
  String? no;
  @HiveField(9)
  String? kind; // 사진 종류 (전경, 결함, 기타 등)
  @HiveField(10)
  String? pid; // 	사진 고유 식별자 (primary key 역할)
  @HiveField(11)
  String? fid;
  @HiveField(12)
  CustomPicture? before_picture; // 	이전 상태의 사진을 참조 (비교용 등)
  @HiveField(13)
  String? location; // 촬영 위치 (예: 동, 층 등과 함께 사용됨)
  @HiveField(14)
  String? cate1_seq;
  @HiveField(15)
  List<String>? cate2_seq;
  @HiveField(16)
  String? cate1_name;
  @HiveField(17)
  String? cate2_name;
  @HiveField(18)
  String? width;
  @HiveField(19)
  String? length;
  @HiveField(20)
  String? dong;
  @HiveField(21)
  String? floor;
  @HiveField(22)
  String? floor_name;
  @HiveField(23)
  String? reg_time; // 	등록 시간 / 수정 시간
  @HiveField(24)
  String? update_time;
  @HiveField(25)
  int? state = DataState.NEW.index; // 현재 상태 (DataState.NEW, DELETED, etc)

  CustomPicture(
      {this.seq,
      this.project_seq,
      this.drawing_seq,
      this.fault_seq,
      this.file_path,
      this.file_name,
      this.file_size,
      this.thumb,
      this.no,
      this.kind,
      this.pid,
      this.fid,
      this.before_picture,
      this.location,
      this.cate1_seq,
      this.cate2_seq,
      this.cate1_name,
      this.cate2_name,
      this.width,
      this.length,
      this.dong,
      this.floor,
      this.floor_name,
      this.reg_time,
      this.update_time,
      this.state});

  // 서버에서 받은 JSON을 CustomPicture 객체로 변환
  factory CustomPicture.fromJson(Map<String, dynamic> json) =>
      _$CustomPictureFromJson(json);

  // 객체를 서버로 전송할 때 JSON으로 변환
  Map<String, dynamic> toJson() => _$CustomPictureToJson(this);
  //  이 부분은 build_runner로 자동 생성되므로, part '05_picture.g.dart';로 연결되고 flutter pub run build_runner build로 코드가 생성돼.
}
