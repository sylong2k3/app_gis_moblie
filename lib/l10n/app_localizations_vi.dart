// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Vietnamese (`vi`).
class AppLocalizationsVi extends AppLocalizations {
  AppLocalizationsVi([String locale = 'vi']) : super(locale);

  @override
  String get appTitle => 'Aqua Farm';

  @override
  String get login => 'Đăng nhập';

  @override
  String get loginSubtitle => 'Nhập email và mật khẩu để đăng nhập';

  @override
  String get email => 'Email';

  @override
  String get password => 'Mật khẩu';

  @override
  String get confirmPassword => 'Xác nhận mật khẩu';

  @override
  String get rememberMe => 'Nhớ đăng nhập';

  @override
  String get forgotPassword => 'Quên mật khẩu?';

  @override
  String get logIn => 'Đăng nhập';

  @override
  String get orLoginWith => 'Hoặc đăng nhập bằng';

  @override
  String get signUp => 'Đăng ký';

  @override
  String get signUpSubtitle => 'Tạo tài khoản của bạn để bắt đầu';

  @override
  String get signUpTerms =>
      'Bằng việc đăng ký, bạn đồng ý với Điều khoản dịch vụ và Chính sách bảo mật của chúng tôi';

  @override
  String get alreadyHaveAccount => 'Đã có tài khoản?';

  @override
  String get signIn => 'Đăng nhập';

  @override
  String get forgotPasswordTitle => 'Quên mật khẩu';

  @override
  String get forgotPasswordSubtitle =>
      'Nhập email của bạn và chúng tôi sẽ gửi liên kết đặt lại mật khẩu';

  @override
  String get sendResetLink => 'Gửi liên kết đặt lại';

  @override
  String get backToLogin => 'Quay lại đăng nhập';

  @override
  String get resetPasswordTitle => 'Đặt lại mật khẩu';

  @override
  String resetPasswordSubtitle(String email) {
    return 'Nhập mã được gửi đến $email và mật khẩu mới của bạn';
  }

  @override
  String get confirmationCode => 'Mã xác nhận';

  @override
  String get newPassword => 'Mật khẩu mới';

  @override
  String get resetPassword => 'Đặt lại mật khẩu';

  @override
  String get back => 'Quay lại';

  @override
  String get verifyEmailTitle => 'Xác minh email';

  @override
  String verifyEmailSubtitle(String email) {
    return 'Nhập mã được gửi đến $email';
  }

  @override
  String get verify => 'Xác minh';

  @override
  String get didntReceiveCode => 'Không nhận được mã?';

  @override
  String get resend => 'Gửi lại';

  @override
  String get codeSentAgain => 'Mã đã được gửi lại';

  @override
  String get chooseLanguage => 'Chọn ngôn ngữ';

  @override
  String get vietnamese => 'Tiếng Việt';

  @override
  String get english => 'English';

  @override
  String get emailRequired => 'Email là bắt buộc';

  @override
  String get invalidEmail => 'Vui lòng nhập email hợp lệ';

  @override
  String get passwordRequired => 'Mật khẩu là bắt buộc';

  @override
  String get passwordTooShort => 'Mật khẩu phải có ít nhất 8 ký tự';

  @override
  String get passwordUppercase => 'Mật khẩu phải chứa ít nhất 1 chữ hoa';

  @override
  String get passwordLowercase => 'Mật khẩu phải chứa ít nhất 1 chữ thường';

  @override
  String get passwordNumber => 'Mật khẩu phải chứa ít nhất 1 số';

  @override
  String get confirmPasswordRequired => 'Vui lòng xác nhận mật khẩu';

  @override
  String get passwordsDoNotMatch => 'Mật khẩu không khớp';

  @override
  String get codeRequired => 'Mã là bắt buộc';

  @override
  String get codeMustBe6Digits => 'Mã phải có 6 chữ số';

  @override
  String get passwordResetSuccess => 'Đặt lại mật khẩu thành công';

  @override
  String get emailVerifiedSuccessfully => 'Xác minh email thành công!';
}
