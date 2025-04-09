// ignore_for_file: non_constant_identifier_names

import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:safety_check/app/data/models/fault_category.dart';

part '08_fault_cate2_list.g.dart';

@JsonSerializable()
@HiveType(typeId: 8)
class FaultCate2List {
  @HiveField(0)
  List<FaultCategory>? fault_cate2_list;

  FaultCate2List({
    this.fault_cate2_list
  });

  factory FaultCate2List.fromJson(Map<String, dynamic> json) => _$FaultCate2ListFromJson(json);
  Map<String, dynamic> toJson() => _$FaultCate2ListToJson(this);
}