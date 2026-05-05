import 'package:flutter/material.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:app_core/shared/configs/mapbox_config.dart';
import 'package:app_core/shared/utils/logger.dart';

class MapboxWidget extends StatefulWidget {
  const MapboxWidget({super.key});

  @override
  State<MapboxWidget> createState() => _MapboxWidgetState();
}

class _MapboxWidgetState extends State<MapboxWidget> {
  MapboxMap? mapboxMap;

  @override
  void initState() {
    super.initState();
    // Validate Mapbox configuration on widget init
    _validateMapboxConfig();
  }

  void _validateMapboxConfig() {
    if (!MapboxConfig.isConfigured) {
      AppLogger.error('Mapbox is not configured properly');
      return;
    }

    final error = MapboxConfig.getConfigError();
    if (error != null) {
      AppLogger.error('Mapbox configuration error: $error');
      return;
    }

    AppLogger.info('Mapbox configured successfully');
  }

  @override
  Widget build(BuildContext context) {
    // Check if Mapbox is properly configured
    if (!MapboxConfig.isConfigured) {
      return _buildErrorWidget(
        'Mapbox Not Configured',
        'Please check your environment configuration',
      );
    }

    final configError = MapboxConfig.getConfigError();
    if (configError != null) {
      return _buildErrorWidget('Mapbox Configuration Error', configError);
    }

    return MapWidget(
      key: const ValueKey('mapWidget'),
      onMapCreated: _onMapCreated,
      cameraOptions: CameraOptions(
        center: Point(
          coordinates: Position(
            MapboxConfig.defaultLongitude,
            MapboxConfig.defaultLatitude,
          ),
        ),
        zoom: MapboxConfig.defaultZoom,
      ),
    );
  }

  Widget _buildErrorWidget(String title, String message) {
    return Container(
      width: double.infinity,
      height: 300,
      decoration: BoxDecoration(
        color: Colors.red[50],
        border: Border.all(color: Colors.red[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 48, color: Colors.red[600]),
          const SizedBox(height: 16),
          Text(
            title,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.red[800],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14, color: Colors.red[600]),
            ),
          ),
        ],
      ),
    );
  }

  void _onMapCreated(MapboxMap mapboxMap) {
    this.mapboxMap = mapboxMap;
    AppLogger.info('Mapbox map created successfully');

    // Add any additional map configuration here
    _configureMap();
  }

  void _configureMap() {
    // Example: Configure map settings
    mapboxMap?.location.updateSettings(
      LocationComponentSettings(
        enabled: true,
        puckBearing: PuckBearing.HEADING,
      ),
    );

    // Add custom styling or behavior here
  }

  @override
  void dispose() {
    mapboxMap = null;
    super.dispose();
  }
}
