// ignore_for_file: non_constant_identifier_names

import 'package:safety_check/app/data/models/00_user.dart';
import 'package:safety_check/app/data/models/07_fault_cate1_list.dart';

import '06_engineer.dart';
import '08_fault_cate2_list.dart';
import '10_elem_list.dart';

class SignInResponse {
  User? user;
  List<Engineer>? engineers;
  FaultCate1List? faultCate1List;
  FaultCate2List? faultCate2List;
  List<ElementList>? elements;
  List? locationList;
  List? causeList;
  List? statusList;
  SignInResponse({
    required this.user,
    required this.engineers,
    required this.faultCate1List,
    required this.faultCate2List,
    required this.elements,
    required this.locationList,
    required this.causeList,
    required this.statusList,
  });
}
