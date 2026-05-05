import 'package:app_core/domain/enums/drawing_mode.dart';
import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'dart:math' as math;

class MapToolsPanel extends StatefulWidget {
  final MapboxMap? mapboxMap;
  final VoidCallback onClose;

  const MapToolsPanel({
    super.key,
    required this.mapboxMap,
    required this.onClose,
  });

  @override
  State<MapToolsPanel> createState() => _MapToolsPanelState();
}

class _MapToolsPanelState extends State<MapToolsPanel> {
  DrawingMode _currentMode = DrawingMode.none;
  final List<Position> _currentLinePoints = [];
  final List<Position> _currentPolygonPoints = [];
  final List<Position> _measurementPoints = [];
  final List<String> _annotationIds = [];
  int _pointCounter = 1;

  @override
  void initState() {
    super.initState();
    _setupMapTapListener();
  }

  @override
  void dispose() {
    widget.mapboxMap?.setOnMapTapListener(null);
    super.dispose();
  }

  void _setupMapTapListener() {
    widget.mapboxMap?.setOnMapTapListener(_onMapTap);
  }

  Future<bool> _onMapTap(MapContentGestureContext context) async {
    if (!mounted) return false;

    final position = Position(
      context.point.coordinates.lng,
      context.point.coordinates.lat,
    );

    switch (_currentMode) {
      case DrawingMode.point:
        await _addPointMarker(position);
        break;
      case DrawingMode.line:
        await _addLinePoint(position);
        break;
      case DrawingMode.polygon:
        await _addPolygonPoint(position);
        break;
      case DrawingMode.measure:
        await _addMeasurementPoint(position);
        break;
      case DrawingMode.gpsPolygon:
        // GPS polygon không cần xử lý tap vì tự động tracking
        break;
      case DrawingMode.routing:
        // Routing xử lý riêng trong map_screen
        break;
      case DrawingMode.none:
        break;
    }

    return true;
  }

  void _setDrawingMode(DrawingMode mode) {
    if (!mounted) return;

    setState(() {
      _currentMode = mode;
    });

    _showSnackBar('Chế độ: ${_getModeLabel(mode)}');
  }

