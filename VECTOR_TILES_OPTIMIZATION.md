# Vector Tiles Optimization - Tối ưu hiển thị dữ liệu lớn

## Tổng quan

Đã chuyển từ **Annotation-based rendering** sang **GeoJSON Layer rendering** để tối ưu hiệu suất với dữ liệu lớn.

## Lợi ích

### Trước (Annotations):
- ❌ Tạo từng annotation riêng lẻ cho mỗi feature
- ❌ Chậm với dữ liệu lớn (>1000 features)
- ❌ Tốn nhiều memory
- ❌ Khó quản lý khi có nhiều layers

### Sau (GeoJSON Layers):
- ✅ Render toàn bộ layer một lần
- ✅ Nhanh hơn 10-100x với dữ liệu lớn
- ✅ Tiết kiệm memory
- ✅ Dễ quản lý, bật/tắt layer nhanh
- ✅ Hỗ trợ styling linh hoạt
- ✅ Tự động clustering (có thể thêm)

## Cách sử dụng

### 1. GeoJsonLayerManager

```dart
// Khởi tạo (đã tự động trong MapScreen)
_geoJsonLayerManager = GeoJsonLayerManager(_mapboxMap);

// Thêm layer
await _geoJsonLayerManager.addCategoryLayer(
  categoryId: 1,
  features: features,
  fillColor: 0x4D2196F3,
  fillOutlineColor: 0xFF2196F3,
  lineColor: 0xFF2196F3,
  lineWidth: 3.0,
  pointColor: 0xFF2196F3,
  pointRadius: 8.0,
);

// Xóa layer
await _geoJsonLayerManager.removeCategoryLayer(1);

// Xóa tất cả layers
await _geoJsonLayerManager.removeAllLayers();
```

### 2. Query features (tap interaction)

```dart
final features = await _geoJsonLayerManager.queryFeaturesAtPoint(
  point: ScreenCoordinate(x: tapX, y: tapY),
  categoryId: categoryId,
);
```

## Nâng cấp lên Vector Tiles (Backend)

Để đạt hiệu suất tối ưu nhất, backend nên serve Vector Tiles:

### Backend Requirements:
1. Cài đặt tile server (ví dụ: `pg_tileserv`, `tegola`, `martin`)
2. Serve tiles theo format: `/{z}/{x}/{y}.pbf`
3. Endpoint: `https://your-api.com/tiles/{categoryId}/{z}/{x}/{y}.pbf`

### Frontend Update:

```dart
// Thay vì GeoJSON source
await mapboxMap.style.addSource(
  VectorSource(
    id: 'category-$categoryId-source',
    tiles: ['https://your-api.com/tiles/$categoryId/{z}/{x}/{y}.pbf'],
    minzoom: 0,
    maxzoom: 14,
  ),
);

// Add layers như bình thường
await mapboxMap.style.addLayer(
  FillLayer(
    id: 'category-$categoryId-polygon',
    sourceId: 'category-$categoryId-source',
    sourceLayer: 'default', // Tên layer trong tile
    fillColor: 0x4D2196F3,
    fillOutlineColor: 0xFF2196F3,
  ),
);
```

## Performance Tips

### 1. Clustering cho Points
```dart
await mapboxMap.style.addSource(
  GeoJsonSource(
    id: sourceId,
    data: geojson,
    cluster: true,
    clusterMaxZoom: 14,
    clusterRadius: 50,
  ),
);
```

### 2. Simplify geometry cho zoom levels thấp
```dart
// Backend nên simplify geometry dựa trên zoom level
// Zoom 0-8: Simplify tolerance = 0.01
// Zoom 9-12: Simplify tolerance = 0.001
// Zoom 13+: Full detail
```

### 3. Lazy loading
```dart
// Chỉ load features khi zoom vào
if (currentZoom >= 10) {
  await loadLayerFeatures(categoryId);
}
```

## Migration Notes

### Code đã thay đổi:
- ✅ `_renderLayerFeatures()` - Sử dụng GeoJSON thay vì annotations
- ✅ `_clearLayerFeatures()` - Xóa GeoJSON layers
- ✅ `_onMapCreated()` - Khởi tạo GeoJsonLayerManager
- ✅ `_resetAnnotationManagers()` - Reset GeoJSON manager

### Code cũ (deprecated):
- ⚠️ `_renderPolygonFeature()` - Không dùng nữa
- ⚠️ `_renderPointFeature()` - Không dùng nữa
- ⚠️ `_renderLineFeature()` - Không dùng nữa
- ⚠️ `_layerPolygonManagers` - Không dùng nữa
- ⚠️ `_layerPointManagers` - Không dùng nữa
- ⚠️ `_layerPolylineManagers` - Không dùng nữa

## Testing

1. Test với dataset nhỏ (<100 features)
2. Test với dataset trung bình (100-1000 features)
3. Test với dataset lớn (>1000 features)
4. Test bật/tắt nhiều layers cùng lúc
5. Test zoom in/out performance
6. Test tap interaction

## Troubleshooting

### Lỗi: "Layer already exists"
```dart
// Xóa layer cũ trước khi thêm mới
await _geoJsonLayerManager.removeCategoryLayer(categoryId);
await _geoJsonLayerManager.addCategoryLayer(...);
```

### Lỗi: "Source not found"
```dart
// Đảm bảo source được thêm trước layer
// GeoJsonLayerManager đã xử lý tự động
```

### Features không hiển thị
```dart
// Check geometry data format
print('Geometry: ${feature.geometryData}');
// Phải đúng GeoJSON format: {"type": "Point", "coordinates": [lng, lat]}
```

## Next Steps

1. ✅ Implement GeoJSON rendering (Done)
2. ⬜ Add clustering cho point layers
3. ⬜ Add feature selection/highlight
4. ⬜ Implement Vector Tiles backend
5. ⬜ Add dynamic styling based on properties
6. ⬜ Add layer opacity control
7. ⬜ Add layer ordering/z-index
