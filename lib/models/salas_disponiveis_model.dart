// class SalaDisponivel {
//   final int? idSala;
//   final String? nomeSala;
//   final String? descricaoSala;
//   final String? dataCriacao;

//   const SalaDisponivel({
//     this.idSala,
//     this.nomeSala,
//     this.descricaoSala,
//     this.dataCriacao,
//   });

//   factory SalaDisponivel.fromJson(Map<String, dynamic> json) {
//     return SalaDisponivel(
//       idSala:
//           json['idSala'] is int
//               ? json['idSala']
//               : int.tryParse(json['idSala']?.toString() ?? ''),
//       nomeSala: json['nomeSala']?.toString(),
//       descricaoSala: json['descricaoSala']?.toString(),
//       dataCriacao: json['dataCriacao']?.toString(),
//     );
//   }

//   Map<String, dynamic> toJson() {
//     return {
//       'idSala': idSala,
//       'nomeSala': nomeSala,
//       'descricaoSala': descricaoSala,
//       'dataCriacao': dataCriacao,
//     };
//   }
// }

class SalaDisponivel {
  final int idSala;
  final String nomeSala;
  final String descricaoSala;
  final String dataCriacao;

  const SalaDisponivel({
    required this.idSala,
    required this.nomeSala,
    required this.descricaoSala,
    required this.dataCriacao,
  });

  factory SalaDisponivel.fromJson(Map<String, dynamic> json) {
    return SalaDisponivel(
      idSala: int.tryParse(json['idSala']?.toString() ?? '0') ?? 0,
      nomeSala: json['nomeSala']?.toString() ?? '',
      descricaoSala: json['descricaoSala']?.toString() ?? '',
      dataCriacao: json['dataCriacao']?.toString() ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idSala': idSala,
      'nomeSala': nomeSala,
      'descricaoSala': descricaoSala,
      'dataCriacao': dataCriacao,
    };
  }
}
