# Cách hoạt động của GPS Tracking Tool

## Tổng quan
GPS Tracking Tool cho phép người dùng tự động ghi lại các điểm GPS theo thời gian thực và tạo thành một polygon (đa giác) để đo diện tích khu vực.

## Kiến trúc

### 1. State Management (MapUiCubit)
```dart
class MapUiState {
  bool isGpsPolygonTracking;           // Trạng thái đang tracking
  List<Position> gpsPolygonPoints;     // Danh sách các điểm GPS đã ghi
  double polygonAreaHa;                // Diện tích tính bằng hecta
}
```

### 2. Luồng hoạt động

#### Bước 1: Khởi động GPS Tracking
```dart
void _startGpsPolygonTracking() {
  // 1. Lấy LocationRepository và MapUiCubit
  final locationRepository = context.read<LocationCubit>().repository;
  final mapUiCubit = context.read<MapUiCubit>();
  
  // 2. Bật trạng thái tracking trong cubit
  mapUiCubit.startGpsPolygonTracking();
  
  // 3. Đăng ký lắng nghe stream vị trí GPS
  _gpsPolygonSubscription = locationRepository.watchLocation().listen(
    (location) {
      // Xử lý mỗi khi có vị trí GPS mới
    }
  );
}
```

#### Bước 2: Xử lý vị trí GPS mới
Mỗi khi GPS cập nhật vị trí mới (thường 1-5 giây/lần):

```dart
_gpsPolygonSubscription = locationRepository.watchLocation().listen(
  (location) {
    // 1. Kiểm tra còn đang tracking không
    if (!mapUiCubit.state.isGpsPolygonTracking) return;
    
    // 2. Chuyển đổi sang Position
    final position = Position(location.longitude, location.latitude);
    
    // 3. Thêm điểm vào danh sách
    mapUiCubit.addGpsPolygonPoint(position);
    
    // 4. Cập nhật hiển thị trên bản đồ (nếu >= 3 điểm)
    if (mapUiCubit.state.gpsPolygonPoints.length >= 3) {
      _updateGpsPolygon();
    }
  }
);
```

#### Bước 3: Cập nhật hiển thị trên bản đồ
```dart
Future<void> _updateGpsPolygon() async {
  // 1. Lấy danh sách điểm từ cubit
  final gpsPolygonPoints = context.read<MapUiCubit>().state.gpsPolygonPoints;
  
  // 2. Xóa các annotation cũ
  await polygonAnnotationManager.deleteAll();
  await pointAnnotationManager.deleteAll();
  
  // 3. Vẽ các điểm đã ghi (với số thứ tự)
  for (int i = 0; i < gpsPolygonPoints.length; i++) {
    final point = gpsPolygonPoints[i];
    // Tạo marker với label là số thứ tự (1, 2, 3, ...)
    await pointAnnotationManager.create(
      PointAnnotationOptions(
        geometry: Point(coordinates: point),
        iconImage: 'green_marker',
        textField: (i + 1).toString(),
        // ... styling
      )
    );
  }
  
  // 4. Vẽ polygon nếu có >= 3 điểm
  if (gpsPolygonPoints.length >= 3) {
    // Đóng polygon bằng cách thêm điểm đầu vào cuối
    final closedPoints = List<Position>.from(gpsPolygonPoints);
    closedPoints.add(gpsPolygonPoints.first);
    
    // Tạo polygon với màu xanh lá trong suốt
    final polygon = Polygon(coordinates: [closedPoints]);
    await polygonAnnotationManager.create(
      PolygonAnnotationOptions(
        geometry: polygon,
        fillColor: 0x4CAF5050,      // Màu xanh lá 50% opacity
        fillOutlineColor: 0xFF4CAF50, // Viền xanh lá đậm
      )
    );
    
    // 5. Tính diện tích
    final areaHa = _DrawingOperations.calculatePolygonAreaHa(gpsPolygonPoints);
    mapUiCubit.setPolygonArea(areaHa);
  }
}
```

