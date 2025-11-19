class Cogumelos {
  final int idCogumelo;
  final String nomeCogumelo;
  final String descricao;

  const Cogumelos({
    required this.idCogumelo,
    required this.nomeCogumelo,
    required this.descricao,
  });

  factory Cogumelos.fromJson(Map<String, dynamic> json) {
    return Cogumelos(
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
