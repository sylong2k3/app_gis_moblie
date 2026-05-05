import 'package:app_core/data/models/map_feature_model.dart';
import 'package:app_core/data/models/map_layer_model.dart';
import 'package:hive/hive.dart';

abstract class MapLocalDataSource {
  Future<List<MapLayerModel>> getCachedLayers();
  Future<void> cacheLayers(List<MapLayerModel> layers);
  Future<MapLayerModel?> getCachedLayerById(String layerId);
  Future<void> cacheLayer(MapLayerModel layer);

  Future<List<MapFeatureModel>> getCachedFeatures(String layerId);
  Future<void> cacheFeatures(String layerId, List<MapFeatureModel> features);
  Future<MapFeatureModel?> getCachedFeatureById(String featureId);
  Future<void> cacheFeature(MapFeatureModel feature);
  Future<void> deleteFeatureFromCache(String featureId);
}

class MapLocalDataSourceImpl implements MapLocalDataSource {
  static const String layersBox = 'map_layers';
  static const String featuresBox = 'map_features';

  @override
  Future<List<MapLayerModel>> getCachedLayers() async {
    final box = await Hive.openBox<Map>(layersBox);
    final layers = box.values
        .map((json) => MapLayerModel.fromJson(Map<String, dynamic>.from(json)))
        .toList();
    return layers;
  }

  @override
  Future<void> cacheLayers(List<MapLayerModel> layers) async {
    final box = await Hive.openBox<Map>(layersBox);
    await box.clear();
    for (var layer in layers) {
      await box.put(layer.id, layer.toJson());
    }
  }

  @override
  Future<MapLayerModel?> getCachedLayerById(String layerId) async {
    final box = await Hive.openBox<Map>(layersBox);
    final json = box.get(layerId);
    if (json == null) return null;
    return MapLayerModel.fromJson(Map<String, dynamic>.from(json));
  }

  @override
  Future<void> cacheLayer(MapLayerModel layer) async {
    final box = await Hive.openBox<Map>(layersBox);
    await box.put(layer.id, layer.toJson());
  }

  @override
  Future<List<MapFeatureModel>> getCachedFeatures(String layerId) async {
    final box = await Hive.openBox<Map>(featuresBox);
    final features = box.values
        .map(
          (json) => MapFeatureModel.fromJson(Map<String, dynamic>.from(json)),
        )
        .where((feature) => feature.properties['layerId'] == layerId)
        .toList();
    return features;
  }

  @override
  Future<void> cacheFeatures(
    String layerId,
    List<MapFeatureModel> features,
  ) async {
    final box = await Hive.openBox<Map>(featuresBox);
    for (var feature in features) {
      final updatedFeature = MapFeatureModel.fromJson({
        ...feature.toJson(),
        'properties': {...feature.properties, 'layerId': layerId},
      });
      await box.put(feature.id, updatedFeature.toJson());
    }
  }

  @override
  Future<MapFeatureModel?> getCachedFeatureById(String featureId) async {
    final box = await Hive.openBox<Map>(featuresBox);
    final json = box.get(featureId);
    if (json == null) return null;
    return MapFeatureModel.fromJson(Map<String, dynamic>.from(json));
  }

  @override
  Future<void> cacheFeature(MapFeatureModel feature) async {
    final box = await Hive.openBox<Map>(featuresBox);
    await box.put(feature.id, feature.toJson());
  }

  @override
  Future<void> deleteFeatureFromCache(String featureId) async {
    final box = await Hive.openBox<Map>(featuresBox);
    await box.delete(featureId);
  }
}