  void _showSnackBar(String message, {Duration? duration}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: duration ?? const Duration(seconds: 2),
      ),
    );
  }

  // Vẽ điểm
  Future<void> _addPointMarker(Position position) async {
    try {
      final pointAnnotationManager = await widget.mapboxMap?.annotations
          .createPointAnnotationManager();

      final pointAnnotationOptions = PointAnnotationOptions(
        geometry: Point(coordinates: position),
      );

      final annotation = await pointAnnotationManager?.create(
        pointAnnotationOptions,
      );

      if (annotation != null && mounted) {
        setState(() {
          _annotationIds.add('point_$_pointCounter');
          _pointCounter++;
        });
        _showSnackBar('Đã thêm điểm ${_pointCounter - 1}');
      }
    } catch (e) {
      debugPrint('Error adding point marker: $e');
    }
  }

  // Vẽ đường
  Future<void> _addLinePoint(Position position) async {
    if (!mounted) return;

    setState(() {
      _currentLinePoints.add(position);
    });

    if (_currentLinePoints.length >= 2) {
      await _updateLine();
    }

    _showSnackBar('Điểm ${_currentLinePoints.length} đã được thêm');
  }

  Future<void> _updateLine() async {
    try {
      final polylineAnnotationManager = await widget.mapboxMap?.annotations
          .createPolylineAnnotationManager();

      final lineString = LineString(coordinates: _currentLinePoints);
      final polylineAnnotationOptions = PolylineAnnotationOptions(
        geometry: lineString,
        lineColor: 0xFF2196F3,
        lineWidth: 3.0,
      );

      final annotation = await polylineAnnotationManager?.create(
        polylineAnnotationOptions,
      );

      if (annotation != null && mounted) {
        setState(() {
          _annotationIds.add('line_${DateTime.now().millisecondsSinceEpoch}');
        });
      }
    } catch (e) {
      debugPrint('Error updating line: $e');
    }
  }

  // Vẽ vùng
  Future<void> _addPolygonPoint(Position position) async {
    if (!mounted) return;

    setState(() {
      _currentPolygonPoints.add(position);
    });

    if (_currentPolygonPoints.length >= 3) {
      await _updatePolygon();
    }

    _showSnackBar('Điểm polygon ${_currentPolygonPoints.length} đã được thêm');
  }

  Future<void> _updatePolygon() async {
    try {
      final polygonAnnotationManager = await widget.mapboxMap?.annotations
          .createPolygonAnnotationManager();

      final closedPoints = List<Position>.from(_currentPolygonPoints);
      if (closedPoints.length >= 3) {
        closedPoints.add(_currentPolygonPoints.first);
      }

      final polygon = Polygon(coordinates: [closedPoints]);
      final polygonAnnotationOptions = PolygonAnnotationOptions(
        geometry: polygon,
        fillColor: 0x4CAF5050,
        fillOutlineColor: 0xFF4CAF50,
      );

      final annotation = await polygonAnnotationManager?.create(
        polygonAnnotationOptions,
      );

      if (annotation != null && mounted) {
        setState(() {
          _annotationIds.add(
            'polygon_${DateTime.now().millisecondsSinceEpoch}',
          );
        });
        _showPolygonArea();
      }
    } catch (e) {
      debugPrint('Error updating polygon: $e');
    }
  }

  // Đo đạc
  Future<void> _addMeasurementPoint(Position position) async {
    if (!mounted) return;

    setState(() {
      _measurementPoints.add(position);
    });

    if (_measurementPoints.length == 2) {
      final distance = _calculateDistance(
        _measurementPoints[0],
        _measurementPoints[1],
      );

      _showSnackBar(
        'Khoảng cách: ${distance.toStringAsFixed(2)} km',
        duration: const Duration(seconds: 4),
      );

      await _drawMeasurementLine();

      if (mounted) {
        setState(() {
          _measurementPoints.clear();
        });
      }
    } else {
      _showSnackBar('Chạm điểm thứ hai để đo khoảng cách');
    }
  }

  Future<void> _drawMeasurementLine() async {
    try {
      final polylineAnnotationManager = await widget.mapboxMap?.annotations
          .createPolylineAnnotationManager();

      final lineString = LineString(coordinates: _measurementPoints);
      final polylineAnnotationOptions = PolylineAnnotationOptions(
        geometry: lineString,
        lineColor: 0xFFF44336,
        lineWidth: 2.0,
      );

      final annotation = await polylineAnnotationManager?.create(
        polylineAnnotationOptions,
      );

      if (annotation != null && mounted) {
        setState(() {
          _annotationIds.add(
            'measure_${DateTime.now().millisecondsSinceEpoch}',
          );
        });
      }
    } catch (e) {
      debugPrint('Error drawing measurement line: $e');
    }
  }

  double _calculateDistance(Position point1, Position point2) {
    const double earthRadius = 6371;

    final double lat1Rad = point1.lat * math.pi / 180;
    final double lat2Rad = point2.lat * math.pi / 180;
    final double deltaLatRad = (point2.lat - point1.lat) * math.pi / 180;
    final double deltaLngRad = (point2.lng - point1.lng) * math.pi / 180;

    final double a =
        math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(deltaLngRad / 2) *
            math.sin(deltaLngRad / 2);
    final double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }

  double _calculatePolygonArea(List<Position> points) {
    if (points.length < 3) return 0;

    double area = 0;
    for (int i = 0; i < points.length; i++) {
      int j = (i + 1) % points.length;
      area += points[i].lng * points[j].lat;
      area -= points[j].lng * points[i].lat;
    }
    area = area.abs() / 2;

    return area * 111.32 * 111.32;
  }

  void _showPolygonArea() {
    if (_currentPolygonPoints.length >= 3) {
      final area = _calculatePolygonArea(_currentPolygonPoints);
      _showSnackBar(
        'Diện tích: ${area.toStringAsFixed(2)} km²',
        duration: const Duration(seconds: 4),
      );
    }
  }

  Future<void> _clearAllDrawings() async {
    try {
      final pointManager = await widget.mapboxMap?.annotations
          .createPointAnnotationManager();
      final polylineManager = await widget.mapboxMap?.annotations
          .createPolylineAnnotationManager();
      final polygonManager = await widget.mapboxMap?.annotations
          .createPolygonAnnotationManager();

      await pointManager?.deleteAll();
      await polylineManager?.deleteAll();
      await polygonManager?.deleteAll();

      if (mounted) {
        setState(() {
          _currentMode = DrawingMode.none;
          _currentLinePoints.clear();
          _currentPolygonPoints.clear();
          _measurementPoints.clear();
          _annotationIds.clear();
          _pointCounter = 1;
        });

        _showSnackBar('Đã xóa tất cả đối tượng');
      }
    } catch (e) {
      debugPrint('Error clearing drawings: $e');
    }
  }

  String _getModeLabel(DrawingMode mode) {
    switch (mode) {
      case DrawingMode.none:
        return 'Không có';
      case DrawingMode.point:
        return 'Vẽ điểm';
      case DrawingMode.line:
        return 'Vẽ đường';
      case DrawingMode.polygon:
        return 'Diện tích';
      case DrawingMode.measure:
        return 'Đo đạc';
      case DrawingMode.gpsPolygon:
        return 'GPS Tracking';
      case DrawingMode.routing:
        return 'Tìm đường';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.build, color: Colors.green[700], size: 24),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Công cụ bản đồ',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Current mode indicator
          if (_currentMode != DrawingMode.none)
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.green[700]!, width: 1),
              ),
              child: Row(
                children: [
                  Icon(Icons.touch_app, color: Colors.green[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Đang sử dụng: ${_getModeLabel(_currentMode)}',
                      style: TextStyle(
                        color: Colors.green[900],
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => _setDrawingMode(DrawingMode.none),
                    child: const Text('Dừng'),
                  ),
                ],
              ),
            ),

          // Tools Grid
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: GridView.count(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisCount: 2,
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 1.5,
              children: [
                _buildToolCard(
                  icon: Icons.place_outlined,
                  title: 'Vẽ điểm',
                  mode: DrawingMode.point,
                ),
                _buildToolCard(
                  icon: Icons.timeline,
                  title: 'Vẽ đường',
                  mode: DrawingMode.line,
                ),
                _buildToolCard(
                  icon: Icons.pentagon_outlined,
                  title: 'Diện tích',
                  mode: DrawingMode.polygon,
                ),
                _buildToolCard(
                  icon: Icons.straighten,
                  title: 'Đo đạc',
                  mode: DrawingMode.measure,
                ),
              ],
            ),
          ),

          const SizedBox(height: 12),
          const Divider(height: 1),
          const SizedBox(height: 12),

          // Action buttons
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 24),
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _clearAllDrawings,
                    icon: const Icon(Icons.delete_outline),
                    label: const Text('Xóa tất cả'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(color: Colors.red),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToolCard({
    required IconData icon,
    required String title,
    required DrawingMode mode,
  }) {
    final isActive = _currentMode == mode;

    return Material(
      color: isActive ? Colors.green[700] : Colors.grey[100],
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: () => _setDrawingMode(mode),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                icon,
                color: isActive ? Colors.white : Colors.grey[700],
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                title,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: isActive ? FontWeight.w600 : FontWeight.w500,
                  color: isActive ? Colors.white : Colors.grey[800],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
