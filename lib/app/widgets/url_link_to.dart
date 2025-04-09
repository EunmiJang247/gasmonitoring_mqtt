import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UrlLinkTo extends StatelessWidget {
  final String url;
  final String? name;
  final TextStyle? style;

  const UrlLinkTo(this.url, {this.name, this.style, super.key});

  /// URL에서 파일 이름 추출
  String _extractFileName() {
    if (url.isEmpty) return '파일 없음';

    try {
      // URL이나 파일 경로에서 파일명만 추출
      String fileName = url;

      // 경로 구분자로 분리하고 마지막 부분(파일명) 가져오기
      if (fileName.contains('/')) {
        fileName = fileName.split('/').last;
      } else if (fileName.contains('\\')) {
        fileName = fileName.split('\\').last;
      }

      // 쿼리 파라미터 제거
      if (fileName.contains('?')) {
        fileName = fileName.split('?').first;
      }

      return fileName;
    } catch (e) {
      return url;
    }
  }

  /// URL 열기
  Future<void> _launchURL() async {
    if (url.isEmpty) return;

    final Uri uri = Uri.parse(url);
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        throw Exception('URL을 열 수 없습니다: $url');
      }
    } catch (e) {
      debugPrint('URL 열기 실패: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    if (url.isEmpty) {
      return Text('파일 없음', style: style);
    }

    final displayText = name ?? _extractFileName();

    return InkWell(
      onTap: _launchURL,
      child: Text(
        displayText,
        style: style?.copyWith(
              color: Colors.blue,
              decoration: TextDecoration.underline,
            ) ??
            TextStyle(
              color: Colors.blue.shade700,
              fontSize: 16,
            ),
      ),
    );
  }
}
