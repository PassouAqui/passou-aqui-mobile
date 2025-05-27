import 'package:flutter/foundation.dart';
import '../entities/user_preferences.dart';
import '../repositories/user_preferences_repository.dart';

class UserPreferencesUseCase {
  final UserPreferencesRepository _repository;

  UserPreferencesUseCase(this._repository);

  Future<UserPreferences> getPreferences() async {
    try {
      debugPrint('🔍 UserPreferencesUseCase: Getting preferences...');
      final preferences = await _repository.getPreferences();
      debugPrint(
          '✅ UserPreferencesUseCase: Preferences retrieved successfully');
      return preferences;
    } catch (e) {
      debugPrint('❌ UserPreferencesUseCase: Error getting preferences: $e');
      rethrow;
    }
  }

  Future<void> savePreferences(UserPreferences preferences) async {
    try {
      debugPrint('💾 UserPreferencesUseCase: Saving preferences...');
      await _repository.savePreferences(preferences);
      debugPrint('✅ UserPreferencesUseCase: Preferences saved successfully');
    } catch (e) {
      debugPrint('❌ UserPreferencesUseCase: Error saving preferences: $e');
      rethrow;
    }
  }

  Future<void> updatePreferences(UserPreferences preferences) async {
    try {
      debugPrint('🔄 UserPreferencesUseCase: Updating preferences...');
      await _repository.updatePreferences(preferences);
      debugPrint('✅ UserPreferencesUseCase: Preferences updated successfully');
    } catch (e) {
      debugPrint('❌ UserPreferencesUseCase: Error updating preferences: $e');
      rethrow;
    }
  }
}
