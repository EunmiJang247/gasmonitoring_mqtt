import 'package:flutter/material.dart';
import 'package:safety_check/app/data/models/03_marker.dart';
import 'package:safety_check/app/data/models/04_fault.dart';

// 성능 최적화를 위한 핵심 헬퍼 함수들
class PerformanceHelpers {
  // 좌표 변환 캐시
  static final Map<String, Offset> _coordinateCache = {};

  // DB 좌표를 디바이스 좌표로 변환 (선택적 캐시 적용)
  static Offset convertDBtoDV(
      String? x, String? y, double drawingWidth, double drawingHeight,
      {bool useCache = true}) {
    if (x == null || y == null) return Offset.zero;

    // 이동 중에는 캐시를 사용하지 않음
    if (!useCache) {
      double rx = double.parse(x);
      double ry = double.parse(y);
      return Offset(drawingWidth * rx, drawingHeight * ry);
    }

    // 캐시 키 생성
    String cacheKey = '$x,$y,$drawingWidth,$drawingHeight';

    // 캐시에 있으면 반환
    if (_coordinateCache.containsKey(cacheKey)) {
      return _coordinateCache[cacheKey]!;
    }

    // 없으면 계산하고 캐시에 저장
    double rx = double.parse(x);
    double ry = double.parse(y);
    Offset result = Offset(drawingWidth * rx, drawingHeight * ry);

    _coordinateCache[cacheKey] = result;
    return result;
  }

  // 특정 항목의 캐시 무효화 (좌표가 변경될 때 호출)
  static void invalidateCache(
      String x, String y, double drawingWidth, double drawingHeight) {
    String cacheKey = '$x,$y,$drawingWidth,$drawingHeight';
    _coordinateCache.remove(cacheKey);
  }

  // 캐시 초기화 (화면 크기 변경 시 호출)
  static void clearCoordinateCache() {
    _coordinateCache.clear();
  }

  // 마커와 연관된 결함 목록 가져오기 (최적화)
  static List<Fault> getRelatedFaults(Marker marker) {
    return marker.fault_list
            ?.where((fault) => marker.mid == fault.mid)
            .toList() ??
        [];
  }
}
