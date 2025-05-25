import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import '../../domain/entities/profile.dart';
import '../../domain/usecases/get_profile_usecase.dart';

class ProfileProvider extends ChangeNotifier {
  final GetProfileUseCase _getProfileUseCase;

  Profile? _profile;
  bool _isLoading = false;
  String? _error;

  ProfileProvider(this._getProfileUseCase);

  Profile? get profile => _profile;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadProfile() async {
    debugPrint('🔄 ProfileProvider: Iniciando carregamento do perfil');
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('🔍 ProfileProvider: Chamando GetProfileUseCase');
      _profile = await _getProfileUseCase();
      debugPrint('✅ ProfileProvider: Perfil carregado com sucesso');
      debugPrint('📦 ProfileProvider: Dados do perfil - ${_profile?.toJson()}');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('❌ ProfileProvider: Erro ao carregar perfil - $e');
      _isLoading = false;
      _error = e.toString();
      notifyListeners();
      rethrow;
    }
  }
}

extension ProfileDebug on Profile {
  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'email': email,
      'name': name,
      'phone': phone,
      'photo': photo,
    };
  }
}
