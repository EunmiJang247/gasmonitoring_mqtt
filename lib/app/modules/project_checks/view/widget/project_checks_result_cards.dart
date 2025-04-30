import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:safety_check/app/data/models/site_check_form.dart';
import 'package:safety_check/app/modules/project_checks/view/widget/photo_check_row.dart';

class ProjectChecksResultCards extends StatelessWidget {
  final InspectionData? data;
  const ProjectChecksResultCards({super.key, this.data});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Container(
              alignment: Alignment.centerLeft,
              child: Text(
                data?.toJson()['caption'] ?? "",
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
              ),
            ),
            SizedBox(
              width: 8,
            ),
            TextButton(
              onPressed: () {
                //
              },
              child: const Text(
                "보수 사유",
                style: TextStyle(
                  fontSize: 12,
                  decoration: TextDecoration.underline,
                ),
              ),
            ),
          ],
        ),
        if (data?.children != null)
          ...data!.children.map((v) => PhotoCheckRow(data: v)),
      ],
    );
  }
}
