import 'package:flutter/material.dart';
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
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      debugPrint('🔍 Carregando perfil do usuário...');
      _profile = await _getProfileUseCase();
      debugPrint('✅ Perfil carregado com sucesso!');
      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;

      // Tratamento específico para erro de autenticação
      if (e.toString().contains('401') ||
          e.toString().toLowerCase().contains('unauthorized')) {
        _error =
            'Sessão expirada ou não autorizada. Por favor, faça login novamente.';
        debugPrint('🔒 Erro de autenticação ao carregar perfil: $e');
      } else {
        _error = 'Erro ao carregar perfil: ${e.toString()}';
        debugPrint('❌ Erro ao carregar perfil: $e');
      }

      notifyListeners();
    }
  }
}
