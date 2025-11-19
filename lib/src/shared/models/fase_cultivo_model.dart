class FaseCultivoModel {
  int? idFaseCultivo;
  String? nomeFaseCultivo;
  int? idCogumelo;
  String? nomeCogumelo;
  String? descricaoFaseCultivo;
  String? temperaturaMin;
  String? temperaturaMax;
  String? umidadeMin;
  String? umidadeMax;
  String? co2Max;

  FaseCultivoModel();

  FaseCultivoModel.fromJson(Map<String, dynamic> json) {
    idFaseCultivo = json['idFaseCultivo'];
    nomeFaseCultivo = json['nomeFaseCultivo'];
    idCogumelo = json['idCogumelo'];
    nomeCogumelo = json['nomeCogumelo'];
    descricaoFaseCultivo = json['descricaoFaseCultivo'];
    temperaturaMin = json['temperaturaMin'];
    temperaturaMax = json['temperaturaMax'];
    umidadeMin = json['umidadeMin'];
    umidadeMax = json['umidadeMax'];
    co2Max = json['co2Max'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['idFaseCultivo'] = idFaseCultivo;
    data['nomeFaseCultivo'] = nomeFaseCultivo;
    data['idCogumelo'] = idCogumelo;
    data['nomeCogumelo'] = nomeCogumelo;
    data['descricaoFaseCultivo'] = descricaoFaseCultivo;
    data['temperaturaMin'] = temperaturaMin;
    data['temperaturaMax'] = temperaturaMax;
    data['umidadeMin'] = umidadeMin;
    data['umidadeMax'] = umidadeMax;
    data['co2Max'] = co2Max;
    return data;
  }
}
