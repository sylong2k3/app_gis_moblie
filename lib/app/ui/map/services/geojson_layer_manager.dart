import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';
import 'package:app_core/domain/entities/map_layer_feature.dart';

/// Manages GeoJSON-based layers for efficient rendering of large datasets
class GeoJsonLayerManager {
  final MapboxMap mapboxMap;
  final Set<String> _addedSourceIds = {};
  final Set<String> _addedLayerIds = {};

  // Predefined color palette for different categories
  static const List<Map<String, int>> _categoryColors = [
    {
      'fill': 0x4D2196F3, // Blue with transparency
      'outline': 0xFF2196F3, // Solid blue
    },
    {
      'fill': 0x4DF44336, // Red with transparency
      'outline': 0xFFF44336, // Solid red
    },
    {
      'fill': 0x4D4CAF50, // Green with transparency
      'outline': 0xFF4CAF50, // Solid green
    },
    {
      'fill': 0x4DFF9800, // Orange with transparency
      'outline': 0xFFFF9800, // Solid orange
    },
    {
      'fill': 0x4D9C27B0, // Purple with transparency
      'outline': 0xFF9C27B0, // Solid purple
    },
    {
      'fill': 0x4DFFEB3B, // Yellow with transparency
      'outline': 0xFFFFEB3B, // Solid yellow
    },
    {
      'fill': 0x4D00BCD4, // Cyan with transparency
      'outline': 0xFF00BCD4, // Solid cyan
    },
    {
      'fill': 0x4DFF5722, // Deep orange with transparency
      'outline': 0xFFFF5722, // Solid deep orange
    },
    {
      'fill': 0x4D795548, // Brown with transparency
      'outline': 0xFF795548, // Solid brown
    },
    {
      'fill': 0x4DE91E63, // Pink with transparency
      'outline': 0xFFE91E63, // Solid pink
    },
  ];

  GeoJsonLayerManager(this.mapboxMap);

  /// Get color for a specific category ID
  Map<String, int> _getColorForCategory(int categoryId) {
    final index = (categoryId - 1) % _categoryColors.length;
    return _categoryColors[index];
  }

