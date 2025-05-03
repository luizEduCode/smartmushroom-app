import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

const primaryColor = Color.fromRGBO(26, 28, 41, 1);
const secontaryColor = Color.fromRGBO(36, 91, 136, 1);

const defaultPadding = 16.0;

const defaultHeightButton = 50;

// Configuração dinâmica da API
final GetStorage _storage = GetStorage();

// Função que retorna a URL base da API (com IP salvo ou valor padrão)
String getApiBaseUrl() {
  const defaultIp = '192.168.15.2'; // IP padrão (fallback)
  final savedIp = _storage.read('server_ip') ?? defaultIp;
  return 'http://$savedIp/smartmushroom-api/';
}
