import '../../domain/entities/drug.dart';

class DrugDTO {
  final int id;
  final String name;
  final String description;
  final String imageUrl;

  DrugDTO({
    required this.id,
    required this.name,
    required this.description,
    required this.imageUrl,
  });

  factory DrugDTO.fromJson(Map<String, dynamic> json) => DrugDTO(
    id: json['id'],
    name: json['name'],
    description: json['description'],
    imageUrl: json['image_url'],
  );

  Drug toEntity() =>
      Drug(id: id, name: name, description: description, imageUrl: imageUrl);
}
