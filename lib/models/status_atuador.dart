class StatusAtuador {
  int? idControle;
  late int idAtuador; // não pode ser nulo
  String? nomeAtuador;
  String? tipoAtuador;
  int? idLote;
  String? loteStatus;
  String? loteDataInicio;
  String? loteDataFim;
  String? nomeSala;
  String? nomeCogumelo;
  String? statusAtuador;
  String? dataCriacao;

  StatusAtuador({
    this.idControle,
    required this.idAtuador,
    this.nomeAtuador,
    this.tipoAtuador,
    this.idLote,
    this.loteStatus,
    this.loteDataInicio,
    this.loteDataFim,
    this.nomeSala,
    this.nomeCogumelo,
    this.statusAtuador,
    this.dataCriacao,
  });

  StatusAtuador.fromJson(Map<String, dynamic> json) {
    idControle = json['idControle'];
    idAtuador = json['idAtuador'] ?? 0; // garante que não seja nulo
    nomeAtuador = json['nomeAtuador'];
    tipoAtuador = json['tipoAtuador'];
    idLote = json['idLote'];
    loteStatus = json['loteStatus'];
    loteDataInicio = json['loteDataInicio'];
    loteDataFim = json['loteDataFim'];
    nomeSala = json['nomeSala'];
    nomeCogumelo = json['nomeCogumelo'];
    statusAtuador = json['statusAtuador'];
    dataCriacao = json['dataCriacao'];
  }

  Map<String, dynamic> toJson() {
    return {
      'idControle': idControle,
      'idAtuador': idAtuador,
      'nomeAtuador': nomeAtuador,
      'tipoAtuador': tipoAtuador,
      'idLote': idLote,
      'loteStatus': loteStatus,
      'loteDataInicio': loteDataInicio,
      'loteDataFim': loteDataFim,
      'nomeSala': nomeSala,
      'nomeCogumelo': nomeCogumelo,
      'statusAtuador': statusAtuador,
      'dataCriacao': dataCriacao,
    };
  }
}
