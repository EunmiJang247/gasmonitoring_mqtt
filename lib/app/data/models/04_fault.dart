// ignore_for_file: non_constant_identifier_names
// 경고 무시하는 설정

import 'package:hive/hive.dart'; // Hive: 로컬 DB
import 'package:json_annotation/json_annotation.dart'; // json_annotation: JSON 자동 직렬화용
import '05_picture.dart'; // 관련된 CustomPicture 클래스 정의 파일

part '04_fault.g.dart'; // build_runner로 자동 생성되는 serialization 코드가 들어갈 파일

// Hive + JSON 직렬화를 활용해 Fault라는 모델을 정의한 코드
@JsonSerializable() // JSON → 객체 / 객체 → JSON 변환을 자동화해주는 패키지
@HiveType(typeId: 4) // Hive 저장용. 고유 ID가 4인 테이블처럼 사용됨.
class Fault {
  // 각 필드에 고유 숫자 인덱스를 붙여서 Hive에서 직렬화 시 사용.
  // 총 37개의 필드가 있고, 건물의 결함(Fault)을 정의하고 있어.
  // (위치, 크기, 구조 상태, 사진 정보 등등…)
  @HiveField(0)
  String? seq; // 고유한 ID
  @HiveField(1)
  String? marker_seq;
  @HiveField(2)
  String? user_seq;
  @HiveField(3)
  String? location;
  @HiveField(4)
  String? elem_seq;
  @HiveField(5)
  String? cate1_seq;
  @HiveField(6)
  String? width;
  @HiveField(7)
  String? length;
  @HiveField(8)
  String? qty;
  @HiveField(9)
  String? structure;
  @HiveField(10)
  String? status;
  @HiveField(11)
  String? ing_yn;
  @HiveField(12)
  String? group_fid;
  @HiveField(13)
  String? deleted;
  @HiveField(14)
  String? x;
  @HiveField(15)
  String? y;
  @HiveField(16)
  String? color;
  @HiveField(17)
  String? cause;
  @HiveField(18)
  String? cloned;
  @HiveField(19)
  String? fid;
  @HiveField(20)
  String? reg_time;
  @HiveField(21)
  String? update_time;
  @HiveField(22)
  String? user_name;
  @HiveField(23)
  String? elem;
  @HiveField(24)
  String? mid;
  @HiveField(25)
  String? marker_no;
  @HiveField(26)
  String? drawing_seq;
  @HiveField(27)
  String? project_seq;
  @HiveField(28)
  String? dong;
  @HiveField(29)
  String? floor;
  @HiveField(30)
  String? cate1_name;
  @HiveField(31)
  String? cate2;
  @HiveField(32)
  String? cate2_name;
  @HiveField(33)
  String? pic_no;
  @HiveField(34)
  String? note;
  @HiveField(35)
  List<CustomPicture>? picture_list;
  @HiveField(36)
  String? floor_name;

  Fault({
    this.seq,
    this.marker_seq,
    this.user_seq,
    this.location,
    this.elem_seq,
    this.cate1_seq,
    this.width,
    this.length,
    this.qty,
    this.structure,
    this.status,
    this.ing_yn,
    this.group_fid,
    this.deleted,
    this.x,
    this.y,
    this.color,
    this.cause,
    this.cloned,
    this.fid,
    this.reg_time,
    this.update_time,
    this.user_name,
    this.elem,
    this.mid,
    this.marker_no,
    this.drawing_seq,
    this.project_seq,
    this.dong,
    this.floor,
    this.cate1_name,
    this.cate2,
    this.cate2_name,
    this.pic_no,
    this.note,
    this.picture_list,
    this.floor_name,
  });

