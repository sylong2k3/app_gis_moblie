import 'dart:async';
import 'package:app_core/app/bloc/auth/auth_bloc.dart';
import 'package:app_core/app/bloc/map_ui/map_ui_cubit.dart';
import 'package:app_core/app/bloc/notification/notification_cubit.dart';
import 'package:app_core/app/ui/map/services/geojson_layer_manager.dart';
import 'package:dio/dio.dart';

import 'package:app_core/app/bloc/location/location_cubit.dart';
import 'package:app_core/app/bloc/map/map_cubit.dart';
import 'package:app_core/app/bloc/weather/weather_cubit.dart';
import 'package:app_core/app/ui/map/field_observation_sheet.dart';
import 'package:app_core/app/ui/map/pick_location_hint.dart';
import 'package:app_core/app/ui/map/widgets/map_action_button.dart';
import 'package:app_core/app/ui/map/widgets/map_floating_action_button.dart';
import 'package:app_core/app/ui/map/widgets/map_style_selector_sheet.dart';
import 'package:app_core/app/ui/map/widgets/weather_info_quick_panel.dart';
import 'package:app_core/app/ui/map/widgets/drawing_tool_bar.dart';
import 'package:app_core/app/ui/map/widgets/feature_selected_panel.dart';
import 'package:app_core/app/ui/map/widgets/layer_control_panel.dart';
import 'package:app_core/app/ui/map/widgets/location_permission_banner.dart';
import 'package:app_core/app/ui/map/widgets/mode_status_banner.dart';
import 'package:app_core/app/ui/map/widgets/search_bar_widget.dart';
import 'package:app_core/app/ui/map/widgets/map_search_results_panel.dart';
import 'package:app_core/app/ui/map/widgets/feature_info_dialog.dart';
import 'package:app_core/app/ui/notifications/notifications_screen.dart';
import 'package:app_core/domain/entities/user_location.dart';
import 'package:app_core/domain/entities/map_layer_feature.dart';
import 'package:app_core/domain/entities/map_layer_detail.dart';
import 'package:app_core/domain/enums/drawing_mode.dart';
import 'package:app_core/shared/constants/app_colors.dart';
import 'package:app_core/shared/constants/app_dimensions.dart';
import 'package:app_core/shared/constants/image_path.dart';
import 'package:app_core/shared/constants/mapbox_constants.dart';
import 'package:app_core/shared/widgets/toast_helper.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'dart:math' as math;
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'package:geolocator/geolocator.dart' as geo;
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

