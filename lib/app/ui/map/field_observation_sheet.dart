import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:app_core/di/injection_container.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:app_core/app/bloc/citizen_feedback/citizen_feedback_cubit.dart';
import 'package:app_core/shared/widgets/toast_helper.dart';
import 'dart:io';

enum _LocationInputChoice { gps, manual }

enum _FeedbackPriority {
  normal('Bình thường', 'normal'),
  high('Cao', 'high'),
  urgent('Khẩn cấp', 'urgent');

  const _FeedbackPriority(this.label, this.apiValue);

  final String label;
  final String apiValue;
}

class FieldObservationSheet extends StatefulWidget {
  final double? initialArea;
  final String? initialLocation;

  const FieldObservationSheet({
    super.key,
    this.initialArea,
    this.initialLocation,
  });

  @override
  State<FieldObservationSheet> createState() => _FieldObservationSheetState();
}

class _FieldObservationSheetState extends State<FieldObservationSheet> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _areaController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  final TextEditingController _manualLocationController =
      TextEditingController();
  final List<File> _selectedImages = [];
  String _location = '';
  _FeedbackPriority _selectedPriority = _FeedbackPriority.normal;
  bool _isFetchingLocation = false;
  bool _isGpsLocation = false; // Track if location is from GPS
  bool _showValidationErrors = false;

  String? get _titleValidationError =>
      _showValidationErrors && _titleController.text.trim().isEmpty
      ? 'Vui lòng nhập tiêu đề phản ánh'
      : null;

  String? get _descriptionValidationError =>
      _showValidationErrors && _descriptionController.text.trim().isEmpty
      ? 'Vui lòng nhập nội dung mô tả'
      : null;

  String? get _locationValidationError =>
      _showValidationErrors && _location.trim().isEmpty
      ? 'Vui lòng chọn vị trí'
      : null;

  String? get _imagesValidationError =>
      _showValidationErrors && _selectedImages.isEmpty
      ? 'Vui lòng chọn ít nhất 1 hình ảnh'
      : null;

  @override
  void initState() {
    super.initState();
    if (widget.initialArea != null) {
      _areaController.text = widget.initialArea!.toStringAsFixed(2);
    }
    if (widget.initialLocation != null) {
      _location = widget.initialLocation!;
      _manualLocationController.text = _location;
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _areaController.dispose();
    _descriptionController.dispose();
    _manualLocationController.dispose();
    super.dispose();
  }

  String _formatLatLng(double lat, double lng) {
    return '${lat.toStringAsFixed(6)}, ${lng.toStringAsFixed(6)}';
  }

  Future<void> _updateLocationFromGps() async {
    if (_isFetchingLocation) return;

    setState(() {
      _isFetchingLocation = true;
    });

    try {
      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        if (mounted) {
          ToastHelper.showWarning(context, 'Vui lòng bật GPS để lấy vị trí');
        }
        Geolocator.openLocationSettings();
        return;
      }

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      if (permission == LocationPermission.denied) {
        if (mounted) {
          ToastHelper.showWarning(
            context,
            'Bạn đã từ chối quyền truy cập vị trí',
          );
        }
        return;
      }

      if (permission == LocationPermission.deniedForever) {
        if (mounted) {
          ToastHelper.showError(
            context,
            'Quyền vị trí bị tắt vĩnh viễn. Vui lòng bật lại trong Cài đặt.',
          );
        }
        openAppSettings();
        return;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      ).timeout(const Duration(seconds: 12));

      final formatted = _formatLatLng(position.latitude, position.longitude);
      if (!mounted) return;
      setState(() {
        _location = formatted;
        _manualLocationController.text = formatted;
        _isGpsLocation = true; // Đánh dấu là vị trí GPS
      });
      if (mounted) {
        ToastHelper.showSuccess(context, 'Đã lấy vị trí GPS thành công');
      }
    } catch (e) {
      if (mounted) {
        ToastHelper.showError(context, 'Không thể lấy vị trí GPS');
      }
    } finally {
      if (mounted) {
        setState(() {
          _isFetchingLocation = false;
        });
      }
    }
  }

  Future<void> _setLocationManually() async {
    _manualLocationController.text = _location;

    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text(
            'Nhập tên vị trí',
            style: TextStyle(fontWeight: FontWeight.w700),
          ),
          content: TextField(
            controller: _manualLocationController,
            autofocus: true,
            textInputAction: TextInputAction.done,
            decoration: const InputDecoration(
              hintText: 'Ví dụ: Cổng chính khu A, Suối đầu nguồn, ...',
            ),
            onSubmitted: (value) => Navigator.pop(context, value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () =>
                  Navigator.pop(context, _manualLocationController.text),
              child: const Text('Xác nhận'),
            ),
          ],
        );
      },
    );

    final value = result?.trim();
    if (value == null) return;
    if (value.isEmpty) {
      if (mounted) {
        ToastHelper.showWarning(context, 'Vui lòng nhập vị trí');
      }
      return;
    }

    setState(() {
      _location = value;
      _isGpsLocation = false; // Vị trí thủ công, không phải GPS
    });
    if (mounted) {
      ToastHelper.showSuccess(context, 'Đã cập nhật vị trí');
    }
  }

  Future<void> _chooseLocationInput() async {
    final choice = await showModalBottomSheet<_LocationInputChoice>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Chọn cách nhập vị trí',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 20),
                _buildImageSourceOption(
                  icon: Icons.gps_fixed_rounded,
                  title: 'Lấy từ GPS',
                  subtitle: 'Tự động lấy tọa độ hiện tại',
                  color: const Color(0xFF10B981),
                  onTap: () => Navigator.pop(context, _LocationInputChoice.gps),
                ),
                const SizedBox(height: 12),
                _buildImageSourceOption(
                  icon: Icons.edit_location_alt_rounded,
                  title: 'Nhập tên vị trí',
                  subtitle: 'Nhập tên/mô tả theo người dùng',
                  color: const Color(0xFF3B82F6),
                  onTap: () =>
                      Navigator.pop(context, _LocationInputChoice.manual),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );

    switch (choice) {
      case _LocationInputChoice.gps:
        await _updateLocationFromGps();
        break;
      case _LocationInputChoice.manual:
        await _setLocationManually();
        break;
      case null:
        break;
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    final ImageSource? source = await showModalBottomSheet<ImageSource>(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5E7EB),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'Chọn nguồn ảnh',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF111827),
                  ),
                ),
                const SizedBox(height: 20),
                _buildImageSourceOption(
                  icon: Icons.camera_alt_rounded,
                  title: 'Chụp ảnh',
                  subtitle: 'Sử dụng camera',
                  color: const Color(0xFF3B82F6),
                  onTap: () => Navigator.pop(context, ImageSource.camera),
                ),
                const SizedBox(height: 12),
                _buildImageSourceOption(
                  icon: Icons.photo_library_rounded,
                  title: 'Chọn từ thư viện',
                  subtitle: 'Chọn ảnh có sẵn',
                  color: const Color(0xFF10B981),
                  onTap: () => Navigator.pop(context, ImageSource.gallery),
                ),
                const SizedBox(height: 12),
              ],
            ),
          ),
        ),
      ),
    );

    if (source != null) {
      final XFile? image = await picker.pickImage(
        source: source,
        maxWidth: 1920,
        maxHeight: 1920,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedImages.add(File(image.path));
        });
      }
    }
  }

  void _removeImage(int index) {
    setState(() {
      _selectedImages.removeAt(index);
    });
  }

  Widget _buildImageSourceOption({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: color.withAlpha(13),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withAlpha(51), width: 1.5),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: Colors.white, size: 24),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF111827),
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: 13,
                      color: Color(0xFF6B7280),
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios_rounded, size: 16, color: color),
          ],
        ),
      ),
    );
  }

  void _handleSubmit() {
    final title = _titleController.text.trim();
    final description = _descriptionController.text.trim();
    final location = _location.trim();
    final hasImages = _selectedImages.isNotEmpty;

    setState(() {
      _showValidationErrors = true;
    });

    if (title.isEmpty ||
        description.isEmpty ||
        location.isEmpty ||
        !hasImages) {
      return;
    }

    // Submit feedback
    context.read<CitizenFeedbackCubit>().submitFeedback(
      title: title,
      content: description,
      location: location,
      priority: _selectedPriority.apiValue,
      images: _selectedImages,
    );
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<CitizenFeedbackCubit, CitizenFeedbackState>(
      listener: (context, state) {
        debugPrint('🔔 CitizenFeedback State: ${state.runtimeType}');

        if (state is CitizenFeedbackSubmitted) {
          debugPrint('✅ Success: Feedback submitted');
          ToastHelper.showSuccess(context, 'Gửi phản ánh thành công!');
          // Delay nhỏ để người dùng thấy toast trước khi đóng
          Future.delayed(const Duration(milliseconds: 500), () {
            if (context.mounted) {
              Navigator.pop(context, true);
            }
          });
        } else if (state is CitizenFeedbackError) {
          debugPrint('❌ Error: ${state.message}');

          // Check if error message contains validation details (multiple lines)
          final errorMessage = state.message.isNotEmpty
              ? state.message
              : 'Không thể gửi phản ánh. Vui lòng thử lại!';

          debugPrint('📢 Showing error: $errorMessage');

          // If error has multiple lines (validation errors), show dialog
          if (errorMessage.contains('\n')) {
            // showDialog(
            //   context: context,
            //   builder: (context) => AlertDialog(
            //     title: const Row(
            //       children: [
            //         Icon(Icons.error_outline, color: Colors.red),
            //         SizedBox(width: 8),
            //         Text('Lỗi gửi phản ánh'),
            //       ],
            //     ),
            //     content: SingleChildScrollView(
            //       child: Text(
            //         errorMessage,
            //         style: const TextStyle(fontSize: 14),
            //       ),
            //     ),
            //     actions: [
            //       TextButton(
            //         onPressed: () => Navigator.pop(context),
            //         child: const Text('Đóng'),
            //       ),
            //     ],
            //   ),
            // );
          } else {
            // Simple error, use toast
            ToastHelper.showError(context, errorMessage);
          }
        }
      },
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.92,
        ),
        decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag Handle
            Container(
              margin: const EdgeInsets.only(top: 12),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFD1D5DB),
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            // Header
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 16, 16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Phản ánh người dân',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF111827),
                            letterSpacing: -0.3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF3F4F6),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'CITIZEN FEEDBACK',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF6B7280),
                              letterSpacing: 0.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    decoration: BoxDecoration(
                      color: const Color(0xFFF3F4F6),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 22,
                        color: Color(0xFF6B7280),
                      ),
                      padding: const EdgeInsets.all(8),
                      constraints: const BoxConstraints(),
                    ),
                  ),
                ],
              ),
            ),

            // Divider
            Container(height: 1, color: const Color(0xFFF3F4F6)),

            // Error Banner
            BlocBuilder<CitizenFeedbackCubit, CitizenFeedbackState>(
              builder: (context, state) {
                if (state is! CitizenFeedbackError) {
                  return const SizedBox.shrink();
                }

                final errorMessage = state.message.isNotEmpty
                    ? state.message
                    : 'Không thể gửi phản ánh. Vui lòng thử lại!';

                return Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFEE2E2),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFFEF4444),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.error_outline_rounded,
                        color: Color(0xFFEF4444),
                        size: 24,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Gửi phản ánh thất bại',
                              style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFFDC2626),
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              errorMessage,
                              style: const TextStyle(
                                fontSize: 13,
                                color: Color(0xFF991B1B),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),

            // Scrollable Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Title Input
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'TIÊU ĐỀ PHẢN ÁNH',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF374151),
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _titleController,
                          onChanged: (_) {
                            if (_showValidationErrors) {
                              setState(() {});
                            }
                          },
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF111827),
                          ),
                          decoration: InputDecoration(
                            hintText: 'Nhập tiêu đề ngắn gọn',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontWeight: FontWeight.w500,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF9FAFB),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color(0xFFE5E7EB),
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color(0xFFE5E7EB),
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color(0xFF10B981),
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 16,
                            ),
                          ),
                        ),
                        if (_titleValidationError != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _titleValidationError!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFDC2626),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Priority Input
                    _buildPrioritySection(),

                    const SizedBox(height: 24),

                    // Photos Section
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            const Text(
                              'HÌNH ẢNH',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w700,
                                color: Color(0xFF374151),
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFF10B981),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${_selectedImages.length}',
                                style: const TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        _buildPhotosGrid(),
                        if (_imagesValidationError != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _imagesValidationError!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFDC2626),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 24),

                    // Location Info
                    _buildLocationSection(),
                    if (_locationValidationError != null) ...[
                      const SizedBox(height: 8),
                      Text(
                        _locationValidationError!,
                        style: const TextStyle(
                          fontSize: 12,
                          color: Color(0xFFDC2626),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],

                    const SizedBox(height: 24),

                    // Description Input
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'NỘI DUNG MÔ TẢ',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: Color(0xFF374151),
                            letterSpacing: 0.3,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _descriptionController,
                          maxLines: 5,
                          onChanged: (_) {
                            if (_showValidationErrors) {
                              setState(() {});
                            }
                          },
                          style: const TextStyle(
                            fontSize: 14,
                            height: 1.6,
                            color: Color(0xFF111827),
                          ),
                          decoration: InputDecoration(
                            hintText:
                                'Nhập mô tả chi tiết về vấn đề cần phản ánh...',
                            hintStyle: TextStyle(
                              color: Colors.grey[400],
                              fontSize: 14,
                              height: 1.6,
                            ),
                            filled: true,
                            fillColor: const Color(0xFFF9FAFB),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color(0xFFE5E7EB),
                                width: 2,
                              ),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color(0xFFE5E7EB),
                                width: 2,
                              ),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(14),
                              borderSide: const BorderSide(
                                color: Color(0xFF10B981),
                                width: 2,
                              ),
                            ),
                            contentPadding: const EdgeInsets.all(16),
                          ),
                        ),
                        if (_descriptionValidationError != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            _descriptionValidationError!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: Color(0xFFDC2626),
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ],
                    ),

                    const SizedBox(height: 28),

                    // Submit Button
                    BlocBuilder<CitizenFeedbackCubit, CitizenFeedbackState>(
                      builder: (context, state) {
                        final isSubmitting = state is CitizenFeedbackSubmitting;

                        return SizedBox(
                          width: double.infinity,
                          height: 56,
                          child: ElevatedButton(
                            onPressed: isSubmitting ? null : _handleSubmit,
                            style: ElevatedButton.styleFrom(
                              backgroundColor: const Color(0xFF111827),
                              foregroundColor: Colors.white,
                              disabledBackgroundColor: const Color(0xFFD1D5DB),
                              elevation: 0,
                              shadowColor: Colors.black.withAlpha(51),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(16),
                              ),
                            ),
                            child: isSubmitting
                                ? const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  )
                                : Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(Icons.send_rounded, size: 20),
                                      SizedBox(width: 10),
                                      Text(
                                        'Gửi phản ánh',
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.w600,
                                          letterSpacing: 0.2,
                                        ),
                                      ),
                                    ],
                                  ),
                          ),
                        );
                      },
                    ),

                    const SizedBox(height: 8),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPhotosGrid() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        ..._selectedImages.asMap().entries.map((entry) {
          final index = entry.key;
          final image = entry.value;
          return _buildImageThumbnail(image, index);
        }),
        _buildAddPhotoButton(),
      ],
    );
  }

  Widget _buildImageThumbnail(File image, int index) {
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.file(image, width: 100, height: 100, fit: BoxFit.cover),
        ),
        Positioned(
          top: 4,
          right: 4,
          child: GestureDetector(
            onTap: () => _removeImage(index),
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.black.withAlpha(153),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Icon(
                Icons.close_rounded,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAddPhotoButton() {
    return GestureDetector(
      onTap: _pickImage,
      child: Container(
        width: 100,
        height: 100,
        decoration: BoxDecoration(
          color: const Color(0xFFF9FAFB),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: const Color(0xFFE5E7EB),
            width: 2,
            style: BorderStyle.solid,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add_a_photo_rounded, size: 28, color: Color(0xFF10B981)),
            SizedBox(height: 4),
            Text(
              'Thêm ảnh',
              style: TextStyle(
                fontSize: 11,
                color: Color(0xFF6B7280),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPrioritySection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'MỨC ĐỘ ƯU TIÊN',
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: Color(0xFF374151),
            letterSpacing: 0.3,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: const Color(0xFFF9FAFB),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFFE5E7EB), width: 2),
          ),
          child: DropdownButtonHideUnderline(
            child: DropdownButton2<_FeedbackPriority>(
              value: _selectedPriority,
              isExpanded: true,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
                color: Color(0xFF111827),
              ),
              buttonStyleData: const ButtonStyleData(
                height: 56,
                padding: EdgeInsets.symmetric(horizontal: 16),
              ),
              iconStyleData: const IconStyleData(
                icon: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: Color(0xFF6B7280),
                ),
              ),
              dropdownStyleData: DropdownStyleData(
                maxHeight: 220,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(color: const Color(0xFFE5E7EB)),
                ),
                offset: const Offset(0, -4),
              ),
              menuItemStyleData: const MenuItemStyleData(height: 48),
              items: _FeedbackPriority.values.map((priority) {
                return DropdownMenuItem<_FeedbackPriority>(
                  value: priority,
                  child: Text(priority.label),
                );
              }).toList(),
              onChanged: (value) {
                if (value == null) return;
                setState(() {
                  _selectedPriority = value;
                });
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLocationSection() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: _isGpsLocation
              ? [
                  const Color(0xFFDBEAFE),
                  const Color(0xFFBFDBFE),
                ] // Xanh dương cho GPS
              : [
                  const Color(0xFFD1FAE5),
                  const Color(0xFFA7F3D0),
                ], // Xanh lá cho manual
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                (_isGpsLocation
                        ? const Color(0xFF3B82F6)
                        : const Color(0xFF10B981))
                    .withAlpha(26),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: _isGpsLocation
                  ? const Color(0xFF3B82F6) // Xanh dương cho GPS
                  : const Color(0xFF10B981), // Xanh lá cho manual
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              _isGpsLocation
                  ? Icons.gps_fixed_rounded
                  : Icons.location_on_rounded,
              color: Colors.white,
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      _isGpsLocation ? 'VỊ TRÍ GPS (WGS84)' : 'VỊ TRÍ (WGS84)',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w700,
                        color: _isGpsLocation
                            ? const Color(0xFF1E40AF)
                            : const Color(0xFF047857),
                        letterSpacing: 0.5,
                      ),
                    ),
                    if (_isGpsLocation) ...[
                      const SizedBox(width: 6),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: const BoxDecoration(
                          color: Color(0xFF3B82F6),
                          shape: BoxShape.circle,
                          boxShadow: [
                            BoxShadow(
                              color: Color(0x663B82F6),
                              blurRadius: 4,
                              spreadRadius: 1,
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  _location.isNotEmpty
                      ? _location
                      : (_isFetchingLocation
                            ? 'Đang lấy vị trí từ GPS...'
                            : 'Chưa chọn vị trí'),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: _isGpsLocation
                        ? const Color(0xFF1E3A8A)
                        : const Color(0xFF065F46),
                  ),
                ),
              ],
            ),
          ),
          if (_isFetchingLocation)
            SizedBox(
              width: 16,
              height: 16,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  _isGpsLocation
                      ? const Color(0xFF3B82F6)
                      : const Color(0xFF059669),
                ),
              ),
            ),
          const SizedBox(width: 10),
          InkWell(
            onTap: _chooseLocationInput,
            borderRadius: BorderRadius.circular(12),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white.withAlpha(179),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withAlpha(204)),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.my_location_rounded,
                    size: 16,
                    color: _isGpsLocation
                        ? const Color(0xFF1E40AF)
                        : const Color(0xFF047857),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'Chọn',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: _isGpsLocation
                          ? const Color(0xFF1E40AF)
                          : const Color(0xFF047857),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<bool?> showFieldObservationSheet(
  BuildContext context, {
  double? initialArea,
  String? initialLocation,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    backgroundColor: Colors.transparent,
    builder: (context) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: BlocProvider<CitizenFeedbackCubit>(
        create: (_) => sl<CitizenFeedbackCubit>(),
        child: FieldObservationSheet(
          initialArea: initialArea,
          initialLocation: initialLocation,
        ),
      ),
    ),
  );
}
