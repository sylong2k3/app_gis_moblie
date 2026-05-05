import 'package:equatable/equatable.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:app_core/domain/enums/drawing_mode.dart';

class MapUiState extends Equatable {
  final bool showLayerPanel;
  final bool showCloudPanel;
  final bool isPickingCloudLocation;
  final Position? cloudLocation;
  final bool isTrackingLocation;
  final DrawingMode currentDrawingMode;
  final List<Position> currentLinePoints;
  final List<Position> currentPolygonPoints;
  final double polygonAreaHa;
  final List<Position> measurementPoints;
  final double measurementTotalKm;
  final List<Position> gpsPolygonPoints;
  final bool isGpsPolygonTracking;
  final Position? routeStartPoint;
  final Position? routeEndPoint;
  final double routeDistanceKm;
  final double routeDurationMinutes;

  const MapUiState({
    this.showLayerPanel = false,
    this.showCloudPanel = false,
    this.isPickingCloudLocation = false,
    this.cloudLocation,
    this.isTrackingLocation = false,
    this.currentDrawingMode = DrawingMode.none,
    this.currentLinePoints = const [],
    this.currentPolygonPoints = const [],
    this.polygonAreaHa = 0.0,
    this.measurementPoints = const [],
    this.measurementTotalKm = 0.0,
    this.gpsPolygonPoints = const [],
    this.isGpsPolygonTracking = false,
    this.routeStartPoint,
    this.routeEndPoint,
    this.routeDistanceKm = 0.0,
    this.routeDurationMinutes = 0.0,
  });

  MapUiState copyWith({
    bool? showLayerPanel,
    bool? showCloudPanel,
    bool? isPickingCloudLocation,
    Position? cloudLocation,
    bool clearCloudLocation = false,
    bool? isTrackingLocation,
    DrawingMode? currentDrawingMode,
    List<Position>? currentLinePoints,
    List<Position>? currentPolygonPoints,
    double? polygonAreaHa,
    List<Position>? measurementPoints,
    double? measurementTotalKm,
    List<Position>? gpsPolygonPoints,
    bool? isGpsPolygonTracking,
    Position? routeStartPoint,
    bool clearRouteStartPoint = false,
    Position? routeEndPoint,
    bool clearRouteEndPoint = false,
    double? routeDistanceKm,
    double? routeDurationMinutes,
  }) {
    return MapUiState(
      showLayerPanel: showLayerPanel ?? this.showLayerPanel,
      showCloudPanel: showCloudPanel ?? this.showCloudPanel,
      isPickingCloudLocation:
          isPickingCloudLocation ?? this.isPickingCloudLocation,
      cloudLocation: clearCloudLocation
          ? null
          : (cloudLocation ?? this.cloudLocation),
      isTrackingLocation: isTrackingLocation ?? this.isTrackingLocation,
      currentDrawingMode: currentDrawingMode ?? this.currentDrawingMode,
      currentLinePoints: currentLinePoints ?? this.currentLinePoints,
      currentPolygonPoints: currentPolygonPoints ?? this.currentPolygonPoints,
      polygonAreaHa: polygonAreaHa ?? this.polygonAreaHa,
      measurementPoints: measurementPoints ?? this.measurementPoints,
      measurementTotalKm: measurementTotalKm ?? this.measurementTotalKm,
      gpsPolygonPoints: gpsPolygonPoints ?? this.gpsPolygonPoints,
      isGpsPolygonTracking: isGpsPolygonTracking ?? this.isGpsPolygonTracking,
      routeStartPoint: clearRouteStartPoint
          ? null
          : (routeStartPoint ?? this.routeStartPoint),
      routeEndPoint: clearRouteEndPoint
          ? null
          : (routeEndPoint ?? this.routeEndPoint),
      routeDistanceKm: routeDistanceKm ?? this.routeDistanceKm,
      routeDurationMinutes: routeDurationMinutes ?? this.routeDurationMinutes,
    );
  }

  @override
  List<Object?> get props => [
    showLayerPanel,
    showCloudPanel,
    isPickingCloudLocation,
    cloudLocation,
    isTrackingLocation,
    currentDrawingMode,
    currentLinePoints,
    currentPolygonPoints,
    polygonAreaHa,
    measurementPoints,
    measurementTotalKm,
    gpsPolygonPoints,
    isGpsPolygonTracking,
    routeStartPoint,
    routeEndPoint,
    routeDistanceKm,
    routeDurationMinutes,
  ];
}