  /// Add or update a GeoJSON source and layers for a category
  Future<void> addCategoryLayer({
    required int categoryId,
    required List<MapLayerFeature> features,
    int? fillColor,
    int? fillOutlineColor,
    int? lineColor,
    double lineWidth = 3.0,
    int? pointColor,
    double pointRadius = 8.0,
  }) async {
    try {
      final hasNonPointGeometry = features.any((feature) {
        final geometryType =
            (feature.geometryData['type'] as String?)?.toLowerCase() ?? '';
        return geometryType != 'point' && geometryType != 'multipoint';
      });
      final enableClustering = !hasNonPointGeometry;

      // Get auto color for category if not provided
      final categoryColors = _getColorForCategory(categoryId);
      final actualFillColor = fillColor ?? categoryColors['fill']!;
      final actualOutlineColor = fillOutlineColor ?? categoryColors['outline']!;
      final actualLineColor = lineColor ?? categoryColors['outline']!;
      final actualPointColor = pointColor ?? categoryColors['outline']!;


      final sourceId = 'category-$categoryId-source';
      final polygonLayerId = 'category-$categoryId-polygon';
      final polygonOutlineLayerId = 'category-$categoryId-polygon-outline';
      final lineLayerId = 'category-$categoryId-line';
      final pointLayerId = 'category-$categoryId-point';

      // Convert features to GeoJSON
      final geojson = _featuresToGeoJson(features);

      // Remove existing layers and source if any
      await removeCategoryLayer(categoryId);

      // Enable clustering only for point-only datasets.
      // Mixed geometry sources (Point/Line/Polygon) can lose non-point rendering
      // when clustering is enabled.
      await mapboxMap.style.addSource(
        GeoJsonSource(
          id: sourceId,
          data: geojson,
          cluster: enableClustering,
          clusterMaxZoom: 14, // Max zoom to cluster points on
          clusterRadius: 50, // Radius of each cluster when clustering points
        ),
      );
      _addedSourceIds.add(sourceId);


      // Add polygon fill layer (supports both Polygon and MultiPolygon)
      await mapboxMap.style.addLayer(
        FillLayer(
          id: polygonLayerId,
          sourceId: sourceId,
          fillColor: actualFillColor,
          fillOutlineColor: actualOutlineColor,
          // Remove fillOpacity - use alpha channel in fillColor instead
          filter: [
            'any',
            [
              '==',
              ['geometry-type'],
              'Polygon',
            ],
            [
              '==',
              ['geometry-type'],
              'MultiPolygon',
            ],
          ],
        ),
      );
      _addedLayerIds.add(polygonLayerId);

      // Add polygon outline layer (LineLayer for polygon borders)
      await mapboxMap.style.addLayer(
        LineLayer(
          id: polygonOutlineLayerId,
          sourceId: sourceId,
          lineColor: actualOutlineColor,
          lineWidth: 2.0,
          filter: [
            'any',
            [
              '==',
              ['geometry-type'],
              'Polygon',
            ],
            [
              '==',
              ['geometry-type'],
              'MultiPolygon',
            ],
          ],
        ),
      );
      _addedLayerIds.add(polygonOutlineLayerId);

      // Add line layer (supports both LineString and MultiLineString)
      await mapboxMap.style.addLayer(
        LineLayer(
          id: lineLayerId,
          sourceId: sourceId,
          lineColor: actualLineColor,
          lineWidth: lineWidth,
          filter: [
            'any',
            [
              '==',
              ['geometry-type'],
              'LineString',
            ],
            [
              '==',
              ['geometry-type'],
              'MultiLineString',
            ],
          ],
        ),
      );
      _addedLayerIds.add(lineLayerId);

      final clusterLayerId = 'category-$categoryId-cluster';
      if (enableClustering) {
        // Add cluster circle layer (for clustered points)
        await mapboxMap.style.addLayer(
          CircleLayer(
            id: clusterLayerId,
            sourceId: sourceId,
            circleColor: actualPointColor,
            circleRadius: 25.0, // Fixed radius for clusters
            circleStrokeColor: 0xFFFFFFFF,
            circleStrokeWidth: 2.0,
            filter: ['has', 'point_count'], // Only show for clusters
          ),
        );
        _addedLayerIds.add(clusterLayerId);
      }

      // Add cluster count label layer
      final clusterCountLayerId = 'category-$categoryId-cluster-count';
      if (enableClustering) {
        await mapboxMap.style.addLayer(
          SymbolLayer(
            id: clusterCountLayerId,
            sourceId: sourceId,
            textField: '{point_count_abbreviated}', // Show cluster count
            textSize: 14.0,
            textColor: 0xFFFFFFFF, // White text
            filter: ['has', 'point_count'], // Only show for clusters
          ),
        );
        _addedLayerIds.add(clusterCountLayerId);
      }

      final pointBaseFilter = [
        'any',
        [
          '==',
          ['geometry-type'],
          'Point',
        ],
        [
          '==',
          ['geometry-type'],
          'MultiPoint',
        ],
      ];

      final pointFilter = enableClustering
          ? [
              'all',
              [
                '!',
                ['has', 'point_count'],
              ], // Not a cluster
              pointBaseFilter,
            ]
          : pointBaseFilter;

      // Add individual point layer (only for non-clustered points)
      await mapboxMap.style.addLayer(
        CircleLayer(
          id: pointLayerId,
          sourceId: sourceId,
          circleColor: actualPointColor,
          circleRadius: pointRadius,
          circleStrokeColor: 0xFFFFFFFF,
          circleStrokeWidth: 2.0,
          filter: pointFilter,
        ),
      );
      _addedLayerIds.add(pointLayerId);

      // Add symbol layer for individual point labels (only when not clustered)
      final pointLabelLayerId = 'category-$categoryId-point-label';
      await mapboxMap.style.addLayer(
        SymbolLayer(
          id: pointLabelLayerId,
          sourceId: sourceId,
          textField: '{name}', // Use 'name' property from feature
          textSize: 12.0,
          textColor: 0xFF000000, // Black text
          textHaloColor: 0xFFFFFFFF, // White halo for readability
          textHaloWidth: 1.5,
          textOffset: [0.0, 1.5], // Offset below the point
          textAnchor: TextAnchor.TOP,
          filter: pointFilter,
        ),
      );
      _addedLayerIds.add(pointLabelLayerId);
    } catch (e, stackTrace) {
      debugPrint('❌ Error adding category layer: $e');
      debugPrint('Stack trace: $stackTrace');
    }
  }

