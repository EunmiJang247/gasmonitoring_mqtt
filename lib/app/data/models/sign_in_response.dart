// ignore_for_file: non_constant_identifier_names

import 'package:safety_check/app/data/models/00_user.dart';

class SignInResponse {
  User? user;
  List? locationList;
  List? statusList;
  SignInResponse({
    required this.user,
    required this.locationList,
    required this.statusList,
  });
}
