import 'package:flutter/material.dart';

class MeditationTile extends StatelessWidget {
  final String title;
  final List<String> tags;
  final Color backgroundColor;
  final Color textColor;
  final Color tagColor;
  final Color playButtonColor;
  final bool transformTilt;

  const MeditationTile({
    super.key,
    required this.title,
    required this.tags,
    required this.backgroundColor,
    this.textColor = Colors.white,
    this.tagColor = Colors.white24,
    this.playButtonColor = Colors.white,
    this.transformTilt = false,
  });

  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: transformTilt ? -0.05 : 0.0, // 약간 기울어짐
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: backgroundColor,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    children: tags
                        .map((tag) => Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 10, vertical: 6),
                              decoration: BoxDecoration(
                                color: tagColor.withOpacity(0.2),
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                tag,
                                style: TextStyle(
                                  color: tagColor,
                                  fontSize: 12,
                                ),
                              ),
                            ))
                        .toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            CircleAvatar(
              radius: 20,
              backgroundColor: playButtonColor,
              child: Icon(
                Icons.play_arrow,
                color: backgroundColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
