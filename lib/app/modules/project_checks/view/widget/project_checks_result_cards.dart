import 'package:flutter/cupertino.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:safety_check/app/data/models/12_building_safety_check.dart';
import 'package:safety_check/app/modules/project_checks/view/widget/photo_box.dart';

class ProjectChecksResultCards extends StatelessWidget {
  final BuildingSafetyCheck? data;
  const ProjectChecksResultCards({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.centerLeft,
          margin: EdgeInsets.only(bottom: 10.h),
          child: Text(
            '외벽마감재',
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 16,
            ),
          ),
        ),
        SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              PhotoBox(),
              PhotoBox(),
            ],
          ),
        )
      ],
    );
  }
}
