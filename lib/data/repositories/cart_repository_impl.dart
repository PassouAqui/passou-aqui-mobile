import '../../domain/entities/drug.dart';
import '../services/api_service.dart';
import '../models/drug_dto.dart';

abstract class DrugRepository {
  Future<List<Drug>> getDrugs();
}

class DrugRepositoryImpl implements DrugRepository {
  final ApiService api;

  DrugRepositoryImpl(this.api);

  @override
  Future<List<Drug>> getDrugs() async {
    final response = await api.get('/api/drugs/');
    return (response as List)
        .map((json) => DrugDTO.fromJson(json).toEntity())
        .toList();
  }
}
