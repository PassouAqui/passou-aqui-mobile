import 'package:flutter/foundation.dart';
import 'package:passou_aqui_mobile/data/repositories/drug_repository.dart';
import 'package:passou_aqui_mobile/domain/entities/drug.dart';
import 'package:passou_aqui_mobile/domain/entities/paginated_response.dart';

class DrugProvider with ChangeNotifier {
  final DrugRepository _repository;
  PaginatedResponse<Drug>? _paginatedDrugs;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;

  // Filtros
  bool _showOnlyActive = true;
  Tarja? _selectedTarja;
  String _searchQuery = '';

  DrugProvider(this._repository);

  // Getters para os filtros
  bool get showOnlyActive => _showOnlyActive;
  Tarja? get selectedTarja => _selectedTarja;
  String get searchQuery => _searchQuery;

  // Getters existentes
  List<Drug> get drugs => _paginatedDrugs?.results ?? [];

  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasNext => _paginatedDrugs?.hasNext ?? false;
  bool get hasPrevious => _paginatedDrugs?.hasPrevious ?? false;
  int get currentPage => _currentPage;
  int get totalPages =>
      _paginatedDrugs != null ? (_paginatedDrugs!.count / 10).ceil() : 1;

  Future<void> loadDrugs({bool refresh = false, int? page}) async {
    if (_isLoading) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      // Sempre envia os filtros ativos
      _currentPage = page ?? 1;
      _paginatedDrugs = await _repository.getDrugs(
        active: _showOnlyActive,
        page: _currentPage,
        search: _searchQuery, // Envia mesmo vazio para o backend tratar
        tarja: _selectedTarja,
      );
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ DrugProvider: Erro ao carregar medicamentos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> nextPage() async {
    if (hasNext && !_isLoading) {
      await loadDrugs(page: _currentPage + 1);
    }
  }

  Future<void> previousPage() async {
    if (hasPrevious && !_isLoading) {
      await loadDrugs(page: _currentPage - 1);
    }
  }

  Future<void> goToPage(int page) async {
    if (page > 0 && page <= totalPages && !_isLoading) {
      await loadDrugs(page: page);
    }
  }

  Future<void> createDrug(Drug drug) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newDrug = await _repository.createDrug(drug);
      _paginatedDrugs?.results.add(newDrug);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateDrug(String id, Drug drug) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final updatedDrug = await _repository.updateDrug(id, drug);
      if (_paginatedDrugs != null) {
        final index = _paginatedDrugs!.results.indexWhere((d) => d.id == id);
        if (index != -1) {
          _paginatedDrugs!.results[index] = updatedDrug;
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteDrug(String id) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      await _repository.deleteDrug(id);
      _paginatedDrugs?.results.removeWhere((drug) => drug.id == id);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleDrugStatus(String id, bool activate) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      if (activate) {
        await _repository.activateDrug(id);
      } else {
        await _repository.deactivateDrug(id);
      }

      if (_paginatedDrugs != null) {
        final index = _paginatedDrugs!.results.indexWhere((d) => d.id == id);
        if (index != -1) {
          _paginatedDrugs!.results[index] =
              _paginatedDrugs!.results[index].copyWith(ativo: activate);
        }
      }
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  // Métodos para atualizar filtros
  void setActiveFilter(bool value) {
    if (_showOnlyActive != value) {
      _showOnlyActive = value;
      _currentPage = 1;
      loadDrugs(refresh: true);
    }
  }

  void setTarjaFilter(Tarja? tarja) {
    if (_selectedTarja != tarja) {
      debugPrint(
          '🔍 DrugProvider: Alterando filtro de tarja para: ${tarja?.code}');
      _selectedTarja = tarja;
      _currentPage = 1;
      loadDrugs(refresh: true);
    }
  }

  void setSearchQuery(String query) {
    if (_searchQuery != query) {
      debugPrint('🔍 DrugProvider: Alterando busca para: $query');
      _searchQuery = query;
      _currentPage = 1;
      loadDrugs(refresh: true);
    }
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedTarja = null;
    _showOnlyActive = true;
    _currentPage = 1;
    loadDrugs(refresh: true);
  }
}
