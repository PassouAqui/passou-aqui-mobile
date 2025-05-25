import '../../domain/entities/profile.dart';
import '../../domain/repositories/profile_repository.dart';
import '../services/profile_service.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileService _profileService;

  ProfileRepositoryImpl(this._profileService);

  @override
  Future<Profile> getProfile() async {
    return await _profileService.getProfile();
  }
}
