// ignore_for_file: non_constant_identifier_names

import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part '10_elem_list.g.dart';

@JsonSerializable()
@HiveType(typeId: 10)
class ElementList {
  @HiveField(0)
  String? seq;
  @HiveField(1)
  String? name;
  @HiveField(2)
  String? order;
  @HiveField(3)
  String? reg_time;

  ElementList({
    this.seq,
    this.name,
    this.order,
    this.reg_time
  });


  factory ElementList.fromJson(Map<String, dynamic> json) => _$ElementListFromJson(json);
  Map<String, dynamic> toJson() => _$ElementListToJson(this);
}