  // copyWoPic 메소드
  // picture_list만 제외한 복사본을 만들고 싶을 때 사용.
  // ?? this.seq는 인자가 null이면 기존 값 유지.
  Fault copyWoPic({
    String? seq,
    String? marker_seq,
    String? user_seq,
    String? location,
    String? elem_seq,
    String? cate1_seq,
    String? width,
    String? length,
    String? qty,
    String? structure,
    String? status,
    String? deleted,
    String? x,
    String? y,
    String? color,
    String? cause,
    String? cloned,
    String? reg_time,
    String? update_time,
    String? user_name,
    String? elem,
    String? mid,
    String? marker_no,
    String? drawing_seq,
    String? project_seq,
    String? dong,
    String? floor,
    String? cate1_name,
    String? cate2,
    String? cate2_name,
    String? ing_yn,
    String? group_fid,
    String? floor_name,
  }) {
    return Fault(
      seq: seq ?? this.seq,
      marker_seq: marker_seq ?? this.marker_seq,
      user_seq: user_seq ?? this.user_seq,
      location: location ?? this.location,
      elem_seq: elem_seq ?? this.elem_seq,
      cate1_seq: cate1_seq ?? this.cate1_seq,
      width: width ?? this.width,
      length: length ?? this.length,
      qty: qty ?? this.qty,
      structure: structure ?? this.structure,
      status: status ?? this.status,
      deleted: deleted ?? this.deleted,
      x: x ?? this.x,
      y: y ?? this.y,
      color: color ?? this.color,
      cause: cause ?? this.cause,
      cloned: cloned ?? this.cloned,
      reg_time: reg_time ?? this.reg_time,
      update_time: update_time ?? this.update_time,
      user_name: user_name ?? this.user_name,
      elem: elem ?? this.elem,
      mid: mid ?? this.mid,
      marker_no: marker_no ?? this.marker_no,
      drawing_seq: drawing_seq ?? this.drawing_seq,
      project_seq: project_seq ?? this.project_seq,
      dong: dong ?? this.dong,
      floor: floor ?? this.floor,
      cate1_name: cate1_name ?? this.cate1_name,
      cate2: cate2 ?? this.cate2,
      cate2_name: cate2_name ?? this.cate2_name,
      ing_yn: ing_yn ?? this.ing_yn,
      group_fid: group_fid ?? this.group_fid,
      floor_name: floor_name ?? this.floor_name,
    );
  }

  // copyWith 메소드
  // 전체 복사하면서 선택적으로 필드를 수정할 수 있는 메소드.
  // 불변성을 지키기 위한 Dart 스타일.
  Fault copyWith({
    String? seq,
    String? marker_seq,
    String? user_seq,
    String? location,
    String? elem_seq,
    String? cate1_seq,
    String? width,
    String? length,
    String? qty,
    String? structure,
    String? status,
    String? deleted,
    String? x,
    String? y,
    String? color,
    String? cause,
    String? cloned,
    String? fid,
    String? reg_time,
    String? update_time,
    String? user_name,
    String? elem,
    String? mid,
    String? marker_no,
    String? drawing_seq,
    String? project_seq,
    String? dong,
    String? floor,
    String? cate1_name,
    String? cate2,
    String? cate2_name,
    String? pic_no,
    String? ing_yn,
    String? group_fid,
    String? note,
    List<CustomPicture>? picture_list,
    String? floor_name,
  }) {
    return Fault(
      seq: seq ?? this.seq,
      marker_seq: marker_seq ?? this.marker_seq,
      user_seq: user_seq ?? this.user_seq,
      location: location ?? this.location,
      elem_seq: elem_seq ?? this.elem_seq,
      cate1_seq: cate1_seq ?? this.cate1_seq,
      width: width ?? this.width,
      length: length ?? this.length,
      qty: qty ?? this.qty,
      structure: structure ?? this.structure,
      status: status ?? this.status,
      deleted: deleted ?? this.deleted,
      x: x ?? this.x,
      y: y ?? this.y,
      color: color ?? this.color,
      cause: cause ?? this.cause,
      cloned: cloned ?? this.cloned,
      fid: fid ?? this.fid,
      reg_time: reg_time ?? this.reg_time,
      update_time: update_time ?? this.update_time,
      user_name: user_name ?? this.user_name,
      elem: elem ?? this.elem,
      mid: mid ?? this.mid,
      marker_no: marker_no ?? this.marker_no,
      drawing_seq: drawing_seq ?? this.drawing_seq,
      project_seq: project_seq ?? this.project_seq,
      dong: dong ?? this.dong,
      floor: floor ?? this.floor,
      cate1_name: cate1_name ?? this.cate1_name,
      cate2: cate2 ?? this.cate2,
      cate2_name: cate2_name ?? this.cate2_name,
      pic_no: pic_no ?? this.pic_no,
      ing_yn: ing_yn ?? this.ing_yn,
      group_fid: group_fid ?? this.group_fid,
      note: note ?? this.note,
      picture_list: picture_list ?? this.picture_list,
      floor_name: floor_name ?? this.floor_name,
    );
  }

