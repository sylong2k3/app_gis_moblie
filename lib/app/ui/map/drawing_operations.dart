part of 'map_screen.dart';

class _DrawingOperations {
  static Future<void> addPoint(_MapScreenState state, Position position) async {
    try {
      await state._ensureAnnotationManagers();
      final pointAnnotationManager = state._pointAnnotationManager;
      if (pointAnnotationManager == null) return;

      final coordText =
          '${position.lat.toStringAsFixed(6)}, ${position.lng.toStringAsFixed(6)}';

      final pointAnnotationOptions = PointAnnotationOptions(
        geometry: Point(coordinates: position),
        iconImage: 'red_marker',
        iconSize: 0.05,
        textField: coordText,
        textAnchor: TextAnchor.BOTTOM,
        textOffset: [0.0, -1.2],
        textMaxWidth: 1000,
        textSize: 12,
        textColor: 0xFF111827,
        textHaloColor: 0xFFFFFFFF,
        textHaloWidth: 2.5,
      );

      await pointAnnotationManager.create(pointAnnotationOptions);
    } catch (e) {
    }
  }

  static Future<void> addLinePoint(
    _MapScreenState state,
    Position position,
  ) async {
    state._currentLinePoints.add(position);
    state._notifyUi();

    if (state._currentLinePoints.length >= 2) {
      await updateLine(state);
    }
  }

  static Future<void> updateLine(_MapScreenState state) async {
    try {
      await state._ensureAnnotationManagers();
      final polylineAnnotationManager = state._linePolylineAnnotationManager;
      if (polylineAnnotationManager == null) return;

      // Redraw a single polyline so the latest geometry is visible.
      await polylineAnnotationManager.deleteAll();

      final lineString = LineString(coordinates: state._currentLinePoints);
      final polylineAnnotationOptions = PolylineAnnotationOptions(
        geometry: lineString,
        lineColor: 0xFF2196F3,
        lineWidth: 3.0,
      );

      await polylineAnnotationManager.create(polylineAnnotationOptions);
    } catch (e) {
      debugPrint('Error updating line: $e');
    }
  }

  static Future<void> addPolygonPoint(
    _MapScreenState state,
    Position position,
  ) async {
    state._currentPolygonPoints.add(position);
    state._notifyUi();

    // Thêm điểm với số thứ tự
    await _addNumberedPoint(
      state,
      position,
      state._currentPolygonPoints.length,
    );

    if (state._currentPolygonPoints.length >= 3) {
      await updatePolygon(state);
    }
  }

  static Future<void> _addNumberedPoint(
    _MapScreenState state,
    Position position,
    int number,
  ) async {
    try {
      await state._ensureAnnotationManagers();
      final pointAnnotationManager = state._pointAnnotationManager;
      if (pointAnnotationManager == null) return;

      final pointAnnotationOptions = PointAnnotationOptions(
        geometry: Point(coordinates: position),
        iconSize: 0.05,
        textField: number.toString(),
        textAnchor: TextAnchor.CENTER,
        textSize: 14,
        textColor: 0xFFFFFFFF,
        textHaloColor: 0xFFFF9800,
        textHaloWidth: 3.0,
      );

      await pointAnnotationManager.create(pointAnnotationOptions);
    } catch (e) {
      debugPrint('Error adding numbered point: $e');
    }
  }

  static Future<void> updatePolygon(_MapScreenState state) async {
    try {
      await state._ensureAnnotationManagers();
      final polygonAnnotationManager = state._polygonAnnotationManager;
      if (polygonAnnotationManager == null) return;

      // Redraw a single polygon so the latest geometry is visible.
      await polygonAnnotationManager.deleteAll();

      final closedPoints = List<Position>.from(state._currentPolygonPoints);
      if (closedPoints.length >= 3) {
        closedPoints.add(state._currentPolygonPoints.first);
      }

      final polygon = Polygon(coordinates: [closedPoints]);
      final polygonAnnotationOptions = PolygonAnnotationOptions(
        geometry: polygon,
        fillColor: 0x4CAF5050,
        fillOutlineColor: 0xFF4CAF50,
      );

      await polygonAnnotationManager.create(polygonAnnotationOptions);

      final areaHa = calculatePolygonAreaHa(state._currentPolygonPoints);
      state._setPolygonAreaHa(areaHa);
    } catch (e) {
      debugPrint('Error updating polygon: $e');
    }
  }

