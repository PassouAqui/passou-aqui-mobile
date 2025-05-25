import '../../domain/entities/drug.dart';

class DrugDTO {
  final String id;
  final String nome;
  final String descricao;
  final String tagUid;
  final String lote;
  final DateTime validade;
  final bool ativo;
  final String tarja;

  DrugDTO({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.tagUid,
    required this.lote,
    required this.validade,
    required this.ativo,
    required this.tarja,
  });

  factory DrugDTO.fromJson(Map<String, dynamic> json) => DrugDTO(
        id: json['id'].toString(),
        nome: json['nome'],
        descricao: json['descricao'],
        tagUid: json['tag_uid'],
        lote: json['lote'],
        validade: DateTime.parse(json['validade']),
        ativo: json['ativo'],
        tarja: json['tarja'],
      );

  Drug toEntity() => Drug(
        id: id,
        nome: nome,
        descricao: descricao,
        tagUid: tagUid,
        lote: lote,
        validade: validade,
        ativo: ativo,
        tarja: Tarja.fromCode(tarja),
      );
}
