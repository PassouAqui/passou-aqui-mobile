import '../../domain/entities/drug.dart';
import '../../domain/entities/paginated_response.dart';
import '../api/drugs/get_drugs.dart';

class DrugService {
  final GetDrugsApi _getDrugsApi;

  DrugService(this._getDrugsApi);

  Future<PaginatedResponse<Drug>> getDrugs({String? nextUrl}) async {
    return await _getDrugsApi(nextUrl: nextUrl);
  }
}
