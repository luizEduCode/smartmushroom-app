class LeituraModel {
  int? idLeitura;
  int? idLote;
  String? umidade;      // vem como string na API
  String? temperatura;  // idem
  String? co2;          // idem
  String? luz;
  String? dataCriacao;
  String? loteStatus;
  String? loteDataInicio;

  LeituraModel({
    this.idLeitura,
    this.idLote,
    this.umidade,
    this.temperatura,
    this.co2,
    this.luz,
    this.dataCriacao,
    this.loteStatus,
    this.loteDataInicio,
  });

  factory LeituraModel.fromJson(Map<String, dynamic> json) {
    return LeituraModel(
      idLeitura: int.tryParse(json['idLeitura'].toString()),
      idLote: int.tryParse(json['idLote'].toString()),
      umidade: json['umidade']?.toString(),
      temperatura: json['temperatura']?.toString(),
      co2: json['co2']?.toString(),
      luz: json['luz']?.toString(),
      dataCriacao: json['dataCriacao']?.toString(),
      loteStatus: json['loteStatus']?.toString(),
      loteDataInicio: json['loteDataInicio']?.toString(),
    );
  }

  // Getters práticos para gráficos (fl_chart)
  double get umidadeNum => double.tryParse(umidade ?? '') ?? 0.0;
  double get temperaturaNum => double.tryParse(temperatura ?? '') ?? 0.0;
  double get co2Num => double.tryParse(co2 ?? '') ?? 0.0;

  Map<String, dynamic> toJson() => {
    'idLeitura': idLeitura,
    'idLote': idLote,
    'umidade': umidade,
    'temperatura': temperatura,
    'co2': co2,
    'luz': luz,
    'dataCriacao': dataCriacao,
    'loteStatus': loteStatus,
    'loteDataInicio': loteDataInicio,
  };
}
