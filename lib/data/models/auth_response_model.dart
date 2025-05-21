class AuthResponseModel {
  final String access;
  final String refresh;

  AuthResponseModel({required this.access, required this.refresh});

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) {
    return AuthResponseModel(access: json['access'], refresh: json['refresh']);
  }
}
