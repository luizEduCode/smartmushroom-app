// ignore: camel_case_types
class fases_cultivo {
  int? idFaseCultivo;
  String? nomeFaseCultivo;
  int? idCogumelo;
  String? nomeCogumelo;
  String? descricaoFaseCultivo;
  double? temperaturaMin;
  double? temperaturaMax;
  double? umidadeMin;
  double? umidadeMax;
  double? co2Max;

  fases_cultivo({
    this.idFaseCultivo,
    this.nomeFaseCultivo,
    this.idCogumelo,
    this.nomeCogumelo,
    this.descricaoFaseCultivo,
    this.temperaturaMin,
    this.temperaturaMax,
    this.umidadeMin,
    this.umidadeMax,
    this.co2Max,
  });

  fases_cultivo.fromJson(Map<String, dynamic> json) {
    idFaseCultivo = int.tryParse(json['idFaseCultivo']?.toString() ?? '') ?? 0;
    nomeFaseCultivo = json['nomeFaseCultivo']?.toString();
    idCogumelo = int.tryParse(json['idCogumelo']?.toString() ?? '') ?? 0;
    nomeCogumelo = json['nomeCogumelo']?.toString();
    descricaoFaseCultivo = json['descricaoFaseCultivo']?.toString();

    // conversão segura de String/int/double
    temperaturaMin = double.tryParse(json['temperaturaMin']?.toString() ?? '');
    temperaturaMax = double.tryParse(json['temperaturaMax']?.toString() ?? '');
    umidadeMin = double.tryParse(json['umidadeMin']?.toString() ?? '');
    umidadeMax = double.tryParse(json['umidadeMax']?.toString() ?? '');
    co2Max = double.tryParse(json['co2Max']?.toString() ?? '');
  }

  Map<String, dynamic> toJson() {
    return {
      'idFaseCultivo': idFaseCultivo,
      'nomeFaseCultivo': nomeFaseCultivo,
      'idCogumelo': idCogumelo,
      'nomeCogumelo': nomeCogumelo,
      'descricaoFaseCultivo': descricaoFaseCultivo,
      'temperaturaMin': temperaturaMin,
      'temperaturaMax': temperaturaMax,
      'umidadeMin': umidadeMin,
      'umidadeMax': umidadeMax,
      'co2Max': co2Max,
    };
  }
}
