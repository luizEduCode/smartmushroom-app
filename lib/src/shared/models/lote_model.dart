class LoteModel {
  int? idLote;
  int? idSala;
  String? nomeSala;
  int? idCogumelo;
  String? nomeCogumelo;
  String? dataInicio;
  String? dataFim;
  String? status;

  LoteModel({
    this.idLote,
    this.idSala,
    this.nomeSala,
    this.idCogumelo,
    this.nomeCogumelo,
    this.dataInicio,
    this.dataFim,
    this.status,
  });

  factory LoteModel.fromJson(Map<String, dynamic> json) {
    return LoteModel(
      idLote: int.tryParse(json['idLote'].toString()),
      idSala: int.tryParse(json['idSala'].toString()),
      nomeSala: json['nomeSala']?.toString(),
      idCogumelo: int.tryParse(json['idCogumelo'].toString()),
      nomeCogumelo: json['nomeCogumelo']?.toString(),
      dataInicio: json['dataInicio']?.toString(),
      dataFim: json['dataFim']?.toString(),
      status: json['status']?.toString(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'idLote': idLote,
      'idSala': idSala,
      'nomeSala': nomeSala,
      'idCogumelo': idCogumelo,
      'nomeCogumelo': nomeCogumelo,
      'dataInicio': dataInicio,
      'dataFim': dataFim,
      'status': status,
    };
  }
}
