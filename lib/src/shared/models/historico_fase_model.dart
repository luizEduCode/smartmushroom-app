class HistoricoFaseModel {
  int? idHistorico;
  String? dataMudanca;
  int? idLote;
  String? loteStatus;
  String? loteDataInicio;
  String? loteDataFim;
  int? idSala;
  String? nomeSala;
  int? idCogumelo;
  String? nomeCogumelo;
  int? idFaseCultivo;
  String? nomeFaseCultivo;
  String? descricaoFaseCultivo;
  String? temperaturaMin;
  String? temperaturaMax;
  String? umidadeMin;
  String? umidadeMax;
  String? co2Max;

  HistoricoFaseModel();

  HistoricoFaseModel.fromJson(Map<String, dynamic> json) {
    idHistorico = json['idHistorico'];
    dataMudanca = json['dataMudanca'];
    idLote = json['idLote'];
    loteStatus = json['loteStatus'];
    loteDataInicio = json['loteDataInicio'];
    loteDataFim = json['loteDataFim'];
    idSala = json['idSala'];
    nomeSala = json['nomeSala'];
    idCogumelo = json['idCogumelo'];
    nomeCogumelo = json['nomeCogumelo'];
    idFaseCultivo = json['idFaseCultivo'];
    nomeFaseCultivo = json['nomeFaseCultivo'];
    descricaoFaseCultivo = json['descricaoFaseCultivo'];
    temperaturaMin = json['temperaturaMin'];
    temperaturaMax = json['temperaturaMax'];
    umidadeMin = json['umidadeMin'];
    umidadeMax = json['umidadeMax'];
    co2Max = json['co2Max'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['idHistorico'] = idHistorico;
    data['dataMudanca'] = dataMudanca;
    data['idLote'] = idLote;
    data['loteStatus'] = loteStatus;
    data['loteDataInicio'] = loteDataInicio;
    data['loteDataFim'] = loteDataFim;
    data['idSala'] = idSala;
    data['nomeSala'] = nomeSala;
    data['idCogumelo'] = idCogumelo;
    data['nomeCogumelo'] = nomeCogumelo;
    data['idFaseCultivo'] = idFaseCultivo;
    data['nomeFaseCultivo'] = nomeFaseCultivo;
    data['descricaoFaseCultivo'] = descricaoFaseCultivo;
    data['temperaturaMin'] = temperaturaMin;
    data['temperaturaMax'] = temperaturaMax;
    data['umidadeMin'] = umidadeMin;
    data['umidadeMax'] = umidadeMax;
    data['co2Max'] = co2Max;
    return data;
  }
}
