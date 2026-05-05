import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:app_core/domain/enums/drawing_mode.dart';
import 'map_ui_state.dart';

class MapUiCubit extends Cubit<MapUiState> {
  MapUiCubit() : super(const MapUiState());

  // Layer Panel
  void toggleLayerPanel() {
    emit(state.copyWith(showLayerPanel: !state.showLayerPanel));
  }

  void closeLayerPanel() {
    emit(state.copyWith(showLayerPanel: false));
  }

  // Cloud Panel
  void showCloudPanel() {
    emit(state.copyWith(showCloudPanel: true));
  }

  void closeCloudPanel() {
    emit(state.copyWith(showCloudPanel: false, clearCloudLocation: true));
  }

  void startPickingCloudLocation() {
    emit(state.copyWith(isPickingCloudLocation: true, showCloudPanel: false));
  }

  void cancelPickingCloudLocation() {
    emit(state.copyWith(isPickingCloudLocation: false));
  }

  void setCloudLocation(Position position) {
    emit(
      state.copyWith(
        cloudLocation: position,
        isPickingCloudLocation: false,
        showCloudPanel: true,
      ),
    );
  }

  // Location Tracking
  void startLocationTracking() {
    emit(state.copyWith(isTrackingLocation: true));
  }

  void stopLocationTracking() {
    emit(state.copyWith(isTrackingLocation: false));
  }

  // Drawing Mode
  void setDrawingMode(DrawingMode mode) {
    emit(state.copyWith(currentDrawingMode: mode));
  }

  // Line Drawing
  void addLinePoint(Position point) {
    final points = List<Position>.from(state.currentLinePoints)..add(point);
    emit(state.copyWith(currentLinePoints: points));
  }

  void clearLinePoints() {
    emit(state.copyWith(currentLinePoints: []));
  }

  // Polygon Drawing
  void addPolygonPoint(Position point) {
    final points = List<Position>.from(state.currentPolygonPoints)..add(point);
    emit(state.copyWith(currentPolygonPoints: points));
  }

  void clearPolygonPoints() {
    emit(state.copyWith(currentPolygonPoints: []));
  }

  void setPolygonArea(double areaHa) {
    emit(state.copyWith(polygonAreaHa: areaHa));
  }

  // Measurement
  void addMeasurementPoint(Position point) {
    final points = List<Position>.from(state.measurementPoints)..add(point);
    emit(state.copyWith(measurementPoints: points));
  }

  void clearMeasurementPoints() {
    emit(state.copyWith(measurementPoints: []));
  }

  void setMeasurementTotal(double totalKm) {
    emit(state.copyWith(measurementTotalKm: totalKm));
  }

  // GPS Polygon
  void startGpsPolygonTracking() {
    emit(state.copyWith(isGpsPolygonTracking: true, gpsPolygonPoints: []));
  }

  void stopGpsPolygonTracking() {
    emit(state.copyWith(isGpsPolygonTracking: false));
  }

  void addGpsPolygonPoint(Position point) {
    final points = List<Position>.from(state.gpsPolygonPoints)..add(point);
    emit(state.copyWith(gpsPolygonPoints: points));
  }

  void clearGpsPolygonPoints() {
    emit(state.copyWith(gpsPolygonPoints: []));
  }

  // Routing
  void setRouteStartPoint(Position point) {
    emit(state.copyWith(routeStartPoint: point));
  }

  void setRouteEndPoint(Position point) {
    emit(state.copyWith(routeEndPoint: point));
  }

  void setRouteInfo(double distanceKm, double durationMinutes) {
    emit(
      state.copyWith(
        routeDistanceKm: distanceKm,
        routeDurationMinutes: durationMinutes,
      ),
    );
  }

  void clearRouting() {
    emit(
      state.copyWith(
        clearRouteStartPoint: true,
        clearRouteEndPoint: true,
        routeDistanceKm: 0.0,
        routeDurationMinutes: 0.0,
      ),
    );
  }

  // Clear All
  void clearAllDrawings() {
    emit(
      state.copyWith(
        currentDrawingMode: DrawingMode.none,
        currentLinePoints: [],
        currentPolygonPoints: [],
        polygonAreaHa: 0.0,
        measurementPoints: [],
        measurementTotalKm: 0.0,
        gpsPolygonPoints: [],
        clearRouteStartPoint: true,
        clearRouteEndPoint: true,
        routeDistanceKm: 0.0,
        routeDurationMinutes: 0.0,
      ),
    );
  }
}
