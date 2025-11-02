class ParametroModel {
  int? idConfig;
  int? idLote;
  String? umidadeMin;
  String? umidadeMax;
  String? temperaturaMin;
  String? temperaturaMax;
  String? co2Max;
  String? dataCriacao;

  ParametroModel();

  ParametroModel.fromJson(Map<String, dynamic> json) {
    idConfig = json['idConfig'];
    idLote = json['idLote'];
    umidadeMin = json['umidadeMin'];
    umidadeMax = json['umidadeMax'];
    temperaturaMin = json['temperaturaMin'];
    temperaturaMax = json['temperaturaMax'];
    co2Max = json['co2Max'];
    dataCriacao = json['dataCriacao'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['idConfig'] = idConfig;
    data['idLote'] = idLote;
    data['umidadeMin'] = umidadeMin;
    data['umidadeMax'] = umidadeMax;
    data['temperaturaMin'] = temperaturaMin;
    data['temperaturaMax'] = temperaturaMax;
    data['co2Max'] = co2Max;
    data['dataCriacao'] = dataCriacao;
    return data;
  }
}
