# HƯỚNG DẪN SỬ DỤNG ỨNG DỤNG MOBILE
## Hệ thống Giám sát Môi trường Đăk Lăk

---

## MỤC LỤC

1. [Giới thiệu](#1-giới-thiệu)
2. [Cài đặt ứng dụng](#2-cài-đặt-ứng-dụng)
3. [Đăng nhập](#3-đăng-nhập)
4. [Giao diện chính](#4-giao-diện-chính)
5. [Chức năng bản đồ](#5-chức-năng-bản-đồ)
6. [Quản lý thông báo](#6-quản-lý-thông-báo)
7. [Phản ánh của công dân](#7-phản-ánh-của-công-dân)
8. [Chỉnh sửa dữ liệu bản đồ (Admin)](#8-chỉnh-sửa-dữ-liệu-bản-đồ-admin)
9. [Cài đặt](#9-cài-đặt)
10. [Câu hỏi thường gặp](#10-câu-hỏi-thường-gặp)

---

## 1. GIỚI THIỆU

### 1.1. Tổng quan hệ thống

Hệ thống Giám sát Môi trường Đăk Lăk là giải pháp công nghệ toàn diện giúp quản lý và giám sát chất lượng môi trường trên địa bàn tỉnh. Hệ thống bao gồm:

**Ứng dụng Mobile** (iOS/Android):
- Hiển thị bản đồ tương tác với nhiều lớp dữ liệu môi trường (điểm quan trắc, khu vực bảo vệ, nguồn thải...)
- Nhận thông báo cảnh báo môi trường theo thời gian thực qua WebSocket
- Thu thập phản ánh từ công dân về các vấn đề môi trường (kèm ảnh, vị trí GPS)
- Chế độ khách cho phép xem bản đồ không cần đăng nhập
- Quản trị viên có thể chỉnh sửa dữ liệu bản đồ trực tiếp trên mobile

**Hệ thống Backend**:
- API RESTful cung cấp dữ liệu bản đồ dạng GeoJSON
- WebSocket server gửi thông báo real-time
- Xác thực JWT với phân quyền User/Admin
- Lưu trữ và xử lý phản ánh công dân

**Công nghệ sử dụng**:
- Flutter (Mobile App)
- Mapbox Maps (Hiển thị bản đồ)
- WebSocket (Thông báo real-time)
- GeoJSON (Dữ liệu không gian)
- JWT Authentication (Bảo mật)

### 1.2. Mục đích
Ứng dụng Mobile Giám sát Môi trường Đăk Lăk được phát triển nhằm:
- Cung cấp thông tin môi trường theo thời gian thực
- Hiển thị dữ liệu bản đồ các lớp môi trường với hiệu năng cao (GeoJSON rendering)
- Nhận thông báo cảnh báo môi trường tức thời
- Thu thập phản ánh từ công dân về các vấn đề môi trường
- Tăng cường sự tham gia của cộng đồng trong bảo vệ môi trường

### 1.3. Đối tượng sử dụng
- **Người dùng thông thường**: Xem bản đồ, nhận thông báo, gửi phản ánh
- **Quản trị viên (Admin)**: Toàn quyền chỉnh sửa dữ liệu bản đồ, quản lý phản ánh
- **Khách (Guest)**: Xem bản đồ không cần đăng nhập (không gửi phản ánh)

### 1.4. Yêu cầu hệ thống
- **Android**: Phiên bản 5.0 trở lên
- **iOS**: Phiên bản 11.0 trở lên
- Kết nối Internet ổn định (3G/4G/WiFi)
- Cho phép truy cập vị trí (GPS)
- Cho phép gửi thông báo
- Dung lượng trống: Tối thiểu 100MB

---

## 2. CÀI ĐẶT ỨNG DỤNG

### 2.1. Tải ứng dụng
- **Android**: Tải từ Google Play Store hoặc file APK
- **iOS**: Tải từ App Store

### 2.2. Cấp quyền
Khi mở ứng dụng lần đầu, cần cấp các quyền sau:
- ✅ Truy cập vị trí: Để xác định vị trí hiện tại trên bản đồ
- ✅ Thông báo: Để nhận cảnh báo môi trường
- ✅ Camera/Thư viện ảnh: Để chụp/đính kèm ảnh khi gửi phản ánh

---

## 3. ĐĂNG NHẬP

### 3.1. Đăng nhập bằng tài khoản

**Bước 1**: Mở ứng dụng, màn hình đăng nhập hiển thị

**Bước 2**: Nhập thông tin:
- Tên đăng nhập
- Mật khẩu

**Bước 3**: Nhấn nút **"Đăng nhập"**

**Lưu ý**: 
- Tài khoản được cấp bởi quản trị viên hệ thống
- Nếu quên mật khẩu, liên hệ quản trị viên

### 3.2. Chế độ khách (Guest)

Nếu chưa có tài khoản, có thể sử dụng chế độ khách:

**Bước 1**: Tại màn hình đăng nhập, nhấn **"Tiếp tục với tư cách khách"**

**Bước 2**: Ứng dụng mở với quyền hạn chế:
- ✅ Xem bản đồ
- ✅ Xem thông tin các lớp dữ liệu
- ❌ Không gửi phản ánh
- ❌ Không nhận thông báo
- ❌ Không chỉnh sửa dữ liệu

---

## 4. GIAO DIỆN CHÍNH

### 4.1. Thanh điều hướng dưới (Bottom Navigation)

Giao diện chính có 3 tab:

1. **🗺️ Bản đồ** (Map)
   - Hiển thị bản đồ tương tác
   - Xem các lớp dữ liệu môi trường

2. **🔔 Thông báo** (Notifications)
   - Danh sách thông báo
   - Cảnh báo môi trường
   - Thông báo hệ thống

3. **⚙️ Cài đặt** (Settings)
   - Thông tin tài khoản
   - Cài đặt ứng dụng
   - Đăng xuất

### 4.2. Thanh công cụ trên (Top Bar)

- Logo ứng dụng
- Tên màn hình hiện tại
- Biểu tượng thông báo (có badge số lượng chưa đọc)

---

## 5. CHỨC NĂNG BẢN ĐỒ

### 5.1. Xem bản đồ

**Thao tác cơ bản**:
- **Phóng to/thu nhỏ**: Chụm 2 ngón tay hoặc nhấn nút +/-
- **Di chuyển**: Vuốt ngón tay
- **Xoay**: Xoay 2 ngón tay
- **Nghiêng**: Vuốt 2 ngón tay lên/xuống

### 5.2. Các lớp bản đồ

Ứng dụng hiển thị nhiều lớp dữ liệu môi trường:
- Điểm quan trắc
- Khu vực bảo vệ
- Ranh giới hành chính
- Nguồn thải
- Và nhiều lớp khác...

**Đặc điểm hiển thị**:
- Mỗi loại dữ liệu có màu sắc riêng
- Điểm được gom cụm (cluster) khi zoom nhỏ
- Hiển thị số lượng điểm trong cụm
- Zoom lớn hơn để xem chi tiết từng điểm

### 5.3. Xem thông tin chi tiết

**Bước 1**: Nhấn vào điểm/vùng trên bản đồ

**Bước 2**: Hộp thoại hiển thị thông tin:
- Tên đối tượng
- Loại dữ liệu
- Các thuộc tính chi tiết
- Tọa độ

**Bước 3**: Nhấn **"Đóng"** để thoát

### 5.4. Nút chức năng bản đồ

**📍 Vị trí của tôi**:
- Nhấn để di chuyển bản đồ đến vị trí hiện tại
- Yêu cầu bật GPS

**📊 Zoom đến khu vực có mật độ cao**:
- Tự động di chuyển đến khu vực có nhiều dữ liệu nhất
- Hữu ích khi mới mở ứng dụng

**🗺️ Chọn lớp bản đồ**:
- Bật/tắt hiển thị các lớp dữ liệu
- Chọn nhiều lớp cùng lúc

### 5.5. Gửi phản ánh (Chỉ người dùng đã đăng nhập)

**Bước 1**: Nhấn nút **"📝 Phản ánh"** ở góc dưới bên phải

**Bước 2**: Điền thông tin:
- **Tiêu đề**: Mô tả ngắn gọn vấn đề
- **Nội dung**: Mô tả chi tiết
- **Loại phản ánh**: Chọn từ danh sách
  - Ô nhiễm không khí
  - Ô nhiễm nước
  - Ô nhiễm đất
  - Rác thải
  - Tiếng ồn
  - Khác
- **Vị trí**: Tự động lấy vị trí hiện tại (có thể chỉnh sửa)
- **Ảnh**: Chụp hoặc chọn từ thư viện (tối đa 5 ảnh)

**Bước 3**: Nhấn **"Gửi phản ánh"**

**Bước 4**: Hệ thống xác nhận và lưu phản ánh

**Lưu ý**:
- Phản ánh được gửi đến cơ quan quản lý
- Có thể theo dõi trạng thái xử lý
- Nếu có lỗi, hệ thống hiển thị thông báo chi tiết

---

## 6. QUẢN LÝ THÔNG BÁO

### 6.1. Xem danh sách thông báo

**Bước 1**: Nhấn tab **"🔔 Thông báo"** ở thanh điều hướng

**Bước 2**: Danh sách thông báo hiển thị:
- Thông báo chưa đọc: Nền trắng, chữ đậm
- Thông báo đã đọc: Nền xám nhạt
- Thời gian: Hiển thị tương đối (vd: "2 giờ trước")

### 6.2. Loại thông báo

Mỗi loại có biểu tượng và màu sắc riêng:

- 📘 **Thông tin** (Info): Màu xanh dương
- ⚠️ **Cảnh báo** (Warning): Màu vàng
- 🚨 **Khẩn cấp** (Error): Màu đỏ
- ✅ **Thành công** (Success): Màu xanh lá
- 💬 **Phản hồi** (Feedback): Màu tím
- 🗺️ **Bản đồ** (Map): Màu xanh ngọc

### 6.3. Đọc thông báo

**Bước 1**: Nhấn vào thông báo

**Bước 2**: Thông báo tự động đánh dấu đã đọc

**Bước 3**: Nền chuyển sang màu xám nhạt

### 6.4. Xóa thông báo

**Cách 1: Vuốt để xóa**
- Vuốt thông báo sang trái
- Nhấn nút **"Xóa"** màu đỏ
- Xác nhận xóa

**Cách 2: Menu tùy chọn**
- Nhấn biểu tượng **⋮** ở góc trên bên phải
- Chọn **"Xóa tất cả"**
- Xác nhận xóa toàn bộ thông báo

### 6.5. Đánh dấu đã đọc

**Đánh dấu tất cả đã đọc**:
- Nhấn biểu tượng **⋮** ở góc trên bên phải
- Chọn **"Đánh dấu tất cả đã đọc"**
- Tất cả thông báo chuyển sang trạng thái đã đọc

### 6.6. Làm mới danh sách

**Kéo xuống để làm mới** (Pull to refresh):
- Kéo danh sách xuống
- Thả ra để tải lại
- Hiển thị thông báo mới nhất

### 6.7. Thông báo thời gian thực

Ứng dụng tự động nhận thông báo mới qua WebSocket:
- Không cần làm mới thủ công
- Thông báo mới xuất hiện ngay lập tức
- Badge số lượng cập nhật tự động

---

## 7. PHẢN ÁNH CỦA CÔNG DÂN

### 7.1. Tạo phản ánh mới

Xem mục **5.5. Gửi phản ánh**

### 7.2. Xử lý lỗi

Nếu gửi phản ánh thất bại, hệ thống hiển thị:

**Lỗi xác thực (Validation Error)**:
- Danh sách các trường bị lỗi
- Mô tả chi tiết từng lỗi
- Ví dụ:
  - ❌ Tiêu đề không được để trống
  - ❌ Nội dung phải có ít nhất 10 ký tự
  - ❌ Vui lòng chọn loại phản ánh

**Lỗi hệ thống**:
- Thông báo lỗi từ server
- Hướng dẫn khắc phục

### 7.3. Theo dõi phản ánh

- Phản ánh được lưu vào hệ thống
- Cơ quan quản lý sẽ xử lý
- Nhận thông báo khi có cập nhật

---

## 8. CHỈNH SỬA DỮ LIỆU BẢN ĐỒ (ADMIN)

### 8.1. Quyền truy cập

Chỉ tài khoản **Quản trị viên (Admin)** mới có quyền chỉnh sửa dữ liệu bản đồ.

### 8.2. Chỉnh sửa thông tin

**Bước 1**: Nhấn vào điểm/vùng trên bản đồ

**Bước 2**: Hộp thoại hiển thị thông tin

**Bước 3**: Nhấn nút **"✏️ Chỉnh sửa"** (chỉ Admin mới thấy)

**Bước 4**: Chỉnh sửa các trường:
- Tên
- Mô tả
- Các thuộc tính khác (tùy loại dữ liệu)

**Bước 5**: Nhấn **"💾 Lưu"**

**Bước 6**: Hệ thống xác nhận và cập nhật dữ liệu

### 8.3. Hủy chỉnh sửa

Nhấn **"❌ Hủy"** để thoát mà không lưu thay đổi

### 8.4. Xử lý lỗi

Nếu lưu thất bại:
- Kiểm tra kết nối Internet
- Kiểm tra quyền truy cập
- Xem thông báo lỗi chi tiết

---

## 9. CÀI ĐẶT

### 9.1. Thông tin tài khoản

Xem thông tin:
- Tên đăng nhập
- Vai trò (User/Admin)
- Email (nếu có)

### 9.2. Cài đặt ứng dụng

- **Ngôn ngữ**: Tiếng Việt / English
- **Thông báo**: Bật/tắt nhận thông báo
- **Bản đồ**: Chọn kiểu bản đồ mặc định

### 9.3. Đăng xuất

**Bước 1**: Vào tab **"⚙️ Cài đặt"**

**Bước 2**: Nhấn **"Đăng xuất"**

**Bước 3**: Xác nhận đăng xuất

**Bước 4**: Quay về màn hình đăng nhập

---

## 10. CÂU HỎI THƯỜNG GẶP

### 10.1. Không kết nối được server?

**Giải pháp**:
- Kiểm tra kết nối Internet
- Thử chuyển đổi WiFi/4G
- Khởi động lại ứng dụng
- Liên hệ quản trị viên nếu vẫn lỗi

### 10.2. Không nhận được thông báo?

**Giải pháp**:
- Kiểm tra cài đặt thông báo trong điện thoại
- Đảm bảo ứng dụng được phép gửi thông báo
- Kiểm tra kết nối Internet
- Đăng xuất và đăng nhập lại

### 10.3. Bản đồ không hiển thị?

**Giải pháp**:
- Kiểm tra kết nối Internet
- Đợi bản đồ tải xong (có thể mất vài giây)
- Thử zoom in/out
- Khởi động lại ứng dụng

### 10.4. Không gửi được phản ánh?

**Giải pháp**:
- Kiểm tra đã đăng nhập chưa (chế độ khách không gửi được)
- Kiểm tra các trường bắt buộc đã điền đủ chưa
- Xem thông báo lỗi chi tiết
- Thử lại sau vài phút

### 10.5. Quên mật khẩu?

**Giải pháp**:
- Liên hệ quản trị viên hệ thống để đặt lại mật khẩu
- Cung cấp thông tin tài khoản để xác thực

### 10.6. Ứng dụng chạy chậm?

**Giải pháp**:
- Đóng các ứng dụng khác đang chạy
- Xóa cache ứng dụng
- Khởi động lại điện thoại
- Cập nhật phiên bản mới nhất

### 10.7. Làm sao để trở thành Admin?

**Giải pháp**:
- Quyền Admin do quản trị viên hệ thống cấp
- Liên hệ quản trị viên để yêu cầu nâng cấp quyền
- Cung cấp lý do cần quyền Admin

---

## THÔNG TIN LIÊN HỆ

**Hỗ trợ kỹ thuật**:
- Email: support@daklak-env.gov.vn
- Điện thoại: 0263.xxx.xxxx
- Giờ làm việc: 7:30 - 17:00 (Thứ 2 - Thứ 6)

**Địa chỉ**:
Sở Tài nguyên và Môi trường tỉnh Đăk Lăk

---

## LỊCH SỬ CẬP NHẬT

| Phiên bản | Ngày | Nội dung |
|-----------|------|----------|
| 1.0.0 | 03/2026 | Phiên bản đầu tiên |

---

**© 2026 Sở Tài nguyên và Môi trường tỉnh Đăk Lăk**
