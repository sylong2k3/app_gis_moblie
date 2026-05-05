// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Aqua Farm';

  @override
  String get login => 'Login';

  @override
  String get loginSubtitle => 'Enter your email and password to log in';

  @override
  String get email => 'Email';

  @override
  String get password => 'Password';

  @override
  String get confirmPassword => 'Confirm Password';

  @override
  String get rememberMe => 'Remember me';

  @override
  String get forgotPassword => 'Forgot Password?';

  @override
  String get logIn => 'Log In';

  @override
  String get orLoginWith => 'Or login with';

  @override
  String get signUp => 'Sign Up';

  @override
  String get signUpSubtitle => 'Create your account to get started';

  @override
  String get signUpTerms =>
      'By signing up, you agree to our Terms of Service and Privacy Policy';

  @override
  String get alreadyHaveAccount => 'Already have an account?';

  @override
  String get signIn => 'Sign In';

  @override
  String get forgotPasswordTitle => 'Forgot Password';

  @override
  String get forgotPasswordSubtitle =>
      'Enter your email and we will send you a reset link';

  @override
  String get sendResetLink => 'Send Reset Link';

  @override
  String get backToLogin => 'Back to Login';

  @override
  String get resetPasswordTitle => 'Reset Password';

  @override
  String resetPasswordSubtitle(String email) {
    return 'Enter the code sent to $email and your new password';
  }

  @override
  String get confirmationCode => 'Confirmation Code';

  @override
  String get newPassword => 'New Password';

  @override
  String get resetPassword => 'Reset Password';

  @override
  String get back => 'Back';

  @override
  String get verifyEmailTitle => 'Verify Email';

  @override
  String verifyEmailSubtitle(String email) {
    return 'Enter the code sent to $email';
  }

  @override
  String get verify => 'Verify';

  @override
  String get didntReceiveCode => 'Didn\'t receive the code? ';

  @override
  String get resend => 'Resend';

  @override
  String get codeSentAgain => 'Code sent again';

  @override
  String get chooseLanguage => 'Choose language';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get english => 'English';

  @override
  String get emailRequired => 'Email is required';

  @override
  String get invalidEmail => 'Please enter a valid email';

  @override
  String get passwordRequired => 'Password is required';

  @override
  String get passwordTooShort => 'Password must be at least 8 characters';

  @override
  String get passwordUppercase =>
      'Password must contain at least 1 uppercase letter';

  @override
  String get passwordLowercase =>
      'Password must contain at least 1 lowercase letter';

  @override
  String get passwordNumber => 'Password must contain at least 1 number';

  @override
  String get confirmPasswordRequired => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';

  @override
  String get codeRequired => 'Code is required';

  @override
  String get codeMustBe6Digits => 'Code must be 6 digits';

  @override
  String get passwordResetSuccess => 'Password reset successfully';

  @override
  String get emailVerifiedSuccessfully => 'Email verified successfully!';
}