  // 두 개의 Fault 객체가 동일한지 비교하는 메소드.
  // isEditingFault가 true면 더 많은 필드를 비교하고, false면 비교 범위를 줄임.
  // 모두 다르면 true, 하나라도 다르면 false
  bool isSame(Fault compareObj, {required bool isEditingFault}) {
    if (isEditingFault && compareObj.fid != fid) {
      return false;
    } else if (isEditingFault && compareObj.marker_seq != marker_seq) {
      return false;
    } else if (compareObj.location != location) {
      return false;
    } else if (compareObj.elem_seq != elem_seq) {
      return false;
    } else if (compareObj.cate1_seq != cate1_seq) {
      return false;
    } else if (compareObj.width != width) {
      return false;
    } else if (compareObj.length != length) {
      return false;
    } else if (compareObj.qty != qty) {
      return false;
    } else if (compareObj.structure != structure) {
      return false;
    } else if (compareObj.status != status) {
      return false;
    } else if (compareObj.deleted != deleted) {
      return false;
    } else if (isEditingFault && compareObj.x != x) {
      return false;
    } else if (isEditingFault && compareObj.y != y) {
      return false;
    } else if (isEditingFault && compareObj.color != color) {
      return false;
    } else if (isEditingFault && compareObj.cause != cause) {
      return false;
    } else if (compareObj.cloned != cloned) {
      return false;
    } else if (isEditingFault && compareObj.reg_time != reg_time) {
      return false;
    } else if (isEditingFault && compareObj.update_time != update_time) {
      return false;
    } else if (isEditingFault && compareObj.user_name != user_name) {
      return false;
    } else if (compareObj.elem != elem) {
      return false;
    } else if (isEditingFault && compareObj.mid != mid) {
      return false;
    } else if (compareObj.marker_no != marker_no) {
      return false;
    } else if (compareObj.drawing_seq != drawing_seq) {
      return false;
    } else if (compareObj.project_seq != project_seq) {
      return false;
    } else if (compareObj.dong != dong) {
      return false;
    } else if (compareObj.floor != floor) {
      return false;
    } else if (compareObj.cate1_name != cate1_name) {
      return false;
    } else if (compareObj.cate2 != cate2) {
      return false;
    } else if (compareObj.cate2_name != cate2_name) {
      return false;
    } else if (compareObj.floor_name != floor_name) {
      return false;
    } else if (compareObj.ing_yn != ing_yn) {
      return false;
    } else if (isEditingFault && compareObj.note != note) {
      return false;
    } else if (isEditingFault && compareObj.group_fid != group_fid) {
      return false;
    } else {
      return true;
    }
  }

  factory Fault.fromJson(Map<String, dynamic> json) => _$FaultFromJson(json);
  Map<String, dynamic> toJson() => _$FaultToJson(this);
  // json_serializable 패키지가 자동으로 구현해주는 JSON ↔ 객체 변환 함수
  // _04_fault.g.dart 파일에 실제 구현이 들어감
}
