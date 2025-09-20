class ParametrosIdLote {
  int? idConfig;
  int? idLote;
  String? umidadeMin;
  String? umidadeMax;
  String? temperaturaMin;
  String? temperaturaMax;
  String? co2Max;
  String? dataCriacao;

  ParametrosIdLote({
    this.idConfig,
    this.idLote,
    this.umidadeMin,
    this.umidadeMax,
    this.temperaturaMin,
    this.temperaturaMax,
    this.co2Max,
    this.dataCriacao,
  });

  ParametrosIdLote.fromJson(Map<String, dynamic> json) {
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
    final Map<String, dynamic> data = new Map<String, dynamic>();
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
