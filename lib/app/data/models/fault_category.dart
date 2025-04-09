// ignore_for_file: non_constant_identifier_names

import 'package:json_annotation/json_annotation.dart';
// import 'package:safety_check/app/data/models/07_fault_cate1_list.dart';

part 'fault_category.g.dart';

@JsonSerializable()
class FaultCategory {
  String seq;
  String name;

  FaultCategory({required this.seq, required this.name});

  static Map<String, String> listToMap(List<FaultCategory> cateList) {
    Map<String, String> result = {};
    for (var cate in cateList) {
      result[cate.seq] = cate.name;
    }
    return result;
  }

  factory FaultCategory.fromJson(Map<String, dynamic> json) =>
      _$FaultCategoryFromJson(json);
  Map<String, dynamic> toJson() => _$FaultCategoryToJson(this);
}
