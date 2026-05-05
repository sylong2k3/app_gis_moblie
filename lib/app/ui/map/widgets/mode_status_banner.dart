import 'package:flutter/material.dart';
import 'package:app_core/domain/enums/drawing_mode.dart';

class ModeStatusBanner extends StatelessWidget {
  final DrawingMode currentDrawingMode;
  final double polygonAreaHa;
  final double measurementTotalKm;
  final double? routeDistanceKm;
  final double? routeDurationMinutes;
  final double? gpsDistanceKm;
  final String? gpsDurationText;

  const ModeStatusBanner({
    super.key,
    required this.currentDrawingMode,
    required this.polygonAreaHa,
    required this.measurementTotalKm,
    this.routeDistanceKm,
    this.routeDurationMinutes,
    this.gpsDistanceKm,
    this.gpsDurationText,
  });

  @override
  Widget build(BuildContext context) {
    String leftText;
    String rightText;

    switch (currentDrawingMode) {
      case DrawingMode.none:
        leftText = '';
        rightText = '';
        break;
      case DrawingMode.point:
        leftText = 'ĐANG GHIM ĐIỂM';
        rightText = 'Chạm để ghim';
        break;
      case DrawingMode.polygon:
        leftText = 'DIỆN TÍCH';
        rightText = '${polygonAreaHa.toStringAsFixed(2)} ha';
        break;
      case DrawingMode.gpsPolygon:
        leftText = 'VẼ LẠI ĐƯỜNG ĐI';
        final distanceText = '${(gpsDistanceKm ?? 0).toStringAsFixed(2)} km';
        final durationText = gpsDurationText ?? '0m 0s';
        rightText = '$distanceText • $durationText';
        break;
      case DrawingMode.measure:
        leftText = 'ĐO KHOẢNG CÁCH';
        rightText = '${measurementTotalKm.toStringAsFixed(2)} km';
        break;
      case DrawingMode.line:
        leftText = 'ĐƯỜNG';
        rightText = 'Chờ thao tác...';
        break;
      case DrawingMode.routing:
        leftText = 'TÌM ĐƯỜNG';
        if (routeDistanceKm != null && routeDistanceKm! > 0) {
          rightText =
              '${routeDistanceKm!.toStringAsFixed(1)} km • '
              '${routeDurationMinutes!.toStringAsFixed(0)} phút';
        } else {
          rightText = 'Chọn điểm đầu và cuối';
        }
        break;
    }

    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: Material(
        color: const Color(0xFF111827),
        elevation: 6,
        shadowColor: Colors.black.withAlpha(46),
        child: Container(
          height: 40,
          padding: const EdgeInsets.symmetric(horizontal: 14),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                leftText,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.3,
                  color: Color(0xFF34D399),
                ),
              ),
              const SizedBox(width: 10),
              Container(
                width: 1,
                height: 18,
                color: Colors.white.withAlpha(71),
              ),
              const SizedBox(width: 10),
              Text(
                rightText,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.2,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