  /// Remove layers and source for a category
  Future<void> removeCategoryLayer(int categoryId) async {
    try {
      final sourceId = 'category-$categoryId-source';
      final polygonLayerId = 'category-$categoryId-polygon';
      final polygonOutlineLayerId = 'category-$categoryId-polygon-outline';
      final lineLayerId = 'category-$categoryId-line';
      final clusterLayerId = 'category-$categoryId-cluster';
      final clusterCountLayerId = 'category-$categoryId-cluster-count';
      final pointLayerId = 'category-$categoryId-point';
      final pointLabelLayerId = 'category-$categoryId-point-label';

      // Remove layers first (in reverse order)
      for (final layerId in [
        pointLabelLayerId,
        pointLayerId,
        clusterCountLayerId,
        clusterLayerId,
        lineLayerId,
        polygonOutlineLayerId,
        polygonLayerId,
      ]) {
        if (_addedLayerIds.contains(layerId)) {
          try {
            await mapboxMap.style.removeStyleLayer(layerId);
            _addedLayerIds.remove(layerId);
          } catch (e) {
            debugPrint('Layer $layerId not found or already removed');
          }
        }
      }

      // Then remove source
      if (_addedSourceIds.contains(sourceId)) {
        try {
          await mapboxMap.style.removeStyleSource(sourceId);
          _addedSourceIds.remove(sourceId);
        } catch (e) {
          debugPrint('Source $sourceId not found or already removed');
        }
      }

      debugPrint('🗑️ Removed layers for category $categoryId');
    } catch (e) {
      debugPrint('Error removing category layer: $e');
    }
  }

  /// Remove all managed layers and sources
  Future<void> removeAllLayers() async {
    final layerIds = List<String>.from(_addedLayerIds);
    final sourceIds = List<String>.from(_addedSourceIds);

    for (final layerId in layerIds) {
      try {
        await mapboxMap.style.removeStyleLayer(layerId);
        _addedLayerIds.remove(layerId);
      } catch (e) {
        debugPrint('Error removing layer $layerId: $e');
      }
    }

    for (final sourceId in sourceIds) {
      try {
        await mapboxMap.style.removeStyleSource(sourceId);
        _addedSourceIds.remove(sourceId);
      } catch (e) {
        debugPrint('Error removing source $sourceId: $e');
      }
    }
  }

