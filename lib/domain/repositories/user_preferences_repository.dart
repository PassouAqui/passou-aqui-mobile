import '../entities/user_preferences.dart';

abstract class UserPreferencesRepository {
  /// Saves user preferences to local storage
  Future<void> savePreferences(UserPreferences preferences);

  /// Retrieves user preferences from local storage
  Future<UserPreferences> getPreferences();

  /// Updates specific user preferences
  Future<void> updatePreferences(UserPreferences preferences);
}
