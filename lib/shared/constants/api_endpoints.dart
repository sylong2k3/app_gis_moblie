class ApiEndpoints {
  // --- BASE URL ---
  static const String baseUrl = 'http://103.163.119.247:8881/api/v1';

  // --- AUTH ---
  static const String pathAuthLogin = '/auth/login';
  static const String pathAuthRegister = '/auth/register';
  static const String pathAuthConfirmEmail = '/auth/confirm-email';
  static const String pathAuthRefresh = '/auth/refresh';
  static const String pathAuthForgotPassword = '/auth/forgot-password';
  static const String pathAuthResetPassword = '/auth/reset-password';
  static const String pathAuthLogout = '/auth/logout';
  static const String pathAuthChangePassword = '/auth/change-password';
  static const String pathAuthResendCode = '/auth/resend-code';
  static const String pathAuthProfile = '/auth/me';
  static const String pathAuthAccount = '/auth/account';
  static const String pathAuthRefreshToken =
      '/realms/vss/protocol/openid-connect/token';
  static const String pathAuthGuestRefreshToken = '/auth/refresh-token';

  // --- CITIZEN FEEDBACK ---
  static const String pathCitizenFeedbacks = '/citizen-feedbacks';

  // --- DEVICE ---
  static const String searchMap = '/search/map-layers';
  static const String categories = '/categories';
  static const String mapLayersCategory = '/map-layers/category';
  static const String mapLayerApis = '/map-layers';

  // --- NOTIFICATIONS ---
  static const String notifications = '/notifications';
}
