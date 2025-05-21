import '../models/profile_model.dart';
import 'api_service.dart';

class ProfileService {
  final ApiService _apiService;

  ProfileService(this._apiService);

  Future<ProfileModel> getProfile() async {
    final response = await _apiService.get('accounts/profile/');
    return ProfileModel.fromJson(response);
  }
}
