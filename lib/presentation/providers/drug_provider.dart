import 'package:flutter/foundation.dart';
import '../../domain/entities/drug.dart';
import '../../data/services/drug_service.dart';

class DrugProvider extends ChangeNotifier {
  final DrugService _drugService;
  List<Drug> _drugs = [];
  int _totalCount = 0;
  bool _isLoading = false;
  String? _error;
  String? _nextUrl;
  bool _hasMore = true;

  DrugProvider(this._drugService);

  List<Drug> get drugs => _drugs;
  int get totalCount => _totalCount;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;

  Future<void> loadDrugs({bool refresh = false}) async {
    if (_isLoading) return;
    if (refresh) {
      _drugs = [];
      _nextUrl = null;
      _hasMore = true;
    }

    if (!_hasMore && !refresh) return;

    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _drugService.getDrugs(nextUrl: _nextUrl);
      _totalCount = response.count;
      _nextUrl = response.next;
      _hasMore = response.hasNext;

      if (refresh) {
        _drugs = response.results;
      } else {
        _drugs = [..._drugs, ...response.results];
      }
    } catch (e) {
      _error = e.toString();
      debugPrint('❌ Erro ao carregar medicamentos: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> refresh() async {
    await loadDrugs(refresh: true);
  }
}
