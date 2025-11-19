import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:smartmushroom_app/src/shared/widgets/custom_app_bar.dart';

class ConfigIPPage extends StatefulWidget {
  const ConfigIPPage({super.key});

  @override
  State<ConfigIPPage> createState() => _ConfigIPPageState();
}

class _ConfigIPPageState extends State<ConfigIPPage> {
  late final TextEditingController _ipController;
  final GetStorage _storage = GetStorage();

  @override
  void initState() {
    super.initState();
    final storedIp = _storage.read<String>('server_ip');
    _ipController = TextEditingController(text: storedIp ?? '');
  }

  @override
  void dispose() {
    _ipController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(title: 'Configurar IP'),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _ipController,
              decoration: const InputDecoration(
                labelText: 'IP do Servidor',
                hintText: 'Ex: 192.168.1.100',
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                onPressed: () {
                  final ip = _ipController.text.trim();
                  final messenger = ScaffoldMessenger.of(context);
                  if (ip.isEmpty) {
                    messenger.showSnackBar(
                      const SnackBar(content: Text('Informe um IP válido.')),
                    );
                    return;
                  }
                  _storage.write('server_ip', ip);
                  Navigator.of(context).pop(ip);
                },
                icon: const Icon(Icons.save),
                label: const Text("Salvar IP"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