  /// Convert MapLayerFeature list to GeoJSON FeatureCollection
  String _featuresToGeoJson(List<MapLayerFeature> features) {
    final geoJsonFeatures = <Map<String, dynamic>>[];

    for (final feature in features) {
      final geometryType = feature.geometryData['type'] as String?;

      // Handle MultiPolygon by splitting into multiple Polygon features
      if (geometryType == 'MultiPolygon') {
        final coordinates =
            feature.geometryData['coordinates'] as List<dynamic>;

        // MultiPolygon structure: [[[[lng,lat],...]]] - 4 levels
        // Each polygon in MultiPolygon: [[[lng,lat],...]] - 3 levels
        // Polygon needs: [[lng,lat],...] - 2 levels (array of rings)

        for (int i = 0; i < coordinates.length; i++) {
          final polygonCoords = coordinates[i]; // This is [[[lng,lat],...]]

          geoJsonFeatures.add({
            'type': 'Feature',
            'id': '${feature.id}_$i',
            'geometry': {
              'type': 'Polygon',
              'coordinates':
                  polygonCoords, // Use as-is, it's already correct format
            },
            'properties': {
              ...feature.properties,
              'id': feature.id,
              'name': feature.name,
              'category_id': feature.categoryId,
              'is_active': feature.isActive,
              'multi_part': i,
            },
          });
        }
      } else {
        // Regular geometry types
        geoJsonFeatures.add(_featureToGeoJson(feature));
      }
    }

    final featureCollection = {
      'type': 'FeatureCollection',
      'features': geoJsonFeatures,
    };

    final geojsonString = jsonEncode(featureCollection);


    

    return geojsonString;
  }

  /// Convert single MapLayerFeature to GeoJSON Feature
  Map<String, dynamic> _featureToGeoJson(MapLayerFeature feature) {
    final geometryData = feature.geometryData;
    final geometryType = geometryData['type'] as String?;

    // Convert MultiPolygon to Polygon for better Mapbox compatibility
    Map<String, dynamic> geometry = geometryData;

    if (geometryType == 'MultiPolygon') {
      final coordinates = geometryData['coordinates'] as List<dynamic>;

      // MultiPolygon structure: [[[[lng,lat],...]]]
      // If it only has one polygon, convert to Polygon
      if (coordinates.length == 1) {
        geometry = {
          'type': 'Polygon',
          'coordinates': coordinates[0], // Extract the single polygon
        };
        debugPrint(
          '🔄 Converted MultiPolygon to Polygon for feature ${feature.id}',
        );
      }
    }

    return {
      'type': 'Feature',
      'id': feature.id,
      'geometry': geometry,
      'properties': {
        ...feature.properties,
        'id': feature.id,
        'name': feature.name,
        'category_id': feature.categoryId,
        'is_active': feature.isActive,
      },
    };
  }

  /// Query features at a point (for tap interactions)
  Future<List<QueriedRenderedFeature>> queryFeaturesAtPoint({
    required ScreenCoordinate point,
    required int categoryId,
  }) async {
    try {
      final layerIds = [
        'category-$categoryId-polygon',
        'category-$categoryId-line',
        'category-$categoryId-cluster', // Include cluster layer
        'category-$categoryId-point',
        'category-$categoryId-point-label', // Include label layer
      ];

      final results = <QueriedRenderedFeature>[];

      for (final layerId in layerIds) {
        if (!_addedLayerIds.contains(layerId)) continue;

        final features = await mapboxMap.queryRenderedFeatures(
          RenderedQueryGeometry.fromScreenCoordinate(point),
          RenderedQueryOptions(layerIds: [layerId]),
        );

        results.addAll(features.whereType<QueriedRenderedFeature>());
      }

      return results;
    } catch (e) {
      debugPrint('Error querying features: $e');
      return [];
    }
  }

