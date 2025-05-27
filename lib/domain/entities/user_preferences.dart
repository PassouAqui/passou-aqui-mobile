import 'package:equatable/equatable.dart';

class UserPreferences extends Equatable {
  final bool darkMode;
  final String fontSize;
  final bool highContrast;

  const UserPreferences({
    this.darkMode = false,
    this.fontSize = 'medium',
    this.highContrast = false,
  });

  UserPreferences copyWith({
    bool? darkMode,
    String? fontSize,
    bool? highContrast,
  }) {
    return UserPreferences(
      darkMode: darkMode ?? this.darkMode,
      fontSize: fontSize ?? this.fontSize,
      highContrast: highContrast ?? this.highContrast,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'darkMode': darkMode ? 1 : 0,
      'fontSize': fontSize,
      'highContrast': highContrast ? 1 : 0,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      darkMode: json['darkMode'] == 1,
      fontSize: json['fontSize'] as String,
      highContrast: json['highContrast'] == 1,
    );
  }

  @override
  List<Object?> get props => [
        darkMode,
        fontSize,
        highContrast,
      ];
}
