import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PhotoBox extends StatelessWidget {
  const PhotoBox({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text('정면'),
        Container(
          width: 150,
          height: 150,
          decoration: BoxDecoration(
            color: Colors.grey[200],
            borderRadius: BorderRadius.circular(8),
          ),
          child: Center(
            child:
                Icon(Icons.photo_outlined, size: 100, color: Colors.grey[400]),
          ),
        ),
      ],
    );
  }
}
