import 'package:uuid/uuid.dart';

enum Tarja {
  semTarja('ST', 'Sem Tarja'),
  amarela('TA', 'Tarja Amarela'),
  vermelha('TV', 'Tarja Vermelha'),
  preta('TP', 'Tarja Preta');

  final String code;
  final String label;
  const Tarja(this.code, this.label);

  static Tarja fromCode(String code) {
    return Tarja.values.firstWhere(
      (tarja) => tarja.code == code,
      orElse: () => Tarja.semTarja,
    );
  }
}

class Drug {
  final String id;
  final String nome;
  final String descricao;
  final String tagUid;
  final String lote;
  final DateTime validade;
  final bool ativo;
  final Tarja tarja;

  Drug({
    String? id,
    required this.nome,
    required this.descricao,
    required this.tagUid,
    required this.lote,
    required this.validade,
    this.ativo = true,
    this.tarja = Tarja.semTarja,
  }) : id = id ?? const Uuid().v4();

  factory Drug.fromJson(Map<String, dynamic> json) {
    return Drug(
      id: json['id'],
      nome: json['nome'],
      descricao: json['descricao'] ?? '',
      tagUid: json['tag_uid'],
      lote: json['lote'],
      validade: DateTime.parse(json['validade']),
      ativo: json['ativo'] ?? true,
      tarja: Tarja.fromCode(json['tarja']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'descricao': descricao,
      'tag_uid': tagUid,
      'lote': lote,
      'validade': validade.toUtc().toIso8601String().split('T')[0],
      'ativo': ativo,
      'tarja': tarja.code,
    };
  }

  Drug copyWith({
    String? id,
    String? nome,
    String? descricao,
    String? tagUid,
    String? lote,
    DateTime? validade,
    bool? ativo,
    Tarja? tarja,
  }) {
    return Drug(
      id: id ?? this.id,
      nome: nome ?? this.nome,
      descricao: descricao ?? this.descricao,
      tagUid: tagUid ?? this.tagUid,
      lote: lote ?? this.lote,
      validade: validade ?? this.validade,
      ativo: ativo ?? this.ativo,
      tarja: tarja ?? this.tarja,
    );
  }
}
