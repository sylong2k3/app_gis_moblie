import 'package:app_core/app/bloc/auth/auth_bloc.dart';
import 'package:app_core/shared/constants/app_colors.dart';
import 'package:app_core/shared/constants/app_dimensions.dart';
import 'package:app_core/shared/themes/app_text_styles.dart';
import 'package:app_core/shared/widgets/toast_helper.dart';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:app_core/domain/entities/user_profile_entity.dart';
import 'package:url_launcher/url_launcher.dart';

const String _usageGuidePdfUrl =
    'http://103.163.119.247:8881/uploads/hdsd-gis-dak-lak.pdf';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Future<UserProfileEntity?>? _profileFuture;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _profileFuture ??= _loadProfile();
  }

  Future<UserProfileEntity?> _loadProfile() async {
    if (!mounted) return null;
    final authRepository = context.read<AuthBloc>().authRepository;
    final result = await authRepository.getUserProfile();
    return result.fold((_) => null, (profile) => profile);
  }

  Future<bool> _tryLaunchUsageGuide(
    Uri uri,
    LaunchMode mode, {
    BrowserConfiguration? browserConfiguration,
  }) async {
    try {
      if (mode == LaunchMode.inAppBrowserView) {
        return await launchUrl(
          uri,
          mode: mode,
          browserConfiguration:
              browserConfiguration ?? const BrowserConfiguration(),
        );
      }
      return await launchUrl(uri, mode: mode);
    } catch (error) {
      debugPrint('Failed to open usage guide with $mode: $error');
      return false;
    }
  }

  Future<void> _openUsageGuidePdf() async {
    final uri = Uri.parse(_usageGuidePdfUrl);

    final launchModes = Platform.isIOS
        ? <LaunchMode>[
            LaunchMode.externalApplication,
            LaunchMode.inAppBrowserView,
          ]
        : <LaunchMode>[
            LaunchMode.inAppBrowserView,
            LaunchMode.externalApplication,
          ];

    for (final mode in launchModes) {
      final opened = await _tryLaunchUsageGuide(
        uri,
        mode,
        browserConfiguration: const BrowserConfiguration(showTitle: true),
      );
      if (opened) {
        return;
      }
    }

    if (mounted) {
      ToastHelper.showError(
        context,
        'Không thể mở tài liệu hướng dẫn. Vui lòng kiểm tra trình duyệt hoặc kết nối mạng.',
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return FutureBuilder<UserProfileEntity?>(
      future: _profileFuture,
      builder: (context, snapshot) {
        final profile = snapshot.data;

        final fullName = (profile?.fullName ?? '').trim();
        final userEmail = (profile?.email ?? '').trim();

        final roleName = (profile?.role?.nameVi ?? '').trim();

        return BlocListener<AuthBloc, AuthState>(
          listenWhen: (previous, current) => current is AuthUnauthenticated,
          listener: (context, state) {
            context.goNamed('signIn');
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text(
                'Hồ sơ cá nhân',
                style: AppTextStyles.textHeader.copyWith(
                  color: AppColors.textDarkPrimary,
                  fontWeight: FontWeight.bold,
                ),
              ),
              automaticallyImplyLeading: false,
              centerTitle: false,
              backgroundColor: AppColors.successDark,
              elevation: 0,
              actions: [
                Padding(
                  padding: const EdgeInsets.only(right: 8.0),
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      if (context.canPop()) {
                        context.pop();
                      } else {
                        context.goNamed('main');
                      }
                    },
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.white.withAlpha(22), // nền mờ
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha(20),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Icon(
                        Icons.close,
                        size: AppDimensions.iconSizeExtraSmall,
                        color: AppColors.textDarkPrimary,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            // backgroundColor: const Color(0xFF0F7B6C),
            body: Container(
              color: AppColors.successDark,
              child: Column(
                children: [
                  // Header section
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 60,
                              height: 60,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.person_outline,
                                size: 32,
                                color: Color(0xFF0F7B6C),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fullName.isNotEmpty ? fullName : userEmail,
                                    style: AppTextStyles.textHeader.copyWith(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.white,
                                    ),
                                  ),
                                  SizedBox(height: 4),
                                  Text(
                                    roleName.toUpperCase(),
                                    style: AppTextStyles.bodySmall.copyWith(
                                      color: AppColors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Container(
                            margin: const EdgeInsets.only(left: 76),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.black.withAlpha(50),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.circle,
                                  size: 8,
                                  color: AppColors.success,
                                ),
                                SizedBox(width: 6),
                                Text(
                                  'ĐANG TRỰC TUYẾN',
                                  style: AppTextStyles.bodySmall.copyWith(
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.white,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // Stats section
                  Expanded(
                    child: Container(
                      decoration: BoxDecoration(
                        color: isDark
                            ? const Color(0xFF1E1E1E)
                            : Colors.grey[100],
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(24),
                          topRight: Radius.circular(24),
                        ),
                      ),
                      child: SingleChildScrollView(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Statistics cards
                            Row(
                              children: [
                                _buildStatCard(
                                  icon: Icons.location_on_outlined,
                                  value: '0',
                                  label: 'BÁO CÁO',
                                  color: const Color(0xFF7ED8C8),
                                ),
                                const SizedBox(width: 12),
                                _buildStatCard(
                                  icon: Icons.watch_later_outlined,
                                  value: '0',
                                  label: 'TUẦN TRA',
                                  color: const Color(0xFFB3D4FF),
                                ),
                                const SizedBox(width: 12),
                                _buildStatCard(
                                  icon: Icons.emoji_events_outlined,
                                  value: '0',
                                  label: 'ĐIỂM CHIM',
                                  color: const Color.fromARGB(
                                    255,
                                    232,
                                    214,
                                    112,
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // Section title
                            Text(
                              'THIẾT BỊ & DỮ LIỆU',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[500],
                                letterSpacing: 0.5,
                              ),
                            ),

                            const SizedBox(height: 12),

                            // Menu items
                            _buildMenuItem(
                              icon: Icons.cloud_outlined,
                              iconColor: const Color(0xFF5B9FED),
                              title: 'Đồng bộ dữ liệu',
                              subtitle: 'Lần cuối: 0 giờ trước',
                              onTap: () {},
                            ),

                            const SizedBox(height: 8),

                            _buildMenuItem(
                              icon: Icons.download_outlined,
                              iconColor: const Color(0xFF5ECC9A),
                              title: 'Bản đồ ngoại tuyến',
                              subtitle: '0 vùng đã tải xuống',
                              onTap: () {},
                            ),

                            const SizedBox(height: 8),

                            _buildMenuItem(
                              icon: Icons.storage_outlined,
                              iconColor: const Color(0xFF9B7FED),
                              title: 'Quản lý bộ nhớ',
                              subtitle: 'Đã dùng 450MB',
                              onTap: () {},
                            ),

                            const SizedBox(height: 8),

                            _buildMenuItem(
                              icon: Icons.settings_outlined,
                              iconColor: Colors.grey[600]!,
                              title: 'Cài đặt hệ thống',
                              subtitle: 'Cấu hình GPS, hiển thị',
                              onTap: () {},
                            ),

                            const SizedBox(height: 24),

                            Text(
                              'HỖ TRỢ',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[500],
                                letterSpacing: 0.5,
                              ),
                            ),

                            const SizedBox(height: 12),

                            _buildMenuItem(
                              icon: Icons.picture_as_pdf_outlined,
                              iconColor: const Color(0xFFEF4444),
                              title: 'Hướng dẫn sử dụng',
                              subtitle: 'Mở file PDF hướng dẫn',
                              onTap: _openUsageGuidePdf,
                            ),

                            const SizedBox(height: 24),

                            // Logout button
                            InkWell(
                              onTap: () {
                                context.read<AuthBloc>().add(
                                  AuthSignOutRequested(),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(
                                      Icons.logout,
                                      color: Colors.red,
                                      size: 20,
                                    ),
                                    SizedBox(width: 8),
                                    Text(
                                      'Đăng xuất tài khoản',
                                      style: TextStyle(
                                        color: Colors.red,
                                        fontSize: 15,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            const SizedBox(height: 16),

                            // Footer
                            Center(
                              child: Text(
                                'ECOGUARD GIS V4.2.0 • BUILD 2024',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: Colors.grey[400],
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildStatCard({
    required IconData icon,
    required String value,
    required String label,
    required Color color,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha((0.05 * 255).round()),
              blurRadius: 10,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withAlpha((0.2 * 255).round()),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: color.withAlpha((0.8 * 255).round()),
                size: 24,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Colors.grey[600],
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMenuItem({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withAlpha((0.03 * 255).round()),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ListTile(
        onTap: onTap,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: iconColor.withAlpha((0.1 * 255).round()),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: iconColor, size: 24),
        ),
        title: Text(
          title,
          style: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: Colors.black87,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: TextStyle(fontSize: 13, color: Colors.grey[600]),
        ),
        trailing: Icon(Icons.chevron_right, color: Colors.grey[400], size: 20),
      ),
    );
  }
}
