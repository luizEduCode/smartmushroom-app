import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:smartmushroom_app/constants.dart';
import 'package:smartmushroom_app/screen/widgets/custom_app_bar.dart';
import 'package:smartmushroom_app/screen/widgets/sala_card.dart';
import 'package:smartmushroom_app/screen/criarLote_page.dart';

class PainelsalasPage extends StatefulWidget {
  const PainelsalasPage({super.key});

  @override
  State<PainelsalasPage> createState() => _PainelsalasPageState();
}

class _PainelsalasPageState extends State<PainelsalasPage> {
  late Timer _timer;
  List _salas = []; // Lista para armazenar os dados das salas
  bool _isLoading = true; // Indica se está carregando os dados
  bool _hasError = false; // Indica se houve erro na requisição

  @override
  void initState() {
    super.initState();
    fetchSalas(); // Carrega os dados iniciais

    // Atualiza automaticamente os dados a cada 10 segundos
    _timer = Timer.periodic(Duration(seconds: 10), (timer) {
      fetchSalas();
    });
  }

  @override
  void dispose() {
    _timer.cancel(); // Cancela o Timer ao sair da tela
    super.dispose();
  }

  Future<void> fetchSalas() async {
    try {
      final response = await http.get(Uri.parse('${getApiBaseUrl()}salas.php'));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (mounted) {
          setState(() {
            _salas = data['sala'] ?? [];
            _isLoading = false;
            _hasError = false;
          });
        }
      } else {
        if (mounted) {
          setState(() {
            _hasError = true;
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
        });
      }
    }
  }

  // Adicionei depois de subir no Drive - 21:43 23/03/2025
  Future<void> vincularLote(int idSala, int idLote) async {
    try {
      final response = await http.post(
        Uri.parse('${getApiBaseUrl()}salas.php'),
        body: {'idSala': idSala.toString(), 'idLote': idLote.toString()},
      );

      if (response.statusCode == 200) {
        // Atualiza a lista de salas
        fetchSalas();
      } else {
        setState(() {
          _hasError = true;
        });
      }
    } catch (e) {
      setState(() {
        _hasError = true;
      });
    }
  }
  // -------------- Acaba aqui -------------- //

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //alterando o app bar
      appBar: const CustomAppBar(title: 'Painel de Salas'),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: RefreshIndicator(
          onRefresh: fetchSalas,
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _hasError
                  ? Center(child: Text('Erro ao carregar dados'))
                  : ListView.builder(
                    itemCount: _salas.length,
                    itemBuilder: (context, index) {
                      final sala = _salas[index];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SalaCard(
                          nomeSala: sala['nomeSala'] ?? 'Sem nome',
                          nomeCogumelo: sala['nomeCogumelo'] ?? '',
                          faseCultivo: sala['nomeFaseCultivo'] ?? '',
                          dataInicio: sala['dataInicio'] ?? '',
                          idLote: sala['idLote'].toString(),
                          temperatura:
                              sala['temperatura'] != null
                                  ? double.tryParse(
                                        sala['temperatura'].toString(),
                                      )?.toStringAsFixed(0) ??
                                      '--'
                                  : '--',
                          umidade:
                              sala['umidade'] != null
                                  ? double.tryParse(
                                        sala['umidade'].toString(),
                                      )?.toStringAsFixed(0) ??
                                      '--'
                                  : '--',
                          co2:
                              sala['co2'] != null
                                  ? double.tryParse(
                                        sala['co2'].toString(),
                                      )?.toStringAsFixed(0) ??
                                      '--'
                                  : '--',
                          status: sala['status'] ?? '',
                        ),
                      );
                    },
                  ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: secontaryColor,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => const CriarLotePage()),
          );
        },
        tooltip: 'Increment',
        child: Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
