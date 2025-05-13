import 'package:flutter/material.dart';
import 'package:safety_check/app/constant/app_color.dart';

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
    return ListTile(
      visualDensity: VisualDensity.compact,
      onTap: onTap,
      leading: Icon(leading, color: AppColors.kGray),
      title: Text(title),
      trailing: const Icon(Icons.add_ic_call_outlined,
          size: 16, color: AppColors.kDark),
    );
  }
}
