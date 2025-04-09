// ignore_for_file: non_constant_identifier_names

import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:safety_check/app/constant/data_state.dart';

part '05_picture.g.dart';

@JsonSerializable()
@HiveType(typeId: 5)
class CustomPicture {
  @HiveField(0)
  String? seq;
  @HiveField(1)
  String? project_seq;
  @HiveField(2)
  String? drawing_seq;
  @HiveField(3)
  String? fault_seq;
  @HiveField(4)
  String? file_path;
  @HiveField(5)
  String? file_name;
  @HiveField(6)
  String? file_size;
  @HiveField(7)
  String? thumb;
  @HiveField(8)
  String? no;
  @HiveField(9)
  String? kind;
  @HiveField(10)
  String? pid;
  @HiveField(11)
  String? fid;
  @HiveField(12)
  CustomPicture? before_picture;
  @HiveField(13)
  String? location;
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
  String? reg_time;
  @HiveField(24)
  String? update_time;
  @HiveField(25)
  int? state = DataState.NEW.index;

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

  factory CustomPicture.fromJson(Map<String, dynamic> json) =>
      _$CustomPictureFromJson(json);
  Map<String, dynamic> toJson() => _$CustomPictureToJson(this);
}
