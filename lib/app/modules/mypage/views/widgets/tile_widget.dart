import 'package:flutter/material.dart';
import 'package:meditation_friend/app/constant/app_color.dart';

class ProfileTileWidget extends StatelessWidget {
  const ProfileTileWidget({
    super.key,
    required this.title,
    this.onTap,
    required this.leading,
  });

  final String title;
  final void Function()? onTap;
  final IconData leading;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.kDark.withOpacity(0.3), // 원하는 색상으로 변경
          borderRadius: BorderRadius.circular(10), // 모서리 둥글게 (선택사항)
        ),
        child: ListTile(
          visualDensity: VisualDensity.compact,
          onTap: onTap,
          leading: Icon(leading, color: AppColors.kWhite),
          title: Text(title,
              style: TextStyle(
                fontSize: 14,
                color: AppColors.kWhite,
                fontWeight: FontWeight.w500,
              )),
        ),
      ),
    );
  }
}
