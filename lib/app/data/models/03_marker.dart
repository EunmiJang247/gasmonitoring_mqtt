// ignore_for_file: non_constant_identifier_names

import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

import '04_fault.dart';

part '03_marker.g.dart';

@JsonSerializable()
@HiveType(typeId: 3)
class Marker {
  @HiveField(0)
  String? seq;
  @HiveField(1)
  String? drawing_seq;
  @HiveField(2)
  String? outline_color;
  @HiveField(3)
  String? foreground_color;
  @HiveField(4)
  String? x;
  @HiveField(5)
  String? y;
  @HiveField(6)
  String? no;
  @HiveField(7)
  String? live_tour_url;
  @HiveField(8)
  String? reg_time;
  @HiveField(9)
  String? update_time;
  @HiveField(10)
  String? deleted;
  @HiveField(11)
  List<Fault>? fault_list;
  @HiveField(12)
  int? fault_cnt;
  @HiveField(13)
  String? mid;
  @HiveField(14)
  String? project_seq;
  @HiveField(15)
  String? dong;
  @HiveField(16)
  String? floor;
  @HiveField(17)
  String? first_fault_seq;
  @HiveField(18)
  String? size;
  @HiveField(19)
  String? floor_name;

  Marker({
    this.seq,
    this.drawing_seq,
    this.outline_color,
    this.foreground_color,
    this.x,
    this.y,
    this.no,
    this.live_tour_url,
    this.reg_time,
    this.update_time,
    this.deleted,
    this.fault_list,
    this.fault_cnt,
    this.mid,
    this.project_seq,
    this.dong,
    this.floor,
    this.first_fault_seq,
    this.size,
    this.floor_name,
  });

  Marker copyWith({
    String? seq,
    String? drawing_seq,
    String? outline_color,
    String? foreground_color,
    String? x,
    String? y,
    String? no,
    String? live_tour_url,
    String? reg_time,
    String? update_time,
    String? deleted,
    List<Fault>? fault_list,
    int? fault_cnt,
    String? mid,
    String? project_seq,
    String? dong,
    String? floor,
    String? first_fault_seq,
    String? size,
    String? floor_name,
  }) {
    return Marker(
      seq: seq ?? this.seq,
      drawing_seq: drawing_seq ?? this.drawing_seq,
      outline_color: outline_color ?? this.outline_color,
      foreground_color: foreground_color ?? this.foreground_color,
      x: x ?? this.x,
      y: y ?? this.y,
      no: no ?? this.no,
      live_tour_url: live_tour_url ?? this.live_tour_url,
      reg_time: reg_time ?? this.reg_time,
      update_time: update_time ?? this.update_time,
      deleted: deleted ?? this.deleted,
      fault_list: fault_list ?? this.fault_list,
      fault_cnt: fault_cnt ?? this.fault_cnt,
      mid: mid ?? this.mid,
      project_seq: project_seq ?? this.project_seq,
      dong: dong ?? this.dong,
      floor: floor ?? this.floor,
      first_fault_seq: first_fault_seq ?? this.first_fault_seq,
      size: size ?? this.size,
      floor_name: floor_name ?? this.floor_name,
    );
  }

  factory Marker.fromJson(Map<String, dynamic> json) => _$MarkerFromJson(json);
  Map<String, dynamic> toJson() => _$MarkerToJson(this);
}
