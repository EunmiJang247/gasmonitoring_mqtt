// ignore_for_file: non_constant_identifier_names

import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part '11_drawing_memo.g.dart';

@JsonSerializable()
@HiveType(typeId: 11)
class DrawingMemo {
  @HiveField(0)
  String? seq;
  @HiveField(1)
  String? drawing_seq;
  @HiveField(2)
  String? pid;
  @HiveField(3)
  String? memo;
  @HiveField(4)
  String? x;
  @HiveField(5)
  String? y;

  DrawingMemo({
    this.seq,
    this.drawing_seq,
    this.pid,
    this.memo,
    this.x,
    this.y,
  });

  factory DrawingMemo.fromJson(Map<String, dynamic> json) =>
      _$DrawingMemoFromJson(json);
  Map<String, dynamic> toJson() => _$DrawingMemoToJson(this);
}
