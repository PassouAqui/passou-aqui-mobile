import '../../domain/entities/profile.dart';
import '../api/profile/get_profile.dart';
import '../api/profile/update_profile.dart';

class ProfileService {
  final GetProfileApi _getProfileApi;
  final UpdateProfileApi _updateProfileApi;

  ProfileService(this._getProfileApi, this._updateProfileApi);

  Future<Profile> getProfile() async {
    return await _getProfileApi();
  }

  Future<Profile> updateProfile(Map<String, dynamic> data) async {
    return await _updateProfileApi(data);
  }
}
