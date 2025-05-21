import '../../domain/entities/profile.dart';

class ProfileModel {
  final String username;
  final String email;
  final String? name;
  final String? phone;
  final String? photo;

  ProfileModel({
    required this.username,
    required this.email,
    this.name,
    this.phone,
    this.photo,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) {
    return ProfileModel(
      username: json['username'] ?? '',
      email: json['email'] ?? '',
      name: json['name'],
      phone: json['phone'],
      photo: json['photo'],
    );
  }

  Profile toEntity() {
    return Profile(
      username: username,
      email: email,
      name: name,
      phone: phone,
      photo: photo,
    );
  }
}