  /// Calculate bounds from features and zoom to fit
  Future<void> zoomToFeatures(List<MapLayerFeature> features) async {
    if (features.isEmpty) return;

    try {
      double minLng = double.infinity;
      double maxLng = double.negativeInfinity;
      double minLat = double.infinity;
      double maxLat = double.negativeInfinity;

      for (final feature in features) {
        final coords = _extractCoordinates(feature.geometryData);
        for (final coord in coords) {
          if (coord.length >= 2) {
            final lng = coord[0];
            final lat = coord[1];
            minLng = minLng < lng ? minLng : lng.toDouble();
            maxLng = maxLng > lng ? maxLng : lng.toDouble();
            minLat = minLat < lat ? minLat : lat.toDouble();
            maxLat = maxLat > lat ? maxLat : lat.toDouble();
          }
        }
      }

      if (minLng != double.infinity && maxLng != double.negativeInfinity) {
        // Calculate center and zoom
        final centerLng = (minLng + maxLng) / 2;
        final centerLat = (minLat + maxLat) / 2;

        // Calculate appropriate zoom level based on bounds
        final lngDiff = maxLng - minLng;
        final latDiff = maxLat - minLat;
        final maxDiff = lngDiff > latDiff ? lngDiff : latDiff;

        // Rough zoom calculation (adjust as needed)
        double zoom = 13;
        if (maxDiff < 0.001) {
          zoom = 18; // Very small area
        } else if (maxDiff < 0.01) {
          zoom = 16;
        } else if (maxDiff < 0.1) {
          zoom = 14;
        } else if (maxDiff < 1) {
          zoom = 13; // For areas like 0.5 degrees
        } else {
          zoom = 10;
        }

        await mapboxMap.setCamera(
          CameraOptions(
            center: Point(coordinates: Position(centerLng, centerLat)),
            zoom: zoom,
          ),
        );
      }
    } catch (e) {
      debugPrint('Error zooming to features: $e');
    }
  }

  /// Zoom to the area with highest feature density
  Future<void> zoomToHighestDensity(List<MapLayerFeature> features) async {
    if (features.isEmpty) return;

    try {
      // Extract all centroids
      final centroids = <Map<String, double>>[];

      for (final feature in features) {
        final coords = _extractCoordinates(feature.geometryData);
        if (coords.isEmpty) continue;

        // Calculate centroid
        double sumLng = 0;
        double sumLat = 0;
        for (final coord in coords) {
          if (coord.length >= 2) {
            sumLng += coord[0].toDouble();
            sumLat += coord[1].toDouble();
          }
        }
        centroids.add({
          'lng': sumLng / coords.length,
          'lat': sumLat / coords.length,
        });
      }

      if (centroids.isEmpty) return;

      // Create grid to find density
      final gridSize = 0.01; // ~1km grid cells
      final densityMap = <String, int>{};

      for (final centroid in centroids) {
        final gridX = (centroid['lng']! / gridSize).floor();
        final gridY = (centroid['lat']! / gridSize).floor();
        final key = '$gridX,$gridY';
        densityMap[key] = (densityMap[key] ?? 0) + 1;
      }

      // Find grid cell with highest density
      String? maxKey;
      int maxDensity = 0;

      densityMap.forEach((key, density) {
        if (density > maxDensity) {
          maxDensity = density;
          maxKey = key;
        }
      });

      if (maxKey != null) {
        final parts = maxKey!.split(',');
        final gridX = int.parse(parts[0]);
        final gridY = int.parse(parts[1]);

        // Calculate center of densest grid cell
        final centerLng = (gridX + 0.5) * gridSize;
        final centerLat = (gridY + 0.5) * gridSize;

        // Use higher zoom for density view
        await mapboxMap.setCamera(
          CameraOptions(
            center: Point(coordinates: Position(centerLng, centerLat)),
            zoom: 15.0,
          ),
        );

      }
    } catch (e) {
      debugPrint('Error zooming to highest density: $e');
    }
  }

  /// Extract all coordinates from geometry data recursively
  List<List<num>> _extractCoordinates(Map<String, dynamic> geometryData) {
    final coords = <List<num>>[];
    final rawCoords = geometryData['coordinates'];

    void extractRecursive(dynamic data) {
      if (data is List) {
        if (data.isNotEmpty && data[0] is num) {
          // This is a coordinate pair [lng, lat]
          coords.add(data.cast<num>());
        } else {
          // This is nested, recurse
          for (final item in data) {
            extractRecursive(item);
          }
        }
      }
    }

    extractRecursive(rawCoords);
    return coords;
  }
}
