class cogumelos {
  final int idCogumelo;
  final String nomeCogumelo;
  final String descricao;

  const cogumelos({
    required this.idCogumelo,
    required this.nomeCogumelo,
    required this.descricao,
  });

  factory cogumelos.fromJson(Map<String, dynamic> json) {
    return cogumelos(
      idCogumelo: int.tryParse(json['idCogumelo']?.toString() ?? '0') ?? 0,
      nomeCogumelo: json['nomeCogumelo']?.toString() ?? '',
      descricao: json['descricao']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idCogumelo': idCogumelo,
      'nomeCogumelo': nomeCogumelo,
      'descricao': descricao,
    };
  }
}
