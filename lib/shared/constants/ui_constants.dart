class UIConstants {
  // App info
  static const String appName = 'Flutter Base Bloc';
  static const String appVersion = '1.0.0';
  static const String appCopyright = '© 2024 Your Company';
  static const String appDescription =
      'This is a demo application showing Flutter Clean Architecture with BLoC pattern.';

  // Common UI Text
  static const String textLoading = 'Loading...';
  static const String textUser = 'User';
  static const String textUserEmailPlaceholder = 'user@example.com';
  static const String textNotSignedIn = 'Not signed in';
  static const String textUserNotFound = 'User not found. Please login again.';
  static const String textValueNotAvailable = 'N/A';
  static const String textUserInitialDefault = 'U';

  // Titles
  static const String titleWelcome = 'Welcome'; // New
  static const String titleHome = 'Home';
  static const String titleSettings = 'Settings';
  static const String titleProfile = 'Profile';
  static const String titleLogin = 'Login';
  static const String titleRegister = 'Register';
  static const String titleCreateAccount = 'Create a new account';
  static const String titleLogout = 'Log Out';
  static const String titleErrorPage = 'Error';
  static const String titlePersonalInformation = 'Personal Information';
  static const String titleAccountSettings = 'Account Settings';

  // Settings screen
  static const String sectionAccount = 'Account';
  static const String sectionAppearance = 'Appearance';
  static const String sectionNotifications = 'Notifications';
  static const String sectionAbout = 'About';

  static const String itemProfile = 'Profile';
  static const String itemChangePassword = 'Change Password';
  static const String itemDarkMode = 'Dark Mode';
  static const String itemDarkModeSubtitle = 'Toggle dark mode theme';
  static const String itemLanguage = 'Language';
  static const String itemPushNotifications = 'Push Notifications';
  static const String itemPushNotificationsSubtitle =
      'Allow push notifications';
  static const String itemAboutApp = 'About App';
  static const String itemHelpSupport = 'Help & Support';
  static const String itemPrivacyPolicy = 'Privacy Policy';
  static const String itemEditProfile = 'Edit Profile';
  static const String itemPreferences = 'Preferences';

  static const String buttonLogout = 'LOG OUT';
  static const String msgLogoutConfirm = 'Are you sure you want to log out?';
  static const String buttonCancel = 'CANCEL';

  // Login/Register
  static const String labelEmail = 'Email';
  static const String hintEmail = 'Enter your email';
  static const String labelPassword = 'Password';
  static const String hintPassword = 'Enter your password';
  static const String labelName = 'Name';
  static const String hintName = 'Enter your name';
  static const String labelMemberSince = 'Member since';

  static const String buttonLogin = 'Login';
  static const String buttonRegister = 'Register';
  static const String textNoAccount = 'Don\'t have an account? Register';
  static const String textHaveAccount = 'Already have an account? Login';

  // Validation messages
  static const String validationEmailRequired = 'Please enter your email';
  static const String validationEmailInvalid = 'Please enter a valid email';
  static const String validationPasswordRequired = 'Please enter your password';
  static const String validationPasswordLength =
      'Password must be at least 6 characters';
  static const String validationNameRequired = 'Please enter your name';

  // Regex
  static const String emailRegex = r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$';
  static const int passwordMinLength = 6;

  // Mock implementation messages
  static const String mockThemeUpdate =
      'Theme settings would be updated in a complete implementation';
  static const String mockNotificationUpdate =
      'Notification settings would be updated in a complete implementation';
  static const String mockLanguageUpdate = 'Language set to';

  // Languages (Example constants, you might fetch these or have a more robust system)
  static const String languageDefault = 'English';
  static const String languageEnglish = 'English';
  static const String languageSpanish = 'Spanish';
  static const String languageFrench = 'French';
  static const String languageGerman = 'German';
  static const String languageJapanese = 'Japanese';

  // Home Screen Features (Example)
  static const String textWelcome = 'Welcome';
  static const String featureProductsTitle = 'Products';
  static const String featureProductsDesc = 'Browse available products';
  static const String featureFavoritesTitle = 'Favorites';
  static const String featureFavoritesDesc = 'Your favorite items';
  static const String featureHistoryTitle = 'History';
  static const String featureHistoryDesc = 'View your purchase history';
  static const String featureOffersTitle = 'Offers';
  static const String featureOffersDesc = 'Special deals for you';
  static const String featureProfileTitle =
      'Profile'; // Re-used for Profile item
  static const String featureProfileDesc = 'Manage your profile';
  static const String featureHelpTitle = 'Help';
  static const String featureHelpDesc = 'Get support and FAQs';

  // Error Messages for Routing/Args
  static const String errorProductIdRequired =
      'Product ID is required for this route.';
  static const String errorRouteNotFound =
      'Route not found. Please check the navigation path.';

  // File Manager
  static const String fileManagerTitle = 'File Manager';
  static const String fileManagerDesc = 'Manage your files';
  static const String fileManagerEmpty = 'No files found.';

  // Bottom Navigation Bar for HomeScreen
  static const String bottomNavHome = 'Trang chủ';
  static const String bottomNavServices = 'Dịch vụ';
  static const String bottomNavConfirmation = 'Xác nhận';
  static const String bottomNavMore = 'Khác';
  static const String bottomNavPlaceholder = 'Nội dung cho tab: ';

  // Welcome Screen
  static const String welcomeButtonGuest = 'Guest';
  static const String welcomeButtonViettelSSO = 'Viettel SSO';
  static const String welcomeLogoAltText = 'Viettel Shared Services Logo';

  // Language
  static const String titleSelectLanguage = 'Select Language';
  static const String textLanguage = 'Language';
  static const String textEnglish = 'English';
  static const String textVietnamese = 'Tiếng Việt';
  static const String titleSelectDisplayLanguage =
      'select_display_language_title';
}
