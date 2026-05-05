import 'package:app_core/app/bloc/notification/notification_cubit.dart';
import 'package:app_core/domain/entities/notification.dart' as entity;
import 'package:app_core/shared/constants/app_colors.dart';
import 'package:app_core/shared/constants/app_dimensions.dart';
import 'package:app_core/shared/constants/image_path.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:timeago/timeago.dart' as timeago;

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  final ScrollController _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      context.read<NotificationCubit>().loadNotifications();
    });
  }

  void _onScroll() {
    if (!_scrollController.hasClients) return;

    final cubit = context.read<NotificationCubit>();
    final state = cubit.state;
    if (state is! NotificationLoaded) return;

    final maxScroll = _scrollController.position.maxScrollExtent;
    final currentScroll = _scrollController.position.pixels;
    const threshold = 120.0;

    if (maxScroll - currentScroll <= threshold && !cubit.isLoadingMore) {
      cubit.loadMoreNotifications();
    }
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _NotificationsScreenContent(scrollController: _scrollController);
  }
}

class _NotificationsScreenContent extends StatelessWidget {
  final ScrollController scrollController;

  const _NotificationsScreenContent({required this.scrollController});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Thông báo'),
        automaticallyImplyLeading: true,
        actions: [
          BlocBuilder<NotificationCubit, NotificationState>(
            builder: (context, state) {
              if (state is NotificationLoaded) {
                return PopupMenuButton<String>(
                  onSelected: (value) {
                    if (value == 'mark_all_read' &&
                        state.response.notifications.any((n) => !n.isRead)) {
                      context.read<NotificationCubit>().markAllAsRead();
                    } else if (value == 'delete_all' &&
                        state.response.notifications.isNotEmpty) {
                      _showDeleteAllDialog(context);
                    }
                  },
                  itemBuilder: (context) => [
                    if (state.response.notifications.any((n) => !n.isRead))
                      const PopupMenuItem(
                        value: 'mark_all_read',
                        child: Row(
                          children: [
                            Icon(Icons.done_all, size: 20),
                            SizedBox(width: 8),
                            Text('Đánh dấu tất cả đã đọc'),
                          ],
                        ),
                      ),
                    if (state.response.notifications.isNotEmpty)
                      const PopupMenuItem(
                        value: 'delete_all',
                        child: Row(
                          children: [
                            Icon(
                              Icons.delete_sweep,
                              size: 20,
                              color: Colors.red,
                            ),
                            SizedBox(width: 8),
                            Text(
                              'Xóa tất cả',
                              style: TextStyle(color: Colors.red),
                            ),
                          ],
                        ),
                      ),
                  ],
                );
              }
              return const SizedBox.shrink();
            },
          ),
        ],
      ),
      body: BlocBuilder<NotificationCubit, NotificationState>(
        builder: (context, state) {
          if (state is NotificationLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is NotificationError) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error_outline, size: 64, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Lỗi tải thông báo',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey[800],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    state.message,
                    style: const TextStyle(fontSize: 14, color: Colors.grey),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () {
                      context.goNamed('signIn');
                    },
                    child: const Text('Đăng nhập'),
                  ),
                ],
              ),
            );
          }

          if (state is NotificationLoaded) {
            final notifications = state.response.notifications;

            if (notifications.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      ImagePath.iconBell,
                      width: AppDimensions.imageSizeSmall.width,
                      height: AppDimensions.imageSizeSmall.height,
                      color: Colors.grey,
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'Không có thông báo',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              );
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<NotificationCubit>().loadNotifications();
              },
              child: ListView.builder(
                controller: scrollController,
                padding: const EdgeInsets.all(16),
                itemCount:
                    notifications.length +
                    (state.response.page < state.response.totalPages ? 1 : 0),
                itemBuilder: (context, index) {
                  if (index >= notifications.length) {
                    return const Padding(
                      padding: EdgeInsets.symmetric(vertical: 12),
                      child: Center(
                        child: SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        ),
                      ),
                    );
                  }

                  final notification = notifications[index];
                  return Dismissible(
                    key: Key('notification_${notification.id}'),
                    direction: DismissDirection.endToStart,
                    background: Container(
                      alignment: Alignment.centerRight,
                      padding: const EdgeInsets.only(right: 20),
                      color: Colors.red,
                      child: const Icon(
                        Icons.delete,
                        color: Colors.white,
                        size: 28,
                      ),
                    ),
                    confirmDismiss: (direction) async {
                      return await _showDeleteDialog(context);
                    },
                    onDismissed: (direction) {
                      context.read<NotificationCubit>().deleteNotificationById(
                        notification.id,
                      );
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: _NotificationItem(
                        notification: notification,
                        onTap: () {
                          if (!notification.isRead) {
                            context.read<NotificationCubit>().markAsRead(
                              notification.id,
                            );
                          }
                        },
                        onLongPress: () {
                          _showNotificationDetailDialog(context, notification);
                        },
                      ),
                    ),
                  );
                },
              ),
            );
          }

          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Image.asset(
                  ImagePath.iconBell,
                  width: AppDimensions.imageSizeSmall.width,
                  height: AppDimensions.imageSizeSmall.height,
                  color: Colors.grey,
                ),
                const SizedBox(height: 16),
                const Text(
                  'Không có thông báo mới',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.grey,
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _NotificationItem extends StatelessWidget {
  final entity.Notification notification;
  final VoidCallback onTap;
  final VoidCallback onLongPress;

  const _NotificationItem({
    required this.notification,
    required this.onTap,
    required this.onLongPress,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      onLongPress: onLongPress,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: notification.isRead ? Colors.transparent : Colors.blue.shade50,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: _getTypeColor(notification.type).withAlpha(50),
                shape: BoxShape.circle,
              ),
              child: Icon(
                _getTypeIcon(notification.type),
                color: _getTypeColor(notification.type),
                size: 20,
              ),
            ),
            const SizedBox(width: 12),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          notification.title,
                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: notification.isRead
                                ? FontWeight.w500
                                : FontWeight.w600,
                            color: Colors.black87,
                          ),
                        ),
                      ),
                      if (!notification.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: const BoxDecoration(
                            color: Colors.blue,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    notification.message,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    timeago.format(notification.createdAt, locale: 'vi'),
                    style: TextStyle(fontSize: 12, color: Colors.grey[500]),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getTypeIcon(String type) {
    switch (type.toLowerCase()) {
      case 'info':
      case 'info_forest':
        return Icons.info_outline;
      case 'warning':
      case 'alert_forest':
        return Icons.warning_amber_outlined;
      case 'error':
        return Icons.error_outline;
      case 'success':
        return Icons.check_circle_outline;
      case 'feedback':
      case 'feedback_status':
        return Icons.feedback_outlined;
      case 'map':
        return Icons.map_outlined;
      default:
        return Icons.notifications_outlined;
    }
  }

  Color _getTypeColor(String type) {
    switch (type.toLowerCase()) {
      case 'info':
        return Colors.blue;
      case 'warning':
        return Colors.orange;
      case 'info_forest':
        return Colors.green;
      case 'alert_forest':
        return Colors.red;
      case 'error':
        return Colors.red;
      case 'success':
        return Colors.green;
      case 'feedback':
      case 'feedback_status':
        return Colors.purple;
      case 'map':
        return AppColors.primaryDark;
      default:
        return Colors.grey;
    }
  }
}

void _showNotificationDetailDialog(
  BuildContext context,
  entity.Notification notification,
) {
  showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(notification.title),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              notification.message,
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 12),
            Text(
              timeago.format(notification.createdAt, locale: 'vi'),
              style: TextStyle(fontSize: 12, color: Colors.grey[600]),
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Đóng'),
        ),
      ],
    ),
  );
}

Future<bool?> _showDeleteDialog(BuildContext context) {
  return showDialog<bool>(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Xóa thông báo'),
      content: const Text('Bạn có chắc muốn xóa thông báo này?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context, false),
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: () => Navigator.pop(context, true),
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Xóa'),
        ),
      ],
    ),
  );
}

void _showDeleteAllDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: const Text('Xóa tất cả thông báo'),
      content: const Text('Bạn có chắc muốn xóa tất cả thông báo?'),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Hủy'),
        ),
        TextButton(
          onPressed: () {
            Navigator.pop(context);
            context.read<NotificationCubit>().deleteAll();
          },
          style: TextButton.styleFrom(foregroundColor: Colors.red),
          child: const Text('Xóa tất cả'),
        ),
      ],
    ),
  );
}
