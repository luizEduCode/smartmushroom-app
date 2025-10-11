import 'dart:async';
import 'package:flutter/material.dart';
import 'package:smartmushroom_app/constants.dart';
import 'package:smartmushroom_app/core/network/dio_client.dart';
import 'package:smartmushroom_app/features/painel_salas/data/painel_salas_remote_datasource.dart';
import 'package:smartmushroom_app/models/salas_lotes_ativos.dart';
import 'package:smartmushroom_app/screen/widgets/custom_app_bar.dart';
import 'package:smartmushroom_app/screen/widgets/sala_card.dart';
import 'package:smartmushroom_app/screen/criarLote_page.dart';

class PainelSalasPage extends StatefulWidget {
  const PainelSalasPage({super.key});

  @override
  State<PainelSalasPage> createState() => _PainelSalasPageState();
}

class _PainelSalasPageState extends State<PainelSalasPage> {
  late Timer _timer;
  late final PainelSalasRemoteDataSource _dataSource;
  List<Salas> _salas = [];
  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _dataSource = PainelSalasRemoteDataSource(DioClient());
    fetchSalas();

    _timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      fetchSalas();
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  Future<void> fetchSalas() async {
    try {
      final salas = await _dataSource.fetchSalas();

      if (mounted) {
        setState(() {
          _salas = salas;
          _isLoading = false;
          _hasError = false;
          _errorMessage = null;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _hasError = true;
          _isLoading = false;
          _errorMessage = 'Falha na conexão: ${e.toString()}';
        });
      }
    }
  }

  Lotes? _getPrimeiroLoteAtivo(Salas sala) {
    if (sala.lotes != null && sala.lotes!.isNotEmpty) {
      return sala.lotes!.first;
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Painel de Salas'),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: RefreshIndicator(
          onRefresh: fetchSalas,
          child:
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : _hasError
                  ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(
                          Icons.error_outline,
                          size: 64,
                          color: Colors.red,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          _errorMessage ?? 'Erro ao carregar dados',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 16),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: fetchSalas,
                          child: const Text('Tentar Novamente'),
                        ),
                      ],
                    ),
                  )
                  : _salas.isEmpty
                  ? const Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.meeting_room_outlined,
                          size: 64,
                          color: Colors.grey,
                        ),
                        SizedBox(height: 16),
                        Text(
                          'Nenhuma sala com lotes ativos',
                          style: TextStyle(fontSize: 16, color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                  : ListView.builder(
                    itemCount: _salas.length,
                    itemBuilder: (context, index) {
                      final sala = _salas[index];
                      final lote = _getPrimeiroLoteAtivo(sala);

                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: SalaCard(
                          nomeSala: sala.nomeSala ?? 'Sem nome',
                          nomeCogumelo:
                              lote?.nomeCogumelo ?? 'Nenhum lote ativo',
                          faseCultivo:
                              lote?.nomeFaseCultivo?.toString() ?? '--',
                          dataInicio: lote?.dataInicio ?? '--',
                          idLote: lote?.idLote?.toString() ?? '0',
                          temperatura: lote?.temperatura?.toString() ?? '--',
                          umidade: lote?.umidade?.toString() ?? '--',
                          co2: lote?.co2?.toString() ?? '--',
                          status: lote?.status ?? 'inativo',
                          idSala: sala.idSala?.toString() ?? '0',
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
        tooltip: 'Criar Novo Lote',
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
