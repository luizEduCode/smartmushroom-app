class SalaLotesAtivos {
  List<Salas>? salas;

  SalaLotesAtivos({this.salas});

  SalaLotesAtivos.fromJson(Map<String, dynamic> json) {
    if (json['salas'] != null) {
      salas = <Salas>[];
      json['salas'].forEach((v) {
        salas!.add(Salas.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    if (salas != null) {
      data['salas'] = salas!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Salas {
  int? idSala;
  String? nomeSala;
  List<Lotes>? lotes;

  Salas({this.idSala, this.nomeSala, this.lotes});

  Salas.fromJson(Map<String, dynamic> json) {
    idSala = json['idSala'];
    nomeSala = json['nomeSala'];
    if (json['lotes'] != null) {
      lotes = <Lotes>[];
      json['lotes'].forEach((v) {
        lotes!.add(Lotes.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['idSala'] = idSala;
    data['nomeSala'] = nomeSala;
    if (lotes != null) {
      data['lotes'] = lotes!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Lotes {
  int? idLote;
  String? dataInicio;
  String? status;
  String? nomeCogumelo;
  dynamic nomeFaseCultivo;
  dynamic temperatura;
  dynamic umidade;
  dynamic co2;

  Lotes({
    this.idLote,
    this.dataInicio,
    this.status,
    this.nomeCogumelo,
    this.nomeFaseCultivo,
    this.temperatura,
    this.umidade,
    this.co2,
  });

  Lotes.fromJson(Map<String, dynamic> json) {
    idLote = json['idLote'];
    dataInicio = json['dataInicio'];
    status = json['status'];
    nomeCogumelo = json['nomeCogumelo'];
    nomeFaseCultivo = json['nomeFaseCultivo'];
    temperatura = json['temperatura'];
    umidade = json['umidade'];
    co2 = json['co2'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = <String, dynamic>{};
    data['idLote'] = idLote;
    data['dataInicio'] = dataInicio;
    data['status'] = status;
    data['nomeCogumelo'] = nomeCogumelo;
    data['nomeFaseCultivo'] = nomeFaseCultivo;
    data['temperatura'] = temperatura;
    data['umidade'] = umidade;
    data['co2'] = co2;
    return data;
  }
}
