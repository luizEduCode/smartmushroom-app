class ControleAtuadorModel {
  final int idControle;
  final int idAtuador;
  final String nomeAtuador;
  final String tipoAtuador;
  final int idLote;
  final String statusAtuador;
  final String dataCriacao;

  ControleAtuadorModel({
    required this.idControle,
    required this.idAtuador,
    required this.nomeAtuador,
    required this.tipoAtuador,
    required this.idLote,
    required this.statusAtuador,
    required this.dataCriacao,
  });

  factory ControleAtuadorModel.fromJson(Map<String, dynamic> json) {
    return ControleAtuadorModel(
      idControle: json['idControle'] != null ? int.parse(json['idControle'].toString()) : 0,
      idAtuador: json['idAtuador'] != null ? int.parse(json['idAtuador'].toString()) : 0,
      nomeAtuador: json['nomeAtuador'] ?? '',
      tipoAtuador: json['tipoAtuador'] ?? '',
      idLote: json['idLote'] != null ? int.parse(json['idLote'].toString()) : 0,
      statusAtuador: json['statusAtuador'] ?? '',
      dataCriacao: json['dataCriacao'] ?? '',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idControle': idControle,
      'idAtuador': idAtuador,
      'nomeAtuador': nomeAtuador,
      'tipoAtuador': tipoAtuador,
      'idLote': idLote,
      'statusAtuador': statusAtuador,
      'dataCriacao': dataCriacao,
    };
  }
}
