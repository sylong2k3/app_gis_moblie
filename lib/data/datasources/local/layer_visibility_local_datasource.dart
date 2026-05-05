import 'package:shared_preferences/shared_preferences.dart';

class LayerVisibilityLocalDataSource {
  final SharedPreferences sharedPreferences;
  static const String _keyVisibleLayers = 'visible_layer_ids';

  LayerVisibilityLocalDataSource({required this.sharedPreferences});

  /// Get list of visible layer IDs
  Future<Set<int>> getVisibleLayerIds() async {
    final List<String>? layerIds = sharedPreferences.getStringList(
      _keyVisibleLayers,
    );
    if (layerIds == null) return {};
    return layerIds.map((id) => int.parse(id)).toSet();
  }

  /// Set a layer as visible
  Future<void> setLayerVisible(int layerId) async {
    final visibleIds = await getVisibleLayerIds();
    visibleIds.add(layerId);
    await sharedPreferences.setStringList(
      _keyVisibleLayers,
      visibleIds.map((id) => id.toString()).toList(),
    );
  }

  /// Set a layer as hidden
  Future<void> setLayerHidden(int layerId) async {
    final visibleIds = await getVisibleLayerIds();
    visibleIds.remove(layerId);
    await sharedPreferences.setStringList(
      _keyVisibleLayers,
      visibleIds.map((id) => id.toString()).toList(),
    );
  }

  /// Toggle layer visibility
  Future<bool> toggleLayerVisibility(int layerId) async {
    final visibleIds = await getVisibleLayerIds();
    final isVisible = visibleIds.contains(layerId);

    if (isVisible) {
      visibleIds.remove(layerId);
    } else {
      visibleIds.add(layerId);
    }

    await sharedPreferences.setStringList(
      _keyVisibleLayers,
      visibleIds.map((id) => id.toString()).toList(),
    );

    return !isVisible; // Return new visibility state
  }

  /// Clear all visible layers
  Future<void> clearAllVisibleLayers() async {
    await sharedPreferences.remove(_keyVisibleLayers);
  }
}
