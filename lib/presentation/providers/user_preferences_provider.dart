import 'package:flutter/foundation.dart';
import '../../domain/entities/user_preferences.dart';
import '../../domain/usecases/user_preferences_usecase.dart';

class UserPreferencesProvider extends ChangeNotifier {
  final UserPreferencesUseCase _useCase;
  UserPreferences? _preferences;
  bool _isLoading = false;
  String? _error;

  UserPreferencesProvider(this._useCase);

  UserPreferences? get preferences => _preferences;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadPreferences() async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('🔄 UserPreferencesProvider: Loading preferences...');
      _preferences = await _useCase.getPreferences();
      debugPrint('✅ UserPreferencesProvider: Preferences loaded successfully');
    } catch (e) {
      debugPrint('❌ UserPreferencesProvider: Error loading preferences: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updatePreferences(UserPreferences preferences) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('🔄 UserPreferencesProvider: Updating preferences...');
      await _useCase.updatePreferences(preferences);
      _preferences = preferences;
      debugPrint('✅ UserPreferencesProvider: Preferences updated successfully');
    } catch (e) {
      debugPrint('❌ UserPreferencesProvider: Error updating preferences: $e');
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleDarkMode() async {
    if (_preferences == null) return;
    final updatedPreferences = _preferences!.copyWith(
      darkMode: !_preferences!.darkMode,
    );
    await updatePreferences(updatedPreferences);
  }

  Future<void> toggleHighContrast() async {
    if (_preferences == null) return;
    final updatedPreferences = _preferences!.copyWith(
      highContrast: !_preferences!.highContrast,
    );
    await updatePreferences(updatedPreferences);
  }

  Future<void> updateFontSize(String fontSize) async {
    if (_preferences == null) return;
    final updatedPreferences = _preferences!.copyWith(
      fontSize: fontSize,
    );
    await updatePreferences(updatedPreferences);
  }
}
