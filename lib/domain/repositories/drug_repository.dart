import '../entities/drug.dart';

abstract class DrugRepository {
  Future<List<Drug>> getDrugs();
}
