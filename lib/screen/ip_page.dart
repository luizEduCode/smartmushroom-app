import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:smartmushroom_app/screen/widgets/custom_app_bar.dart';

class ConfigIPPage extends StatelessWidget {
  final _ipController = TextEditingController();
  final storage = GetStorage();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Configurar IP'),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _ipController,
              decoration: InputDecoration(
                labelText: 'IP do Servidor',
                hintText: 'Ex: 192.168.1.100',
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                final ip = _ipController.text.trim();
                if (ip.isNotEmpty) {
                  storage.write('server_ip', ip);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('IP salvo com sucesso!')),
                  );
                }
              },
              icon: const Icon(Icons.save, color: Colors.white),
              label: const Text(
                'Salvar IP',
                style: TextStyle(color: Colors.white),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
