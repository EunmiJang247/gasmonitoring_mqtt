// ignore_for_file: non_constant_identifier_names

import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:safety_check/app/data/models/01_project.dart';

part '06_engineer.g.dart';

@JsonSerializable()
@HiveType(typeId: 6)
class Engineer {
  @HiveField(0)
  String? seq;
  @HiveField(1)
  String? user_seq;
  @HiveField(2)
  String? license_no;
  @HiveField(3)
  String? grade;
  @HiveField(4)
  String? deleted;
  @HiveField(5)
  String? status;
  @HiveField(6)
  String? remark;
  @HiveField(7)
  String? engineer_seq;
  @HiveField(8)
  String? email;
  @HiveField(9)
  String? name;
  @HiveField(10)
  String? mobile;
  @HiveField(11)
  String? avatar_file;
  @HiveField(12)
  String? position_seq;
  @HiveField(13)
  String? position;
  @HiveField(14)
  String? license_seq;
  @HiveField(15)
  String? license_name;
  @HiveField(16)
  String? project_seq;
  @HiveField(17)
  List<Project>? project_list;

  Engineer({
  this.seq,
  this.user_seq,
  this.license_no,
  this.grade,
  this.deleted,
  this.status,
  this.remark,
  this.engineer_seq,
  this.email,
  this.name,
  this.mobile,
  this.avatar_file,
  this.position_seq,
  this.position,
  this.license_seq,
  this.license_name,
  this.project_seq,
  this.project_list,
  });

  factory Engineer.fromJson(Map<String, dynamic> json) => _$EngineerFromJson(json);
  Map<String, dynamic> toJson() => _$EngineerToJson(this);
}