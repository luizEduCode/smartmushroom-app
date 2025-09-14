// // ignore: camel_case_types
// class cogumelos {
//   int? idCogumelo;
//   String? nomeCogumelo;
//   String? descricao;

//   cogumelos({this.idCogumelo, this.nomeCogumelo, this.descricao});

//   cogumelos.fromJson(Map<String, dynamic> json) {
//     idCogumelo = int.tryParse(json['idCogumelo']?.toString() ?? '') ?? 0;
//     nomeCogumelo = json['nomeCogumelo']?.toString();
//     descricao = json['descricao']?.toString();
//   }

//   Map<String, dynamic> toJson() {
//     final Map<String, dynamic> data = {};
//     data['idCogumelo'] = idCogumelo;
//     data['nomeCogumelo'] = nomeCogumelo;
//     data['descricao'] = descricao;
//     return data;
//   }
// }

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
