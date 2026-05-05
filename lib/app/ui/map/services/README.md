# Map Services

## GeoJsonLayerManager

Quản lý việc render dữ liệu GIS lớn hiệu quả bằng GeoJSON layers thay vì annotations.

### Sử dụng

```dart
// Khởi tạo
final manager = GeoJsonLayerManager(mapboxMap);

// Thêm layer
await manager.addCategoryLayer(
  categoryId: 1,
  features: features,
  fillColor: 0x4D2196F3,
  fillOutlineColor: 0xFF2196F3,
);

// Xóa layer
await manager.removeCategoryLayer(1);

// Query features khi tap
final results = await manager.queryFeaturesAtPoint(
  point: ScreenCoordinate(x: 100, y: 200),
  categoryId: 1,
);
```

### Lợi ích
- ⚡ Nhanh hơn 10-100x với dữ liệu lớn
- 💾 Tiết kiệm memory
- 🎨 Styling linh hoạt
- 🔄 Dễ quản lý layers

Xem thêm: `VECTOR_TILES_OPTIMIZATION.md`
