class UserEntity {
  final int id;
  final String email;
  final String firstName;
  final String lastName;
  final bool isActive;

  const UserEntity({
    required this.id,
    required this.email,
    required this.firstName,
    required this.lastName,
    required this.isActive,
  });

  String get fullName => '$firstName $lastName';
}