part 'drawing_operations.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  MapboxMap? _mapboxMap;
  String _currentStyle =
      MapboxConstants.styleOutdoors; // Sử dụng custom Outdoor style
  bool _showLayerPanel = false;
  bool _showCloudPanel = false;
  bool _isPickingCloudLocation = false;
  Position? _cloudLocation;

  // Keep annotation managers alive to ensure drawings render reliably.
  PointAnnotationManager? _pointAnnotationManager;
  PolylineAnnotationManager? _linePolylineAnnotationManager;
  PolylineAnnotationManager? _measurementPolylineAnnotationManager;
  PolygonAnnotationManager? _polygonAnnotationManager;

  // Real-time location tracking
  bool _isTrackingLocation = false;
  bool _shouldFlyToCurrentLocation = false;
  PointAnnotationManager? _userLocationAnnotationManager;

  // Weather location marker
  PointAnnotationManager? _weatherLocationAnnotationManager;

  // GeoJSON Layer Manager for efficient rendering
  GeoJsonLayerManager? _geoJsonLayerManager;

  // Layer features annotation managers (keyed by categoryId) - DEPRECATED, use GeoJsonLayerManager
  final Map<int, PolygonAnnotationManager> _layerPolygonManagers = {};
  final Map<int, PolylineAnnotationManager> _layerPolylineManagers = {};
  final Map<int, PointAnnotationManager> _layerPointManagers = {};

  // Store feature data for each annotation (keyed by annotation ID)
  final Map<String, MapLayerFeature> _annotationFeatureMap = {};

  // Track if this is initial load to avoid showing snackbars
  bool _isInitialLoad = true;
  List<int> _pendingCategoryIdsAfterStyleChange = [];
  Set<int> _visibleLayerIds = {};

  static const double _drawingToolsPanelHeight = 78;

  // Drawing tools state
  DrawingMode _currentDrawingMode = DrawingMode.none;
  final List<Position> _currentLinePoints = [];
  final List<Position> _currentPolygonPoints = [];
  double _polygonAreaHa = 0.0;
  final List<Position> _measurementPoints = [];
  double _measurementTotalKm = 0.0;
  final List<String> _annotationIds = [];

  // GPS Polygon tracking
  StreamSubscription<UserLocation>? _gpsPolygonSubscription;
  Position? _lastGpsTrackPosition;
  static const double _gpsTrackMinMoveMeters = 3.0;
  DateTime? _gpsTrackingStartedAt;
  Timer? _gpsRealtimeTimer;
  // Note: _gpsPolygonPoints and _isGpsPolygonTracking moved to MapUiCubit

  // Routing
  Position? _routeStartPoint;
  Position? _routeEndPoint;
  PolylineAnnotationManager? _routePolylineAnnotationManager;
  double _routeDistanceKm = 0.0;
  double _routeDurationMinutes = 0.0;

  bool get _isInteractionLockedByGpsTracking =>
      _currentDrawingMode == DrawingMode.gpsPolygon;

  // Safe context access helper
  T? _safeRead<T extends Object>() {
    if (!mounted) return null;
    try {
      return context.read<T>();
    } catch (e) {
      debugPrint('Error reading $T from context: $e');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    // Defer context usage until after the first frame
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _safeRead<MapCubit>()?.loadLayers();
      _safeRead<LocationCubit>()?.checkPermission();
      _safeRead<NotificationCubit>()?.loadNotifications();
    });
  }

  @override
  void dispose() {
    // Clean up location tracking without using context
    if (_isTrackingLocation) {
      _isTrackingLocation = false;
      // Note: LocationCubit cleanup will happen automatically when widget is disposed
    }
    _stopGpsPolygonTracking();
    _gpsRealtimeTimer?.cancel();
    _gpsRealtimeTimer = null;
    super.dispose();
  }

  void _notifyUi() {
    if (!mounted) return;
    setState(() {});
  }

  void _setPolygonAreaHa(double value) {
    if (!mounted) return;
    setState(() {
      _polygonAreaHa = value;
    });
  }

  void _setMeasurementTotalKm(double value) {
    if (!mounted) return;
    setState(() {
      _measurementTotalKm = value;
    });
  }

  Future<void> _registerStyleImages() async {
    final mapboxMap = _mapboxMap;
    if (mapboxMap == null) return;

    try {
      final redMarkerByteData = await rootBundle.load(ImagePath.iconGps);
      final Uint8List redMarkerBytes = redMarkerByteData.buffer.asUint8List();
      final redMarkerImage = MbxImage(
        width: 512,
        height: 512,
        data: redMarkerBytes,
      );
      await mapboxMap.style.addStyleImage(
        'red_marker',
        1.0,
        redMarkerImage,
        false,
        const [],
        const [],
        null,
      );
    } catch (e) {
      debugPrint('Skip registering red_marker style image: $e');
    }

    try {
      final locationMarkerByteData = await rootBundle.load(
        ImagePath.iconLocation,
      );
      final Uint8List locationMarkerBytes = locationMarkerByteData.buffer
          .asUint8List();
      final locationMarkerImage = MbxImage(
        width: 512,
        height: 512,
        data: locationMarkerBytes,
      );
      await mapboxMap.style.addStyleImage(
        'location_marker',
        1.0,
        locationMarkerImage,
        false,
        const [],
        const [],
        null,
      );
    } catch (e) {
      debugPrint('Skip registering location_marker style image: $e');
    }
  }

  void _restoreVisibleLayersAfterStyleChange() {
    if (!mounted) return;

    final mapCubit = context.read<MapCubit>();
    final categoryIds = <int>{..._pendingCategoryIdsAfterStyleChange};

    if (categoryIds.isEmpty) {
      categoryIds.addAll(_visibleLayerIds);
    }

    _pendingCategoryIdsAfterStyleChange = [];

    for (final categoryId in categoryIds) {
      mapCubit.loadLayerFeatures(categoryId);
    }
  }

  void _onMapCreated(MapboxMap mapboxMap) async {
    _mapboxMap = mapboxMap;
    _mapboxMap?.scaleBar.updateSettings(ScaleBarSettings(enabled: false));

    // Initialize GeoJSON Layer Manager
    _geoJsonLayerManager = GeoJsonLayerManager(mapboxMap);

    _mapboxMap?.setCamera(
      CameraOptions(
        center: Point(
          coordinates: Position(
            MapboxConstants.defaultLongitude,
            MapboxConstants.defaultLatitude,
          ),
        ),
        zoom: MapboxConstants.defaultZoom,
      ),
    );

    // Set up tap listener for feature detection (will be active when drawing mode is none)
    _setupMapTapListener();
  }

  Future<void> _onMapStyleLoaded() async {
    await _registerStyleImages();
    _restoreVisibleLayersAfterStyleChange();
  }

  Future<void> _ensureAnnotationManagers() async {
    final mapboxMap = _mapboxMap;
    if (mapboxMap == null) return;

    _pointAnnotationManager ??= await mapboxMap.annotations
        .createPointAnnotationManager();
    _linePolylineAnnotationManager ??= await mapboxMap.annotations
        .createPolylineAnnotationManager();
    _measurementPolylineAnnotationManager ??= await mapboxMap.annotations
        .createPolylineAnnotationManager();
    _polygonAnnotationManager ??= await mapboxMap.annotations
        .createPolygonAnnotationManager();
  }

  void _resetAnnotationManagers() {
    _pointAnnotationManager = null;
    _linePolylineAnnotationManager = null;
    _measurementPolylineAnnotationManager = null;
    _polygonAnnotationManager = null;
    _userLocationAnnotationManager = null;
    _weatherLocationAnnotationManager = null;
    _routePolylineAnnotationManager = null;
    _layerPolygonManagers.clear();
    _layerPolylineManagers.clear();
    _layerPointManagers.clear();
    _annotationFeatureMap.clear();

    // Reset GeoJSON layer manager (will be recreated on next map creation)
    _geoJsonLayerManager = null;
  }

  void _onLocationButtonPressed() {
    if (_isTrackingLocation) {
      _stopLocationTracking();
      return;
    }

    _shouldFlyToCurrentLocation = true;
    _startLocationTracking();
    _centerOnUserLocation();
  }

  void _startLocationTracking() {
    if (!mounted) return;
    setState(() {
      _isTrackingLocation = true;
    });
    context.read<LocationCubit>().startTracking();
  }

  void _stopLocationTracking() {
    if (!mounted) return;

    final locationCubit = context.read<LocationCubit>();

    setState(() {
      _isTrackingLocation = false;
    });
    _shouldFlyToCurrentLocation = false;

    locationCubit.stopTracking();
    _removeUserLocationMarker();
  }

  Future<void> _updateUserLocationMarker(Position position) async {
    try {
      await _ensureAnnotationManagers();

      _userLocationAnnotationManager ??= await _mapboxMap?.annotations
          .createPointAnnotationManager();

      if (_userLocationAnnotationManager == null) return;

      // Xóa tất cả marker cũ
      await _userLocationAnnotationManager?.deleteAll();

      // Tạo marker mới
      final pointAnnotationOptions = PointAnnotationOptions(
        geometry: Point(coordinates: position),
        iconImage: 'location_marker',
        iconSize: 0.08,
        iconColor: 0xFFF44336,
      );

      await _userLocationAnnotationManager!.create(pointAnnotationOptions);
    } catch (e) {
      debugPrint('Error updating user location marker: $e');
    }
  }

  Future<void> _removeUserLocationMarker() async {
    try {
      await _userLocationAnnotationManager?.deleteAll();
    } catch (e) {
      debugPrint('Error removing user location marker: $e');
    }
  }

  Future<void> _updateWeatherLocationMarker(Position position) async {
    try {
      await _ensureAnnotationManagers();

      _weatherLocationAnnotationManager ??= await _mapboxMap?.annotations
          .createPointAnnotationManager();

      if (_weatherLocationAnnotationManager == null) return;

      // Xóa marker cũ
      await _weatherLocationAnnotationManager?.deleteAll();

      // Tạo marker mới cho vị trí thời tiết
      final pointAnnotationOptions = PointAnnotationOptions(
        geometry: Point(coordinates: position),
        iconImage: 'location_marker',
        iconSize: 0.07,
      );

      await _weatherLocationAnnotationManager!.create(pointAnnotationOptions);
    } catch (e) {
      debugPrint('Error updating weather location marker: $e');
    }
  }

  Future<void> _removeWeatherLocationMarker() async {
    try {
      await _weatherLocationAnnotationManager?.deleteAll();
    } catch (e) {
      debugPrint('Error removing weather location marker: $e');
    }
  }

  void _changeMapStyle(String styleUrl) {
    if (!mounted) return;

    _pendingCategoryIdsAfterStyleChange = _visibleLayerIds.toList();

    setState(() {
      _currentStyle = styleUrl;
    });

    // Annotation managers are style-bound.
    _resetAnnotationManagers();
  }

  void _showMapStyleSelectorSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (sheetContext) => MapStyleSelectorSheet(
        currentStyle: _currentStyle,
        onSelectStyle: _changeMapStyle,
      ),
    );
  }

  void _toggleCloudPanel() {
    if (_showCloudPanel) {
      _closeCloudPanel();
      return;
    }

    if (_isPickingCloudLocation) {
      _cancelPickingCloudLocation();
      return;
    }

    if (_cloudLocation == null) {
      _startPickingCloudLocation();
      return;
    }

    if (!mounted) return;
    setState(() {
      _showCloudPanel = true;
    });
  }

  void _startPickingCloudLocation() {
    if (!mounted) return;

    setState(() {
      _isPickingCloudLocation = true;
      _showCloudPanel = false;
    });

    _mapboxMap?.setOnMapTapListener((tapContext) async {
      final position = Position(
        tapContext.point.coordinates.lng,
        tapContext.point.coordinates.lat,
      );

      if (!mounted) return;
      setState(() {
        _cloudLocation = position;
        _isPickingCloudLocation = false;
        _showCloudPanel = true;
      });

      // Hiển thị marker tại vị trí được chọn
      await _updateWeatherLocationMarker(position);

      // Gọi API weather - kiểm tra mounted trước khi dùng context
      if (!mounted) return;
      context.read<WeatherCubit>().getWeatherByCoordinates(
        latitude: position.lat.toDouble(),
        longitude: position.lng.toDouble(),
      );

      _setupMapTapListener();
      return;
    });
  }

  void _cancelPickingCloudLocation() {
    if (!_isPickingCloudLocation) return;
    if (!mounted) return;

    _setupMapTapListener();
    setState(() {
      _isPickingCloudLocation = false;
    });
  }

  void _closeCloudPanel() {
    if (_isPickingCloudLocation) {
      _cancelPickingCloudLocation();
    }
    if (!_showCloudPanel) return;
    if (!mounted) return;

    setState(() {
      _showCloudPanel = false;
      _cloudLocation = null;
    });
    _setupMapTapListener();
    // Xóa marker khi đóng panel
    _removeWeatherLocationMarker();
  }

  void _centerOnUserLocation() {
    if (!mounted) return;
    final locationState = context.read<LocationCubit>().state;

    if (locationState is LocationLoaded) {
      final position = Position(
        locationState.location.longitude,
        locationState.location.latitude,
      );
      _updateUserLocationMarker(position);
      _flyToUserLocation(position);
      _shouldFlyToCurrentLocation = false;
    } else {
      context.read<LocationCubit>().getLocation();
    }
  }

  void _flyToUserLocation(Position position) {
    _mapboxMap?.flyTo(
      CameraOptions(center: Point(coordinates: position), zoom: 16.0, pitch: 0),
      MapAnimationOptions(duration: 1200, startDelay: 0),
    );
  }

  void _setDrawingMode(DrawingMode mode) {
    if (!mounted) return;

    setState(() {
      _currentDrawingMode = mode;
    });

    if (mode == DrawingMode.gpsPolygon) {
      _startGpsPolygonTracking();
    } else if (mode == DrawingMode.routing) {
      _startRoutingMode();
    } else {
      _stopGpsPolygonTracking();
      _clearRouting();

      // Always set up tap listener (it will handle both drawing and feature taps)
      _setupMapTapListener();

      if (mode == DrawingMode.none) {
        // Xóa tất cả drawings khi chuyển về mode none
        _clearAllDrawings();
      }
    }
  }

  void _startRoutingMode() {
    if (!mounted) return;

    setState(() {
      _routeStartPoint = null;
      _routeEndPoint = null;
      _routeDistanceKm = 0.0;
      _routeDurationMinutes = 0.0;
    });
    _setupMapTapListener();
  }

  void _clearRouting() {
    if (!mounted) return;

    _routePolylineAnnotationManager?.deleteAll();
    setState(() {
      _routeStartPoint = null;
      _routeEndPoint = null;
      _routeDistanceKm = 0.0;
      _routeDurationMinutes = 0.0;
    });
  }

  Future<void> _handleRoutingTap(Position position) async {
    if (_routeStartPoint == null) {
      // Đặt điểm bắt đầu
      if (!mounted) return;
      setState(() {
        _routeStartPoint = position;
      });
      await _addRouteMarker(position, 'A', 0xFFF44336);
    } else if (_routeEndPoint == null) {
      // Đặt điểm kết thúc và tìm đường
      if (!mounted) return;
      setState(() {
        _routeEndPoint = position;
      });
      await _addRouteMarker(position, 'B', 0xFFF44336);
      await _fetchAndDrawRoute();
    } else {
      // Reset và bắt đầu lại
      _clearRouting();
      await _pointAnnotationManager?.deleteAll();
      if (!mounted) return;
      setState(() {
        _routeStartPoint = position;
      });
      await _addRouteMarker(position, 'A', 0xFFF44336);
    }
  }

  Future<void> _addRouteMarker(
    Position position,
    String label,
    int color,
  ) async {
    try {
      await _ensureAnnotationManagers();
      final pointAnnotationManager = _pointAnnotationManager;
      if (pointAnnotationManager == null) return;

      final pointAnnotationOptions = PointAnnotationOptions(
        geometry: Point(coordinates: position),
        // iconImage: 'red_marker',
        iconSize: 0.06,
        iconColor: color,
        textField: label,
        textAnchor: TextAnchor.CENTER,
        textSize: 16,
        textColor: 0xFFFFFFFF,
        textHaloColor: color,
        textHaloWidth: 3.0,
      );

      await pointAnnotationManager.create(pointAnnotationOptions);
    } catch (e) {
      debugPrint('Error adding route marker: $e');
    }
  }

  Future<void> _fetchAndDrawRoute() async {
    if (_routeStartPoint == null || _routeEndPoint == null) return;

    try {
      // Gọi Mapbox Directions API với polyline6
      final url =
          '${MapboxConstants.directionsBaseUrl}/mapbox/driving/'
          '${_routeStartPoint!.lng},${_routeStartPoint!.lat};'
          '${_routeEndPoint!.lng},${_routeEndPoint!.lat}'
          '?geometries=polyline6&overview=full&access_token=${MapboxConstants.accessToken}';

      debugPrint('Fetching route from: $url');

      final dio = Dio();
      final response = await dio.get(url);

      if (response.statusCode == 200) {
        final data = response.data;
        final routes = data['routes'] as List;

        if (routes.isNotEmpty) {
          final route = routes[0];
          final geometry = route['geometry'] as String;

          // Decode polyline6
          final routePoints = _decodePolyline6(geometry);

          // Lấy thông tin khoảng cách và thời gian
          final distance = (route['distance'] as num) / 1000; // km
          final duration = (route['duration'] as num) / 60; // minutes

          debugPrint(
            'Route found: ${distance.toStringAsFixed(2)}km, ${duration.toStringAsFixed(0)}min',
          );
          debugPrint('Route points: ${routePoints.length}');

          if (!mounted) return;
          setState(() {
            _routeDistanceKm = distance.toDouble();
            _routeDurationMinutes = duration.toDouble();
          });

          // Vẽ route
          await _drawRoute(routePoints);
        } else {
          debugPrint('No routes found');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(
                content: Text('Không tìm thấy đường đi'),
                backgroundColor: Colors.orange,
              ),
            );
          }
        }
      } else {
        debugPrint('API error: ${response.statusCode}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Lỗi API: ${response.statusCode}'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      debugPrint('Error fetching route: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Không thể tìm đường đi: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // Decode polyline6 format
  List<Position> _decodePolyline6(String encoded) {
    List<Position> points = [];
    int index = 0;
    int len = encoded.length;
    int lat = 0;
    int lng = 0;
    int precision = 6; // polyline6 uses 1e6 precision

    while (index < len) {
      int b;
      int shift = 0;
      int result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;

      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);

      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      double latitude = lat / math.pow(10, precision);
      double longitude = lng / math.pow(10, precision);

      points.add(Position(longitude, latitude));
    }

    return points;
  }

  Future<void> _drawRoute(List<Position> routePoints) async {
    try {
      _routePolylineAnnotationManager ??= await _mapboxMap?.annotations
          .createPolylineAnnotationManager();

      if (_routePolylineAnnotationManager == null) return;

      await _routePolylineAnnotationManager?.deleteAll();

      final lineString = LineString(coordinates: routePoints);
      final polylineAnnotationOptions = PolylineAnnotationOptions(
        geometry: lineString,
        lineColor: 0xFF2196F3,
        lineWidth: 5.0,
      );

      await _routePolylineAnnotationManager!.create(polylineAnnotationOptions);
    } catch (e) {
      debugPrint('Error drawing route: $e');
    }
  }

  void _startGpsPolygonTracking() async {
    if (!mounted) return;

    // Read context before async operations
    final locationRepository = context.read<LocationCubit>().repository;
    final mapUiCubit = context.read<MapUiCubit>();

    // Use cubit instead of setState
    mapUiCubit.startGpsPolygonTracking();
    _lastGpsTrackPosition = null;
    _gpsTrackingStartedAt = DateTime.now();
    _gpsRealtimeTimer?.cancel();
    _gpsRealtimeTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (!mounted || _currentDrawingMode != DrawingMode.gpsPolygon) {
        return;
      }
      _notifyUi();
    });

    // Lấy GPS hiện tại làm điểm bắt đầu đường đi
    final currentLocationResult = await locationRepository.getCurrentLocation();
    currentLocationResult.fold((_) => null, (location) {
      if (!mounted || !mapUiCubit.state.isGpsPolygonTracking) return;

      final currentPosition = Position(location.longitude, location.latitude);
      mapUiCubit.addGpsPolygonPoint(currentPosition);
      _lastGpsTrackPosition = currentPosition;
      _updateGpsPolygon();
      _notifyUi();
    });

    // Bắt đầu lắng nghe vị trí GPS
    _gpsPolygonSubscription?.cancel();
    _gpsPolygonSubscription = locationRepository.watchLocation().listen(
      (location) {
        // Check cubit state instead of local variable
        if (!mapUiCubit.state.isGpsPolygonTracking) return;

        final position = Position(location.longitude, location.latitude);

        if (!_hasMovedEnoughForTrack(position)) {
          return;
        }

        // Add point to cubit
        mapUiCubit.addGpsPolygonPoint(position);
        _lastGpsTrackPosition = position;

        // Cập nhật đường đi/polygon trên bản đồ
        _updateGpsPolygon();
        _notifyUi();
      },
      onError: (error) {
        debugPrint('GPS Polygon tracking error: $error');
      },
    );
  }

  bool _hasMovedEnoughForTrack(Position nextPosition) {
    final lastPosition = _lastGpsTrackPosition;
    if (lastPosition == null) {
      return true;
    }

    final distanceMeters = geo.Geolocator.distanceBetween(
      lastPosition.lat.toDouble(),
      lastPosition.lng.toDouble(),
      nextPosition.lat.toDouble(),
      nextPosition.lng.toDouble(),
    );

    return distanceMeters >= _gpsTrackMinMoveMeters;
  }

  void _stopGpsPolygonTracking() {
    _gpsPolygonSubscription?.cancel();
    _gpsPolygonSubscription = null;
    _lastGpsTrackPosition = null;
    _gpsTrackingStartedAt = null;
    _gpsRealtimeTimer?.cancel();
    _gpsRealtimeTimer = null;

    // Use cubit instead of setState to avoid lifecycle issues
    _safeRead<MapUiCubit>()?.stopGpsPolygonTracking();
  }

  Future<void> _updateGpsPolygon() async {
    if (!mounted) return;

    try {
      // Get points from cubit BEFORE any async operations
      final gpsPolygonPoints = context
          .read<MapUiCubit>()
          .state
          .gpsPolygonPoints;

      await _ensureAnnotationManagers();
      final polygonAnnotationManager = _polygonAnnotationManager;
      final pointAnnotationManager = _pointAnnotationManager;
      final linePolylineAnnotationManager = _linePolylineAnnotationManager;

      if (polygonAnnotationManager == null ||
          pointAnnotationManager == null ||
          linePolylineAnnotationManager == null) {
        return;
      }

      // Xóa polygon cũ
      await polygonAnnotationManager.deleteAll();
      await pointAnnotationManager.deleteAll();
      await linePolylineAnnotationManager.deleteAll();

      // Vẽ lại đường đi theo các điểm GPS
      if (gpsPolygonPoints.length >= 2) {
        final trackLine = LineString(coordinates: gpsPolygonPoints);
        final lineOptions = PolylineAnnotationOptions(
          geometry: trackLine,
          lineColor: 0xFF3B82F6,
          lineWidth: 4.0,
        );
        await linePolylineAnnotationManager.create(lineOptions);
      }

      // Vẽ các điểm đã ghi
      for (int i = 0; i < gpsPolygonPoints.length; i++) {
        final point = gpsPolygonPoints[i];
        final pointAnnotationOptions = PointAnnotationOptions(
          geometry: Point(coordinates: point),
          iconImage: 'red_marker',
          iconSize: 0.05,
          iconColor: 0xFFF44336,
          textField: (i + 1).toString(),
          textAnchor: TextAnchor.CENTER,
          textSize: 14,
          textColor: 0xFFFFFFFF,
          textHaloColor: 0xFF4CAF50,
          textHaloWidth: 3.0,
        );
        await pointAnnotationManager.create(pointAnnotationOptions);
      }

      // Vẽ polygon nếu có >= 3 điểm
      if (gpsPolygonPoints.length >= 3) {
        final closedPoints = List<Position>.from(gpsPolygonPoints);
        closedPoints.add(gpsPolygonPoints.first);

        final polygon = Polygon(coordinates: [closedPoints]);
        final polygonAnnotationOptions = PolygonAnnotationOptions(
          geometry: polygon,
          fillColor: 0x4CAF5050,
          fillOutlineColor: 0xFF4CAF50,
        );

        await polygonAnnotationManager.create(polygonAnnotationOptions);

        // Tính diện tích và update vào cubit
        final areaHa = _DrawingOperations.calculatePolygonAreaHa(
          gpsPolygonPoints,
        );
        _safeRead<MapUiCubit>()?.setPolygonArea(areaHa);
      }
    } catch (e) {
      debugPrint('Error updating GPS polygon: $e');
    }
  }

  Future<void> _clearAllDrawings() async {
    await _ensureAnnotationManagers();

    await _pointAnnotationManager?.deleteAll();
    await _linePolylineAnnotationManager?.deleteAll();
    await _measurementPolylineAnnotationManager?.deleteAll();
    await _polygonAnnotationManager?.deleteAll();
    await _routePolylineAnnotationManager?.deleteAll();

    _stopGpsPolygonTracking();
    _clearRouting();

    // Use cubit to clear all state instead of setState
    _safeRead<MapUiCubit>()?.clearAllDrawings();

    // Clear local state that's not in cubit
    if (!mounted) return;
    setState(() {
      _currentLinePoints.clear();
      _currentPolygonPoints.clear();
      _measurementPoints.clear();
      _polygonAreaHa = 0.0;
      _measurementTotalKm = 0.0;
      _annotationIds.clear();
    });
  }

  Future<void> _onAddObservationPressed(BuildContext context) async {
    final locationState = context.read<LocationCubit>().state;
    String? currentLocation;

    if (locationState is LocationLoaded) {
      currentLocation =
          '${locationState.location.latitude.toStringAsFixed(6)}, '
          '${locationState.location.longitude.toStringAsFixed(6)}';
    }

    await showFieldObservationSheet(
      context,
      initialArea: _polygonAreaHa > 0 ? _polygonAreaHa : null,
      initialLocation: currentLocation,
    );
  }

  Future<void> _selectDrawingModeWithAutoClear(DrawingMode mode) async {
    if (_currentDrawingMode == mode) {
      if (mode == DrawingMode.gpsPolygon) {
        await _showGpsTrackingStopSummary();
      }
      _setDrawingMode(DrawingMode.none);
      return;
    }

    if (_currentDrawingMode == DrawingMode.gpsPolygon &&
        mode != DrawingMode.gpsPolygon) {
      await _showGpsTrackingStopSummary();
    }

    if (_currentDrawingMode != DrawingMode.none) {
      await _clearAllDrawings();
    }

    _setDrawingMode(mode);
  }

  double _calculateGpsTrackDistanceKm(List<Position> points) {
    if (points.length < 2) return 0;

    double distanceMeters = 0;
    for (int i = 1; i < points.length; i++) {
      final previous = points[i - 1];
      final current = points[i];
      distanceMeters += geo.Geolocator.distanceBetween(
        previous.lat.toDouble(),
        previous.lng.toDouble(),
        current.lat.toDouble(),
        current.lng.toDouble(),
      );
    }

    return distanceMeters / 1000;
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours}h ${minutes}m ${seconds}s';
    }

    return '${minutes}m ${seconds}s';
  }

  String _formatGpsDurationForBanner() {
    final startedAt = _gpsTrackingStartedAt;
    if (startedAt == null) {
      return '0m 0s';
    }

    final duration = DateTime.now().difference(startedAt);
    return _formatDuration(duration);
  }

  Future<void> _showGpsTrackingStopSummary() async {
    if (!mounted) return;

    final points = context.read<MapUiCubit>().state.gpsPolygonPoints;
    if (points.isEmpty) {
      return;
    }

    final totalDistanceKm = _calculateGpsTrackDistanceKm(points);
    final startedAt = _gpsTrackingStartedAt;
    final duration = startedAt == null
        ? null
        : DateTime.now().difference(startedAt);
    final areaHa = points.length >= 3
        ? _DrawingOperations.calculatePolygonAreaHa(points)
        : 0.0;

    await showDialog<void>(
      context: context,
      builder: (context) {
        final colorScheme = Theme.of(context).colorScheme;
        final textTheme = Theme.of(context).textTheme;

        Widget summaryItem({
          required IconData icon,
          required String label,
          required String value,
        }) {
          return Container(
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: colorScheme.surfaceContainerHighest.withValues(
                alpha: 0.45,
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                Icon(icon, size: 18, color: colorScheme.primary),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    label,
                    style: textTheme.bodyMedium?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Text(
                  value,
                  style: textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: colorScheme.onSurface,
                  ),
                ),
              ],
            ),
          );
        }

        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          insetPadding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 24,
          ),
          titlePadding: const EdgeInsets.fromLTRB(20, 20, 20, 8),
          contentPadding: const EdgeInsets.fromLTRB(20, 0, 20, 8),
          actionsPadding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
          title: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: colorScheme.primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  Icons.route_rounded,
                  color: colorScheme.primary,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Kết quả hành trình',
                  style: textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              summaryItem(
                icon: Icons.pin_drop_outlined,
                label: 'Số điểm ghi nhận',
                value: '${points.length}',
              ),
              summaryItem(
                icon: Icons.straighten_rounded,
                label: 'Quãng đường',
                value: '${totalDistanceKm.toStringAsFixed(2)} km',
              ),
              if (duration != null) ...[
                summaryItem(
                  icon: Icons.timer_outlined,
                  label: 'Thời gian',
                  value: _formatDuration(duration),
                ),
              ],
              if (areaHa > 0) ...[
                summaryItem(
                  icon: Icons.crop_square_rounded,
                  label: 'Diện tích',
                  value: '${areaHa.toStringAsFixed(2)} ha',
                ),
              ],
            ],
          ),
          actions: [
            SizedBox(
              width: double.infinity,
              child: FilledButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Đóng'),
              ),
            ),
          ],
        );
      },
    );
  }

  Future<bool> _confirmStopGpsTracking() async {
    if (!mounted) return false;

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Dừng hành trình?'),
          content: const Text(
            'Bạn có chắc chắn muốn dừng ghi hành trình và tính kết quả?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Dừng'),
            ),
          ],
        );
      },
    );

    return confirmed ?? false;
  }

  void _showTrackingLockedMessage() {
    if (!mounted) return;
    ToastHelper.showInfo(
      context,
      'Đang ghi hành trình. Hãy dừng tracking để thao tác chức năng khác.',
    );
  }

  void _setupMapTapListener() {
    _mapboxMap?.setOnMapTapListener((tapContext) async {
      final position = Position(
        tapContext.point.coordinates.lng,
        tapContext.point.coordinates.lat,
      );

      // Handle drawing mode taps
      switch (_currentDrawingMode) {
        case DrawingMode.point:
          await _DrawingOperations.addPoint(this, position);
          break;
        case DrawingMode.line:
          await _DrawingOperations.addLinePoint(this, position);
          break;
        case DrawingMode.polygon:
          await _DrawingOperations.addPolygonPoint(this, position);
          break;
        case DrawingMode.measure:
          await _DrawingOperations.addMeasurePoint(this, position);
          break;
        case DrawingMode.routing:
          await _handleRoutingTap(position);
          break;
        case DrawingMode.gpsPolygon:
          // GPS polygon không xử lý tap vì tự động tracking từ GPS
          break;
        case DrawingMode.none:
          // When not in drawing mode, check for feature taps
          await _handleFeatureTap(position);
          break;
      }

      return;
    });
  }

  Future<void> _handleFeatureTap(Position tappedPoint) async {
    final geoJsonManager = _geoJsonLayerManager;
    if (geoJsonManager == null) {
      debugPrint('❌ GeoJSON manager is null');
      return;
    }

    debugPrint('👆 Tap at: [${tappedPoint.lng}, ${tappedPoint.lat}]');

    // Query features from all visible GeoJSON layers
    final screenCoordinate = await _mapboxMap?.pixelForCoordinate(
      Point(coordinates: tappedPoint),
    );

    if (screenCoordinate == null) {
      debugPrint('❌ Screen coordinate is null');
      return;
    }

    debugPrint(
      '📍 Screen coordinate: [${screenCoordinate.x}, ${screenCoordinate.y}]',
    );

    // Try to query features from all visible categories
    bool foundCluster = false;
    String? selectedFeatureId;

    for (final categoryId in _visibleLayerIds) {
      debugPrint('🔍 Querying category $categoryId...');

      final features = await geoJsonManager.queryFeaturesAtPoint(
        point: screenCoordinate,
        categoryId: categoryId,
      );

      debugPrint(
        '📊 Found ${features.length} features in category $categoryId',
      );

      for (final renderedFeature in features) {
        final queriedFeature = renderedFeature.queriedFeature;

        // Convert to Map - handle CastMap type
        Map<String, dynamic>? featureMap;
        try {
          final rawFeature = queriedFeature.feature;
          featureMap = Map<String, dynamic>.from(rawFeature);
        } catch (e) {
          debugPrint('❌ Error converting feature map: $e');
          continue;
        }

        if (_isClusterFeature(featureMap)) {
          foundCluster = true;
          debugPrint('🧩 Cluster tapped, zooming into cluster');
          break;
        }

        selectedFeatureId ??= _extractLayerIdFromFeature(featureMap);
        if (selectedFeatureId != null) {
          debugPrint('🆔 Candidate Feature ID: $selectedFeatureId');
        }
      }

      if (foundCluster) {
        break;
      }

      if (selectedFeatureId != null) {
        break;
      }
    }

    if (foundCluster) {
      await _zoomIntoCluster(tappedPoint);
      return;
    }

    if (selectedFeatureId != null && mounted) {
      debugPrint('✅ Loading feature detail for ID: $selectedFeatureId');
      context.read<MapCubit>().loadLayerDetail(selectedFeatureId);
      return;
    }

    if (!foundCluster) {
      debugPrint('⚠️ No features found at tap location');
      debugPrint('📋 Visible layer IDs: $_visibleLayerIds');
    }
  }

  bool _isClusterFeature(Map<String, dynamic>? featureMap) {
    if (featureMap == null) return false;

    final rawProperties = featureMap['properties'];
    final properties = rawProperties is Map
        ? Map<String, dynamic>.from(rawProperties)
        : <String, dynamic>{};

    final hasPointCount = properties.containsKey('point_count');
    final clusterValue = properties['cluster'];
    final isClusterValue =
        clusterValue == true ||
        clusterValue?.toString().toLowerCase() == 'true';

    return hasPointCount || isClusterValue;
  }

  Future<void> _zoomIntoCluster(Position tappedPoint) async {
    final mapboxMap = _mapboxMap;
    if (mapboxMap == null) return;

    double targetZoom = 15.0;
    try {
      final cameraState = await mapboxMap.getCameraState();
      final nextZoom = cameraState.zoom + 2.0;
      targetZoom = nextZoom.clamp(0.0, 22.0).toDouble();
    } catch (e) {
      debugPrint('⚠️ Could not read camera state for cluster zoom: $e');
    }

    mapboxMap.flyTo(
      CameraOptions(
        center: Point(coordinates: tappedPoint),
        zoom: targetZoom,
        pitch: 0,
      ),
      MapAnimationOptions(duration: 700, startDelay: 0),
    );
  }

  String? _extractLayerIdFromFeature(Map<String, dynamic>? featureMap) {
    if (featureMap == null) return null;

    final rawProperties = featureMap['properties'];
    final properties = rawProperties is Map
        ? Map<String, dynamic>.from(rawProperties)
        : <String, dynamic>{};

    final candidates = <dynamic>[
      properties['id'],
      properties['layer_id'],
      properties['map_layer_id'],
      featureMap['id'],
    ];

    for (final candidate in candidates) {
      final normalized = _normalizeLayerId(candidate);
      if (normalized != null) {
        return normalized;
      }
    }

    return null;
  }

  String? _normalizeLayerId(dynamic value) {
    if (value == null) return null;

    if (value is num) {
      return value.toInt().toString();
    }

    final raw = value.toString().trim();
    if (raw.isEmpty) return null;

    if (RegExp(r'^\d+$').hasMatch(raw)) {
      return raw;
    }

    final compositeMatch = RegExp(r'^(\d+)[_-]\d+$').firstMatch(raw);
    if (compositeMatch != null) {
      return compositeMatch.group(1);
    }

    return null;
  }

  Future<void> _renderLayerFeatures(
    int categoryId,
    List<MapLayerFeature> features,
  ) async {
    final geoJsonManager = _geoJsonLayerManager;
    if (geoJsonManager == null) {
      return;
    }

    try {
      // Use GeoJSON layers for efficient rendering
      // Colors will be automatically assigned based on categoryId
      await geoJsonManager.addCategoryLayer(
        categoryId: categoryId,
        features: features,
      );

      debugPrint(
        '✅ Rendered ${features.length} features for category $categoryId using GeoJSON',
      );
    } catch (e, stackTrace) {
      debugPrint('❌ Error rendering layer features: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  // DEPRECATED: Old annotation-based rendering methods removed
  // Now using GeoJsonLayerManager for efficient rendering
  // See VECTOR_TILES_OPTIMIZATION.md for details

  double? _toDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  Future<void> _clearLayerFeatures(int categoryId) async {
    try {
      final geoJsonManager = _geoJsonLayerManager;
      if (geoJsonManager != null) {
        await geoJsonManager.removeCategoryLayer(categoryId);
      }

      debugPrint('Cleared features for category $categoryId');
    } catch (e) {
      debugPrint('Error clearing layer features: $e');
    }
  }

  void _zoomToFeature(MapLayerDetail mapLayer) {
    final mapboxMap = _mapboxMap;
    if (mapboxMap == null) return;

    try {
      if (_shouldSkipCameraForLayer(mapLayer)) {
        debugPrint('Skip camera move for administrative boundary layer');
        return;
      }

      final geometryData = mapLayer.geometryData;
      final geometryType =
          (geometryData['type']?.toString() ?? mapLayer.geometryType)
              .toLowerCase();

      if (geometryType == 'point') {
        // For Point geometry
        final coordinates = geometryData['coordinates'];
        if (coordinates is! List || coordinates.length < 2) return;
        final lng = _toDouble(coordinates.isNotEmpty ? coordinates[0] : null);
        final lat = _toDouble(coordinates.length > 1 ? coordinates[1] : null);
        if (lng == null || lat == null) return;
        final position = Position(lng, lat);

        // Fly to the point with animation
        mapboxMap.flyTo(
          CameraOptions(
            center: Point(coordinates: position),
            zoom: 30.0,
            pitch: 0,
          ),
          MapAnimationOptions(duration: 1500, startDelay: 0),
        );
      } else if (geometryType == 'multipoint') {
        final coordinates = geometryData['coordinates'];
        if (coordinates is! List || coordinates.isEmpty) return;

        double sumLng = 0;
        double sumLat = 0;
        int count = 0;

        for (final coord in coordinates) {
          if (coord is! List || coord.length < 2) continue;
          final lng = _toDouble(coord[0]);
          final lat = _toDouble(coord[1]);
          if (lng == null || lat == null) continue;
          sumLng += lng;
          sumLat += lat;
          count++;
        }

        if (count == 0) return;
        final center = Position(sumLng / count, sumLat / count);

        mapboxMap.flyTo(
          CameraOptions(
            center: Point(coordinates: center),
            zoom: 30.0,
            pitch: 0,
          ),
          MapAnimationOptions(duration: 1500, startDelay: 0),
        );
      } else if (geometryType == 'polygon' || geometryType == 'multipolygon') {
        final coordinatePairs = _extractCoordinatePairs(
          geometryData['coordinates'],
        );
        if (coordinatePairs.isEmpty) return;

        double minLng = double.infinity;
        double maxLng = double.negativeInfinity;
        double minLat = double.infinity;
        double maxLat = double.negativeInfinity;

        for (final pair in coordinatePairs) {
          final lng = _toDouble(pair[0]);
          final lat = _toDouble(pair[1]);
          if (lng == null || lat == null) continue;
          if (lng < minLng) minLng = lng;
          if (lng > maxLng) maxLng = lng;
          if (lat < minLat) minLat = lat;
          if (lat > maxLat) maxLat = lat;
        }

        if (minLng == double.infinity ||
            maxLng == double.negativeInfinity ||
            minLat == double.infinity ||
            maxLat == double.negativeInfinity) {
          return;
        }

        final centerLng = (minLng + maxLng) / 2;
        final centerLat = (minLat + maxLat) / 2;
        final lngDiff = maxLng - minLng;
        final latDiff = maxLat - minLat;
        final maxDiff = lngDiff > latDiff ? lngDiff : latDiff;

        double zoom = 15.5;
        if (maxDiff > 1.5) {
          zoom = 10.5;
        } else if (maxDiff > 0.7) {
          zoom = 11.5;
        } else if (maxDiff > 0.3) {
          zoom = 12.5;
        } else if (maxDiff > 0.12) {
          zoom = 13.5;
        } else if (maxDiff > 0.04) {
          zoom = 14.5;
        }

        mapboxMap.flyTo(
          CameraOptions(
            center: Point(coordinates: Position(centerLng, centerLat)),
            zoom: zoom,
            pitch: 0,
          ),
          MapAnimationOptions(duration: 1500, startDelay: 0),
        );
      }

      debugPrint('Zoomed to feature: ${mapLayer.name}');
    } catch (e) {
      debugPrint('Error zooming to feature: $e');
    }
  }

  bool _shouldSkipCameraForLayer(MapLayerDetail mapLayer) {
    final normalizedName = mapLayer.name.toLowerCase();
    final normalizedGeometryType = mapLayer.geometryType.toLowerCase();

    final metaValues = mapLayer.properties.values
        .map((value) => value.toString().toLowerCase())
        .join(' ');

    final searchable = '$normalizedName $metaValues';

    final isBoundaryLike =
        searchable.contains('đơn vị hành chính') ||
        searchable.contains('hanh chinh') ||
        searchable.contains('cấp xã') ||
        searchable.contains('cap xa') ||
        searchable.contains('ranh giới') ||
        searchable.contains('ranh gioi');

    final isLargeBoundaryGeometry =
        normalizedGeometryType.contains('polygon') ||
        (mapLayer.geometryData['type']?.toString().toLowerCase().contains(
              'polygon',
            ) ??
            false);

    return isBoundaryLike && isLargeBoundaryGeometry;
  }

  List<List<dynamic>> _extractCoordinatePairs(dynamic coordinates) {
    final pairs = <List<dynamic>>[];

    void extract(dynamic value) {
      if (value is List) {
        if (value.length >= 2 && value[0] is num && value[1] is num) {
          pairs.add(value);
          return;
        }

        for (final child in value) {
          extract(child);
        }
      }
    }

    extract(coordinates);
    return pairs;
  }

  @override
  Widget build(BuildContext context) {
    final bottomOverlayBase = MediaQuery.of(context).padding.bottom + 16;
    final isWeatherModeActive = _isPickingCloudLocation || _showCloudPanel;

    final topSafe = MediaQuery.of(context).padding.top;
    final searchTop = topSafe + 16;
    final modeBannerTop = searchTop + 70;

    return Scaffold(
      body: BlocListener<MapCubit, MapState>(
        listener: (context, state) {
          if (state is MapError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: Colors.red,
                duration: const Duration(seconds: 5),
              ),
            );
          } else if (state is MapLayerFeaturesLoaded) {
            // Render features on map
            _renderLayerFeatures(state.categoryId, state.response.mapLayers);
          } else if (state is MapLayerFeaturesCleared) {
            // Clear features from map
            _clearLayerFeatures(state.categoryId);
          } else if (state is MapLayersLoaded) {
            _visibleLayerIds = state.layers
                .where((layer) => layer.isVisible)
                .map((layer) => layer.id)
                .toSet();

            // Auto-load features for visible layers on initial load
            if (_isInitialLoad) {
              for (final layer in state.layers) {
                if (layer.isVisible) {
                  context.read<MapCubit>().loadLayerFeatures(layer.id);
                }
              }
              // Set flag to false after first load
              _isInitialLoad = false;
            }
          } else if (state is MapLayerDetailLoaded) {
            debugPrint('✅ MapLayerDetailLoaded received');
            // When layer detail is loaded, zoom to it and show on map
            final mapLayer = state.response.mapLayer;
            debugPrint('📦 Feature name: ${mapLayer.name}');
            debugPrint('🆔 Feature ID: ${mapLayer.id}');

            final categoryId = int.tryParse(mapLayer.categoryId);

            // Load all features for this category
            if (categoryId != null) {
              context.read<MapCubit>().loadLayerFeatures(categoryId);
            }

            // Zoom to the specific feature
            _zoomToFeature(mapLayer);

            // Show feature info dialog
            debugPrint('🎨 Showing feature info dialog...');
            showDialog(
              context: context,
              builder: (context) => FeatureInfoDialog(feature: mapLayer),
            );
          } else if (state is MapLayerDetailLoading) {
            debugPrint('⏳ Loading layer detail for ID: ${state.layerId}');
          } else if (state is MapError) {
            debugPrint('❌ Map error: ${state.message}');
          }
        },
        child: BlocListener<LocationCubit, LocationState>(
          listener: (context, state) {
            if (state is LocationLoaded && _isTrackingLocation) {
              final position = Position(
                state.location.longitude,
                state.location.latitude,
              );
              _updateUserLocationMarker(position);

              if (_shouldFlyToCurrentLocation) {
                _flyToUserLocation(position);
                _shouldFlyToCurrentLocation = false;
              }
            }
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  SizedBox(
                    width: constraints.maxWidth,
                    height: constraints.maxHeight,
                    child: MapWidget(
                      key: ValueKey(_currentStyle),
                      cameraOptions: CameraOptions(
                        center: Point(
                          coordinates: Position(
                            MapboxConstants.defaultLongitude,
                            MapboxConstants.defaultLatitude,
                          ),
                        ),
                        zoom: MapboxConstants.defaultZoom,
                      ),
                      styleUri: _currentStyle,
                      onMapCreated: _onMapCreated,
                      onStyleLoadedListener: (_) {
                        unawaited(_onMapStyleLoaded());
                      },
                    ),
                  ),

                  if (_showCloudPanel)
                    Positioned.fill(
                      child: GestureDetector(
                        behavior: HitTestBehavior.translucent,
                        onTap: _closeCloudPanel,
                        child: const SizedBox.shrink(),
                      ),
                    ),

                  Positioned(
                    top: searchTop,
                    left: 16,
                    right: 16,
                    child: IgnorePointer(
                      ignoring: _isInteractionLockedByGpsTracking,
                      child: SearchBarWidget(
                        onSearch: (query) {
                          context.read<MapCubit>().searchLayers(query);
                        },
                        onAvatarTap: () {
                          context.goNamed('profile');
                        },
                      ),
                    ),
                  ),

                  // Search results panel
                  Positioned(
                    top: searchTop + 60,
                    left: 16,
                    right: 16,
                    child: const MapSearchResultsPanel(),
                  ),

                  Positioned(
                    left: 16,
                    bottom: bottomOverlayBase + _drawingToolsPanelHeight + 12,
                    child: AnimatedSwitcher(
                      duration: const Duration(milliseconds: 160),
                      switchInCurve: Curves.easeOut,
                      switchOutCurve: Curves.easeIn,
                      child: _isPickingCloudLocation
                          ? const PickLocationHint(
                              key: ValueKey('weather_pick_location_hint'),
                            )
                          : _showCloudPanel
                          ? WeatherQuickInfo(
                              key: const ValueKey('weather_info_panel'),
                              locationText: _cloudLocation == null
                                  ? null
                                  : '${_cloudLocation!.lat.toStringAsFixed(6)}, '
                                        '${_cloudLocation!.lng.toStringAsFixed(6)}',
                              onClose: _closeCloudPanel,
                            )
                          : const SizedBox.shrink(
                              key: ValueKey('weather_info_panel_empty'),
                            ),
                    ),
                  ),

                  Positioned(
                    top: modeBannerTop,
                    left: 16,
                    right: 16,
                    child: Align(
                      alignment: Alignment.topCenter,
                      child: AnimatedSwitcher(
                        duration: const Duration(milliseconds: 180),
                        switchInCurve: Curves.easeOut,
                        switchOutCurve: Curves.easeIn,
                        child: _currentDrawingMode == DrawingMode.none
                            ? const SizedBox.shrink(
                                key: ValueKey('mode_banner_empty'),
                              )
                            : ModeStatusBanner(
                                key: const ValueKey('mode_status_banner'),
                                currentDrawingMode: _currentDrawingMode,
                                polygonAreaHa: _polygonAreaHa,
                                measurementTotalKm: _measurementTotalKm,
                                routeDistanceKm: _routeDistanceKm,
                                routeDurationMinutes: _routeDurationMinutes,
                                gpsDistanceKm: _calculateGpsTrackDistanceKm(
                                  context
                                      .read<MapUiCubit>()
                                      .state
                                      .gpsPolygonPoints,
                                ),
                                gpsDurationText: _formatGpsDurationForBanner(),
                              ),
                      ),
                    ),
                  ),

                  Positioned(
                    top: MediaQuery.of(context).padding.top + 90,
                    right: 16,
                    child: Column(
                      children: [
                        BlocBuilder<NotificationCubit, NotificationState>(
                          builder: (context, state) {
                            final unreadCount = state is NotificationLoaded
                                ? state.response.unreadCount
                                : 0;

                            return Stack(
                              clipBehavior: Clip.none,
                              children: [
                                MapActionButton(
                                  heroTag: 'notifications',
                                  onPressed: _isInteractionLockedByGpsTracking
                                      ? _showTrackingLockedMessage
                                      : () {
                                          Navigator.of(context).push(
                                            MaterialPageRoute(
                                              builder: (context) =>
                                                  const NotificationsScreen(),
                                            ),
                                          );
                                        },
                                  iconPath: ImagePath.iconBell,
                                ),
                                if (unreadCount > 0)
                                  Positioned(
                                    right: -2,
                                    top: -2,
                                    child: Container(
                                      constraints: const BoxConstraints(
                                        minWidth: 18,
                                        minHeight: 18,
                                      ),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 4,
                                        vertical: 1,
                                      ),
                                      decoration: BoxDecoration(
                                        color: Colors.red,
                                        borderRadius: BorderRadius.circular(10),
                                        border: Border.all(
                                          color: Colors.white,
                                          width: 1.5,
                                        ),
                                      ),
                                      alignment: Alignment.center,
                                      child: Text(
                                        unreadCount > 99
                                            ? '99+'
                                            : unreadCount.toString(),
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 10,
                                          fontWeight: FontWeight.w700,
                                          height: 1.0,
                                        ),
                                      ),
                                    ),
                                  ),
                              ],
                            );
                          },
                        ),
                        const SizedBox(height: 12),
                        MapActionButton(
                          heroTag: 'routing',
                          onPressed: _isInteractionLockedByGpsTracking
                              ? _showTrackingLockedMessage
                              : () {
                                  _selectDrawingModeWithAutoClear(
                                    DrawingMode.routing,
                                  );
                                },
                          iconPath: ImagePath.iconRoute,
                          isActive: _currentDrawingMode == DrawingMode.routing,
                        ),

                        const SizedBox(height: 12),
                        MapActionButton(
                          heroTag: 'tools_toggle',
                          onPressed: _isInteractionLockedByGpsTracking
                              ? _showTrackingLockedMessage
                              : _toggleCloudPanel,
                          iconPath: ImagePath.iconWeather,
                          isActive: isWeatherModeActive,
                        ),
                        const SizedBox(height: 12),
                        MapActionButton(
                          heroTag: 'style',
                          onPressed: _isInteractionLockedByGpsTracking
                              ? _showTrackingLockedMessage
                              : _showMapStyleSelectorSheet,
                          iconPath: ImagePath.iconLayer,
                        ),
                        if (_currentDrawingMode == DrawingMode.gpsPolygon) ...[
                          const SizedBox(height: 12),
                          MapActionButton(
                            heroTag: 'gps_stop',
                            onPressed: () {
                              if (!mounted) return;
                              ToastHelper.showInfo(
                                context,
                                'Nhấn giữ nút dừng để xác nhận kết thúc hành trình',
                              );
                            },
                            onLongPress: () async {
                              final confirmed = await _confirmStopGpsTracking();
                              if (!confirmed || !mounted) return;
                              await _selectDrawingModeWithAutoClear(
                                DrawingMode.none,
                              );
                            },
                            iconPath: ImagePath.iconPause,
                            isActive: true,
                          ),
                        ],
                      ],
                    ),
                  ),

                  if (_showLayerPanel)
                    Positioned(
                      left: 16,
                      top: MediaQuery.of(context).padding.top + 136,
                      bottom: MediaQuery.of(context).padding.bottom + 100,
                      width: 300,
                      child: LayerControlPanel(
                        onClose: () => setState(() => _showLayerPanel = false),
                      ),
                    ),

                  const FeatureSelectedPanel(),

                  Positioned(
                    right: 16,
                    bottom: bottomOverlayBase + _drawingToolsPanelHeight + 16,
                    child: IgnorePointer(
                      ignoring: _isInteractionLockedByGpsTracking,
                      child: BlocBuilder<AuthBloc, AuthState>(
                        builder: (context, authState) {
                          final isAuthenticated =
                              authState is AuthAuthenticated;

                          return Column(
                            children: [
                              // Only show add observation button for authenticated users
                              if (isAuthenticated) ...[
                                MapFloatingActionButton(
                                  heroTag: 'add',
                                  backgroundColor: AppColors.successDark,
                                  foregroundColor: AppColors.white,
                                  onPressed: () =>
                                      _onAddObservationPressed(context),
                                  child: Icon(
                                    Icons.camera_enhance,
                                    size: AppDimensions.iconSizeMedium,
                                  ),
                                ),
                                const SizedBox(height: 12),
                              ],
                              MapFloatingActionButton(
                                heroTag: 'location',
                                backgroundColor: _isTrackingLocation
                                    ? AppColors.primary
                                    : AppColors.white,
                                foregroundColor: _isTrackingLocation
                                    ? AppColors.white
                                    : AppColors.primary,
                                onPressed: _onLocationButtonPressed,
                                child: Icon(
                                  _isTrackingLocation
                                      ? Icons.gps_fixed
                                      : Icons.my_location,
                                ),
                              ),
                            ],
                          );
                        },
                      ),
                    ),
                  ),

                  Positioned(
                    left: 16,
                    right: 16,
                    bottom: bottomOverlayBase,
                    child: IgnorePointer(
                      ignoring: _isInteractionLockedByGpsTracking,
                      child: DrawingToolsBar(
                        height: _drawingToolsPanelHeight,
                        activeColor: AppColors.successDark,
                        selectedMode: _currentDrawingMode,
                        onSelectMode: (mode) {
                          _selectDrawingModeWithAutoClear(mode);
                        },
                        onExplore: () {
                          _selectDrawingModeWithAutoClear(DrawingMode.none);
                        },
                      ),
                    ),
                  ),

                  const LocationPermissionBanner(),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
