import 'dart:io';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:safety_check/app/widgets/photo.dart';

class ImageDialog extends StatefulWidget {
  const ImageDialog({super.key, required this.source});
  final String source;

  @override
  State<ImageDialog> createState() => _ImageDialogState();
}

class _ImageDialogState extends State<ImageDialog> {
  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: GestureDetector(
        onTap: ()=>Get.back(),
        child: widget.source.isURL ?
          Photo(imageUrl: widget.source,)
            :
          Image.file(File(widget.source),fit: BoxFit.cover,),
      ),
    );
  }
}
