// ignore_for_file: non_constant_identifier_names

import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';
import 'package:safety_check/app/data/models/fault_category.dart';

part '07_fault_cate1_list.g.dart';

@JsonSerializable()
@HiveType(typeId: 7)
class FaultCate1List {
  @HiveField(0)
  List<FaultCategory>? fault_cate1_list;

  FaultCate1List({
    this.fault_cate1_list
  });


  factory FaultCate1List.fromJson(Map<String, dynamic> json) => _$FaultCate1ListFromJson(json);
  Map<String, dynamic> toJson() => _$FaultCate1ListToJson(this);
}