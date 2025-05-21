import '../entities/drug.dart';
import '../repositories/drug_repository.dart';

class GetDrugsUseCase {
  final DrugRepository repository;

  GetDrugsUseCase(this.repository);

  Future<List<Drug>> call() async {
    return await repository.getDrugs();
  }
}
