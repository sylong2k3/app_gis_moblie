# Flutter Base App

Dự án này là code base, được xây dựng với kiến trúc Clean Architecture để tách biệt rõ ràng các lớp (domain, data, presentation). Nó sử dụng BLoC (Business Logic Component) cho quản lý trạng thái, dependency injection (DI) để quản lý phụ thuộc, và hỗ trợ đa ngôn ngữ (tiếng Anh và tiếng Việt) thông qua localization.

## Cấu trúc chính:
- **lib/**: Chứa mã nguồn chính, chia thành các module như app/ (UI và navigation), data/ (datasources và repositories), domain/ (entities, usecases, services), di/ (injection container), l10n/ (localization), và shared/ (configs chung).
- **assets/**: Chứa hình ảnh, font, icon, và animation.
- **android/, ios/, web/, windows/, linux/, macos/**: Cấu hình cho các nền tảng hỗ trợ.
- **build/** và **test/**: Thư mục build và test tự động.

Dự án đang trong giai đoạn phát triển ban đầu (vừa khởi tạo Git và thêm dependency như json_annotation). Nó có thể là một ứng dụng nông nghiệp hoặc liên quan đến "aqua farm" dựa trên tên file (aqua_farm_mobile.iml), nhưng chưa có mô tả chi tiết trong README. Nếu cần chi tiết hơn, hãy cung cấp thêm thông tin!