class Profile {
  final String username;
  final String email;
  final String? name;
  final String? phone;
  final String? photo;

  Profile({
    required this.username,
    required this.email,
    this.name,
    this.phone,
    this.photo,
  });
}
