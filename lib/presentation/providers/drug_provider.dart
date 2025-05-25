import 'package:flutter/foundation.dart';
import 'package:passou_aqui_mobile/data/repositories/drug_repository.dart';
import 'package:passou_aqui_mobile/domain/entities/drug.dart';

class DrugProvider with ChangeNotifier {
  final DrugRepository _repository;
  List<Drug> _drugs = [];
  bool _isLoading = false;
  String? _error;

  DrugProvider(this._repository);

  List<Drug> get drugs => _drugs;
  bool get isLoading => _isLoading;
  String? get error => _error;

  Future<void> loadDrugs({bool? active}) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      _drugs = await _repository.getDrugs(active: active);
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createDrug(Drug drug) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final newDrug = await _repository.createDrug(drug);
      _drugs.add(newDrug);
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
      final index = _drugs.indexWhere((d) => d.id == id);
      if (index != -1) {
        _drugs[index] = updatedDrug;
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
      _drugs.removeWhere((drug) => drug.id == id);
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

      final index = _drugs.indexWhere((d) => d.id == id);
      if (index != -1) {
        _drugs[index] = _drugs[index].copyWith(ativo: activate);
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
}