  static double calculatePolygonAreaHa(List<Position> points) {
    if (points.length < 3) return 0.0;

    const double earthRadius = 6371000.0; // meters

    // Chuyển đổi sang radian
    final lats = points.map((p) => p.lat * math.pi / 180).toList();
    final lngs = points.map((p) => p.lng * math.pi / 180).toList();

    double area = 0.0;

    for (int i = 0; i < points.length; i++) {
      final j = (i + 1) % points.length;
      area += lngs[i] * lats[j] - lngs[j] * lats[i];
    }

    area = area.abs() / 2.0;

    // Chuyển đổi sang mét vuông
    final areaM2 = area * earthRadius * earthRadius;

    // Chuyển sang hecta
    return areaM2 / 10000.0;
  }

  static Future<void> addMeasurePoint(
    _MapScreenState state,
    Position position,
  ) async {
    debugPrint('Adding measure point: ${position.lat}, ${position.lng}');
    state._measurementPoints.add(position);
    debugPrint('Total measure points: ${state._measurementPoints.length}');

    // Thêm marker cho điểm đo
    await _addMeasurementMarker(
      state,
      position,
      state._measurementPoints.length,
    );

    state._notifyUi();

    if (state._measurementPoints.length >= 2) {
      debugPrint('Updating measurement line...');
      await updateMeasurement(state);
    }
  }

  static Future<void> _addMeasurementMarker(
    _MapScreenState state,
    Position position,
    int number,
  ) async {
    try {
      await state._ensureAnnotationManagers();
      final pointAnnotationManager = state._pointAnnotationManager;
      if (pointAnnotationManager == null) return;

      final pointAnnotationOptions = PointAnnotationOptions(
        geometry: Point(coordinates: position),
        iconSize: 0.05,
        textField: number.toString(),
        textAnchor: TextAnchor.CENTER,
        textSize: 14,
        textColor: 0xFFFFFFFF,
        textHaloColor: 0xFFFF9800,
        textHaloWidth: 3.0,
      );

      await pointAnnotationManager.create(pointAnnotationOptions);
    } catch (e) {
      debugPrint('Error adding measurement marker: $e');
    }
  }

  static Future<void> updateMeasurement(_MapScreenState state) async {
    try {
      await state._ensureAnnotationManagers();
      final polylineAnnotationManager =
          state._measurementPolylineAnnotationManager;
      if (polylineAnnotationManager == null) return;

      // Redraw a single measurement line.
      await polylineAnnotationManager.deleteAll();

      final lineString = LineString(coordinates: state._measurementPoints);
      final polylineAnnotationOptions = PolylineAnnotationOptions(
        geometry: lineString,
        lineColor: 0xFFFF9800,
        lineWidth: 3.0,
      );

      await polylineAnnotationManager.create(polylineAnnotationOptions);

      if (state._measurementPoints.length >= 2) {
        double totalDistance = 0;
        for (int i = 0; i < state._measurementPoints.length - 1; i++) {
          totalDistance += calculateDistance(
            state._measurementPoints[i],
            state._measurementPoints[i + 1],
          );
        }

        state._setMeasurementTotalKm(totalDistance);
      }
    } catch (e) {
      debugPrint('Error updating measurement: $e');
    }
  }

  static double calculateDistance(Position start, Position end) {
    const double earthRadius = 6371.0;

    double lat1Rad = start.lat * (math.pi / 180);
    double lat2Rad = end.lat * (math.pi / 180);
    double deltaLatRad = (end.lat - start.lat) * (math.pi / 180);
    double deltaLngRad = (end.lng - start.lng) * (math.pi / 180);

    double a =
        math.sin(deltaLatRad / 2) * math.sin(deltaLatRad / 2) +
        math.cos(lat1Rad) *
            math.cos(lat2Rad) *
            math.sin(deltaLngRad / 2) *
            math.sin(deltaLngRad / 2);
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));

    return earthRadius * c;
  }
}
