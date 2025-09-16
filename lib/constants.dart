import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

const primaryColor = Color.fromRGBO(26, 28, 41, 1);
const secontaryColor = Color.fromRGBO(36, 91, 136, 1);
const white = Color.fromRGBO(255, 255, 255, 1);

const defaultPadding = 16.0;

const defaultHeightButton = 50;

final GetStorage _storage = GetStorage();

String getApiBaseUrl() {
  const defaultIp = '192.168.15.2';
  final savedIp = _storage.read('server_ip') ?? defaultIp;
  return 'http://$savedIp/smartmushroom-api/';
}
