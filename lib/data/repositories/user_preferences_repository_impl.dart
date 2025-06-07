import 'package:flutter/foundation.dart' show debugPrint;
import '../../domain/entities/user_preferences.dart';
import '../../domain/repositories/user_preferences_repository.dart';
import '../database/database_helper.dart';

class UserPreferencesRepositoryImpl implements UserPreferencesRepository {
  final DatabaseHelper _dbHelper;

  UserPreferencesRepositoryImpl(this._dbHelper);

  @override
  Future<UserPreferences> getPreferences() async {
    try {
      debugPrint('🔍 UserPreferencesRepository: Getting preferences...');
      final row = await _dbHelper.queryRow();

      if (row == null) {
        debugPrint(
          '⚠️ UserPreferencesRepository: No preferences found, returning defaults',
        );
        return const UserPreferences();
      }

      final preferences = UserPreferences.fromJson(row);
      debugPrint(
        '✅ UserPreferencesRepository: Preferences retrieved successfully',
      );
      return preferences;
    } catch (e) {
      debugPrint('❌ UserPreferencesRepository: Error getting preferences: $e');
      rethrow;
    }
  }

  @override
  Future<void> savePreferences(UserPreferences preferences) async {
    try {
      debugPrint('💾 UserPreferencesRepository: Saving preferences...');
      final row = await _dbHelper.queryRow();

      if (row == null) {
        await _dbHelper.insert(preferences.toJson());
      } else {
        final updatedRow = preferences.toJson()..['id'] = row['id'];
        await _dbHelper.update(updatedRow);
      }

      debugPrint('✅ UserPreferencesRepository: Preferences saved successfully');
    } catch (e) {
      debugPrint('❌ UserPreferencesRepository: Error saving preferences: $e');
      rethrow;
    }
  }

  @override
  Future<void> updatePreferences(UserPreferences preferences) async {
    try {
      debugPrint('🔄 UserPreferencesRepository: Updating preferences...');
      final row = await _dbHelper.queryRow();

      if (row == null) {
        debugPrint(
          '⚠️ UserPreferencesRepository: No preferences found, creating new ones',
        );
        await _dbHelper.insert(preferences.toJson());
      } else {
        final updatedRow = preferences.toJson()..['id'] = row['id'];
        await _dbHelper.update(updatedRow);
      }

      debugPrint(
        '✅ UserPreferencesRepository: Preferences updated successfully',
      );
    } catch (e) {
      debugPrint('❌ UserPreferencesRepository: Error updating preferences: $e');
      rethrow;
    }
  }
}
