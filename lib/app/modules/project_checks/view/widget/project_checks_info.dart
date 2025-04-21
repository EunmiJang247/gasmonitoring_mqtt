import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safety_check/app/constant/constants.dart';
import 'package:safety_check/app/modules/project_checks/view/widget/photo_box.dart';

class ProjectChecksInfo extends StatelessWidget {
  final String? buildingName;
  final String? inspectorName;
  final String? inspectionDate;
  final String? type;

  const ProjectChecksInfo({
    super.key,
    this.buildingName,
    this.inspectorName,
    this.inspectionDate,
    this.type,
  });

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      Container(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(bottom: 10.h),
        child: Text(
          '점검자 : ${inspectorName}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      Container(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(bottom: 10.h),
        child: Text(
          '점검 일자 : ${inspectionDate}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      Container(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(bottom: 10.h),
        child: Text(
          '건물명 : ${buildingName}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      Container(
        alignment: Alignment.centerLeft,
        margin: EdgeInsets.only(bottom: 10.h),
        child: Text(
          '건물종류 : ${type}',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      )
    ]);
  }
}
