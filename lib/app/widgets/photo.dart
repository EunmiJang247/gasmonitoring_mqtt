import 'dart:io';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:meditation_friend/app/utils/converter.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

class Photo extends StatelessWidget {
  final String? imageUrl;
  final BoxFit? boxFit;
  final double? width;
  final double? height;
  final IconData? icon;

  const Photo({
    super.key,
    this.imageUrl,
    this.boxFit,
    this.width,
    this.height,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    if (icon != null) {
      return Center(
        child: SizedBox(
          height: 106.6.h,
          child: Icon(icon, size: 50),
        ),
      );
    }

    if (imageUrl == null || imageUrl == '') {
      return Container(
        decoration: BoxDecoration(
          color: Colors.grey[200],
        ),
        child: Center(
          child: Icon(Icons.photo_outlined, size: 100, color: Colors.grey[400]),
        ),
      );
    }

    if (isFilePath(imageUrl)) {
      return Image.file(
        File(
          imageUrl!,
        ),
        width: width,
        height: height,
        fit: boxFit ?? BoxFit.cover,
        errorBuilder: (context, error, stackTrace) {
          return const Icon(Icons.delete_forever_outlined);
        },
      );
    }

    if (imageUrl != null) {
      bool isValidUrl = Uri.tryParse(imageUrl!)?.hasAbsolutePath ?? false;
      if (!isValidUrl) {
        return const Center(
          child: Icon(Icons.link_off, size: 60),
        );
      }
    }

    return CachedNetworkImage(
      width: width,
      height: height,
      imageUrl: imageUrl!,
      fit: boxFit ?? BoxFit.cover,
      progressIndicatorBuilder: (context, url, downloadProgress) {
        return Center(
          child: CircularProgressIndicator(value: downloadProgress.progress),
        );
      },
      errorWidget: (context, url, error) {
        return const Center(
          child: Icon(
            Icons.error_outline,
            size: 60,
          ),
        );
      },
    );
  }
}
