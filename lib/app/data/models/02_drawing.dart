// ignore_for_file: non_constant_identifier_names

import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:safety_check/app/data/models/11_drawing_memo.dart';

part '02_drawing.g.dart';

@JsonSerializable()
@HiveType(typeId: 2)
class Drawing {
  @HiveField(0)
  String? seq;
  @HiveField(1)
  String? project_seq;
  @HiveField(2)
  String? dong;
  @HiveField(3)
  String? floor;
  @HiveField(4)
  String? file_path;
  @HiveField(5)
  String? file_name;
  @HiveField(6)
  String? file_size;
  @HiveField(7)
  String? thumb;
  @HiveField(8)
  String? deleted;
  @HiveField(9)
  String? reg_time;
  @HiveField(10)
  String? update_time;
  @HiveField(11)
  String? marker_size;
  @HiveField(12)
  String? floor_name;
  @HiveField(13)
  String? name;
  @HiveField(14)
  List<DrawingMemo> memo_list;

  Drawing({
    this.seq,
    this.project_seq,
    this.dong,
    this.floor,
    this.file_path,
    this.file_name,
    this.file_size,
    this.thumb,
    this.deleted,
    this.reg_time,
    this.update_time,
    this.marker_size,
    this.floor_name,
    this.name,
    this.memo_list = const [],
  });

  factory Drawing.fromJson(Map<String, dynamic> json) =>
      _$DrawingFromJson(json);
  Map<String, dynamic> toJson() => _$DrawingToJson(this);
}