#### Bước 4: Dừng GPS Tracking
```dart
void _stopGpsPolygonTracking() {
  // 1. Hủy subscription
  _gpsPolygonSubscription?.cancel();
  _gpsPolygonSubscription = null;
  
  // 2. Cập nhật state trong cubit
  mapUiCubit.stopGpsPolygonTracking();
}
```

## Các tính năng chính

### 1. Tự động ghi điểm
- Không cần tap trên bản đồ
- GPS tự động cập nhật vị trí theo thời gian thực
- Mỗi điểm được đánh số thứ tự (1, 2, 3, ...)

### 2. Hiển thị trực quan
- **Markers**: Các điểm GPS với số thứ tự
- **Polygon**: Vùng được tô màu xanh lá nhạt khi có >= 3 điểm
- **Outline**: Viền xanh lá đậm bao quanh polygon

### 3. Tính diện tích
- Tự động tính diện tích khi có >= 3 điểm
- Hiển thị kết quả bằng hecta (ha)
- Sử dụng công thức Shoelace để tính diện tích đa giác

### 4. State Management
- Sử dụng BLoC pattern với MapUiCubit
- State được quản lý tập trung, tránh memory leak
- An toàn với lifecycle của widget

## Ưu điểm

1. **Chính xác**: Sử dụng GPS thực tế, không phụ thuộc vào tap tay
2. **Tiện lợi**: Tự động ghi điểm khi di chuyển
3. **Trực quan**: Hiển thị real-time trên bản đồ
4. **An toàn**: Quản lý state tốt, tránh crash khi dispose

## Nhược điểm & Giải pháp

### Vấn đề 1: GPS không chính xác
- **Nguyên nhân**: Tín hiệu GPS yếu, nhiễu
- **Giải pháp**: Sử dụng `LocationAccuracy.high` và filter các điểm có độ chính xác thấp

### Vấn đề 2: Quá nhiều điểm
- **Nguyên nhân**: GPS cập nhật quá nhanh
- **Giải pháp**: Có thể thêm throttle hoặc debounce để giảm tần suất ghi điểm

### Vấn đề 3: Pin tiêu hao
- **Nguyên nhân**: GPS chạy liên tục
- **Giải pháp**: Tự động dừng sau một khoảng thời gian hoặc khi đủ điểm

## Cải tiến có thể thực hiện

1. **Thêm nút "Ghi điểm"**: Cho phép người dùng chủ động ghi điểm thay vì tự động
2. **Lọc điểm**: Loại bỏ các điểm quá gần nhau (< 5m)
3. **Undo/Redo**: Cho phép xóa điểm cuối cùng
4. **Lưu polygon**: Lưu vào database để sử dụng sau
5. **Export**: Xuất ra file GeoJSON hoặc KML

## Ví dụ sử dụng

```dart
// 1. Người dùng nhấn nút "GPS" trong toolbar
onTap: () => onSelectMode!(DrawingMode.gpsPolygon)

// 2. MapScreen nhận mode và bắt đầu tracking
_setDrawingMode(DrawingMode.gpsPolygon);
  -> _startGpsPolygonTracking();

// 3. GPS tự động ghi điểm khi người dùng di chuyển
// Điểm 1: (105.123456, 21.123456)
// Điểm 2: (105.123457, 21.123457)
// Điểm 3: (105.123458, 21.123458)
// ...

// 4. Polygon được vẽ và diện tích được tính
// Diện tích: 2.5 ha

// 5. Người dùng nhấn "Khám phá" để dừng
onTap: onExplore!
  -> _setDrawingMode(DrawingMode.none);
  -> _stopGpsPolygonTracking();
```

## Kết luận

GPS Tracking Tool là một tính năng mạnh mẽ cho phép đo diện tích chính xác bằng cách di chuyển theo biên giới khu vực. Nó kết hợp GPS real-time, state management tốt, và visualization trực quan để mang lại trải nghiệm người dùng tốt nhất.
