import 'package:app_core/shared/constants/shared_preferences_key.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SaveDeviceToken {
  final SharedPreferences sharedPreferences;

  SaveDeviceToken(this.sharedPreferences);

  Future<void> call(String? token) async {
    if (token == null || token.isEmpty) return;
    await sharedPreferences.setString(SharedPreferencesKey.keyFcmToken, token);
  }
}
