import 'package:app_core/shared/constants/api_endpoints.dart';
import 'package:dio/dio.dart';
import 'package:app_core/data/models/map_layer_search_result_model.dart';
import 'package:app_core/data/models/map_layer_model.dart';
import 'package:app_core/data/models/map_layer_feature_model.dart';
import 'package:app_core/data/models/map_layer_detail_model.dart';

abstract class MapRemoteDataSource {
  Future<MapLayerSearchResponseModel> searchMapLayers(String keyword);
  Future<List<MapLayerModel>> getCategories();
  Future<MapLayerFeaturesResponseModel> getMapLayersByCategory(int categoryId);
  Future<MapLayerDetailResponseModel> getMapLayerDetail(String layerId);
}

class MapRemoteDataSourceImpl implements MapRemoteDataSource {
  final Dio dio;

  MapRemoteDataSourceImpl({required this.dio});

  @override
  Future<MapLayerSearchResponseModel> searchMapLayers(String keyword) async {
    try {
      final response = await dio.get(
        ApiEndpoints.searchMap,
        queryParameters: {'q': keyword},
      );

      if (response.statusCode == 200) {
        return MapLayerSearchResponseModel.fromJson(response.data);
      } else {
        throw Exception('Failed to search map layers: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error searching map layers: $e');
    }
  }

  @override
  Future<List<MapLayerModel>> getCategories() async {
    try {
      final response = await dio.get(
        ApiEndpoints.categories,
        queryParameters: {
          'page': 1,
          'is_active': true,
          'sortBy': 'id',
          'sortOrder': 'ASC',
          'limit': 100,
        },
      );

      if (response.statusCode == 200) {
        final data = response.data['data'] as Map<String, dynamic>;
        final categories = data['categories'] as List<dynamic>;

        return categories
            .map((json) => MapLayerModel.fromJson(json as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to get categories: ${response.statusCode}');
      }
    } catch (e) {
      throw Exception('Error getting categories: $e');
    }
  }

  @override
  Future<MapLayerFeaturesResponseModel> getMapLayersByCategory(
    int categoryId,
  ) async {
    try {
      final url = '${ApiEndpoints.mapLayersCategory}/$categoryId';

      final response = await dio.get(url);

      if (response.statusCode == 200) {
        return MapLayerFeaturesResponseModel.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to get map layers by category: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error getting map layers by category: $e');
    }
  }

  @override
  Future<MapLayerDetailResponseModel> getMapLayerDetail(String layerId) async {
    try {
      final url = '${ApiEndpoints.mapLayerApis}/$layerId';

      final response = await dio.get(url);

      if (response.statusCode == 200) {
        return MapLayerDetailResponseModel.fromJson(response.data);
      } else {
        throw Exception(
          'Failed to get map layer detail: ${response.statusCode}',
        );
      }
    } catch (e) {
      throw Exception('Error getting map layer detail: $e');
    }
  }
}
