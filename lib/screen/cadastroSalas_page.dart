// import 'dart:async';
// import 'dart:convert';
// import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:smartmushroom_app/constants.dart';
// import 'package:smartmshroom_app/constants.dart';

import 'package:smartmushroom_app/screen/sala_page.dart';
// import 'package:smartmushroom_app/screen/widgets/sala_card.dart';

class CadastrosalasPage extends StatefulWidget {
  const CadastrosalasPage({super.key});

  @override
  State<CadastrosalasPage> createState() => _CadastrosalasPageState();
}

class _CadastrosalasPageState extends State<CadastrosalasPage> {
  String?
  _selectedMushroom; // Estado para armazenar o tipo de cogumelo selecionado.
  String?
  _selectedPhase; // Estado para armazenar a fase do cultivo selecionada.

  final List<String> mushroomTypes = [
    'Shimeji Branco',
    'Shitake',
    'Paris',
    'Ganoderma',
  ];

  final List<String> cultivationPhases = [
    'Colonização',
    'Indução',
    'Frutificação',
  ];

  // Função chamada quando um novo valor é selecionado no dropdown dos cogumelos.
  void mushroomDropdownCallback(String? selectedValue) {
    setState(() {
      _selectedMushroom = selectedValue;
    });
  }

  //referente ao dropdown das fases do cultivo
  void phaseDropdownCallback(String? selectedValue) {
    setState(() {
      _selectedPhase = selectedValue;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          "Cadastro Salas",
          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
        ),
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(8.00),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    Column(
                      crossAxisAlignment:
                          CrossAxisAlignment.start, // Alinha o texto à esquerda
                      children: [
                        const Text(
                          'Dados da Sala',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ), // Espaçamento entre o título e o campo
                        const TextField(
                          decoration: InputDecoration(
                            border: OutlineInputBorder(),
                            hintText: 'NOME DA SALA',
                          ),
                        ),
                        const SizedBox(
                          height: 10,
                        ), // Espaçamento entre o título e o campo

                        Text(
                          'Tipo do Cogumelo',
                          style: TextStyle(fontSize: 18),
                        ),
                        // Dropdown para selecionar o tipo de cogumelo.
                        DropdownButton<String>(
                          value: _selectedMushroom,
                          hint: const Text(
                            "Escolha um tipo de cogumelo",
                          ), // Texto antes da seleção.
                          items:
                              mushroomTypes.map((String type) {
                                return DropdownMenuItem<String>(
                                  value: type,
                                  child: Text(type),
                                );
                              }).toList(),
                          onChanged: mushroomDropdownCallback,
                        ),
                        const SizedBox(
                          height: 10,
                        ), // Espaçamento entre o título e o campo
                        Text('Fase de Cultivo', style: TextStyle(fontSize: 18)),
                        DropdownButton<String>(
                          value: _selectedPhase,
                          hint: const Text(
                            "Escolha a fase do cultivo",
                          ), // Texto antes da seleção.
                          items:
                              cultivationPhases.map((String phase) {
                                return DropdownMenuItem<String>(
                                  value: phase,
                                  child: Text(phase),
                                );
                              }).toList(),
                          onChanged: phaseDropdownCallback,
                        ),

                        const SizedBox(
                          height: 10,
                        ), // Espaçamento entre o título e o campo
                      ],
                    ),
                    const Divider(
                      color: Colors.black, // Cor da linha
                      thickness: 1, // Espessura da linha
                      indent: 20, // Espaço à esquerda
                      endIndent: 20, // Espaço à direita
                    ),
                    const Row(
                      children: [
                        Text(
                          'Setar paramêtros da fase',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        // widget customSwitch(String text, bool val, Function onChangeMethod){
                        //   return Padding(padding: )
                        // }
                      ],
                    ),
                    SizedBox(
                      height: 10,
                    ), // Espaçamento entre o título e o campo
                    TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Temperatura',
                        suffixIcon: Icon(
                          Icons.thermostat,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ), // Espaçamento entre o título e o campo
                    TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Umidade',
                        suffixIcon: Icon(
                          Icons.water_drop_outlined,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ), // Espaçamento entre o título e o campo
                    TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Co²',
                        suffixIcon: Icon(
                          Icons.co2_outlined,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 10,
                    ), // Espaçamento entre o título e o campo
                    TextField(
                      decoration: InputDecoration(
                        border: OutlineInputBorder(),
                        hintText: 'Luminosidade',
                        suffixIcon: Icon(
                          Icons.lightbulb_outlined,
                          color: Colors.blueAccent,
                        ),
                      ),
                    ),
                    // SizedBox(16.0),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder:
                                    (context) => SalaPage(
                                      idLote: '1',
                                      nomeSala: 'Sala 01',
                                    ),
                              ),
                            );
                          },
                          child: Text(
                            'Salvar alterações',
                            style: TextStyle(
                              color: Colors.green,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        SizedBox(width: 20),
                        ElevatedButton(
                          onPressed: () {},
                          child: Text(
                            'Finalizar lote',
                            style: TextStyle(
                              color: Colors.redAccent,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
