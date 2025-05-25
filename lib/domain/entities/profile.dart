class Profile {
  final String username;
  final String email;
  final String? name;
  final String? phone;
  final String? photo;

  const Profile({
    required this.username,
    required this.email,
    this.name,
    this.phone,
    this.photo,
  });

  factory Profile.fromJson(Map<String, dynamic> json) {
    return Profile(
      username: json['username'] as String,
      email: json['email'] as String,
      name: json['name'] as String?,
      phone: json['phone'] as String?,
      photo: json['photo'] as String?,
    );
  }
}
