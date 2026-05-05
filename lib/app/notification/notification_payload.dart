import 'dart:convert';

class AppNotificationPayload {
  final String? route;
  final Map<String, dynamic> data;

  const AppNotificationPayload({required this.data, this.route});

  factory AppNotificationPayload.fromJsonString(String jsonString) {
    final decoded = jsonDecode(jsonString);
    if (decoded is Map<String, dynamic>) {
      return AppNotificationPayload(
        data: decoded,
        route: decoded['route'] as String?,
      );
    }
    return const AppNotificationPayload(data: <String, dynamic>{});
  }
}
