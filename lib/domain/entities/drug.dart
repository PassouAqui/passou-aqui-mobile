class Drug {
  final String id;
  final String nome;
  final String descricao;
  final String tagUid;
  final String lote;
  final DateTime validade;
  final bool ativo;
  final String tarja;

  Drug({
    required this.id,
    required this.nome,
    required this.descricao,
    required this.tagUid,
    required this.lote,
    required this.validade,
    required this.ativo,
    required this.tarja,
  });

  factory Drug.fromJson(Map<String, dynamic> json) {
    return Drug(
      id: json['id'] as String,
      nome: json['nome'] as String,
      descricao: json['descricao'] as String,
      tagUid: json['tag_uid'] as String,
      lote: json['lote'] as String,
      validade: DateTime.parse(json['validade'] as String),
      ativo: json['ativo'] as bool,
      tarja: json['tarja'] as String,
    );
  }
}
