import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';
import 'package:smartmushroom_app/core/theme/app_colors.dart';

const primaryColor = AppColors.primary;
const secontaryColor = AppColors.secondary;
const accentColor = AppColors.accent;
const white = Color.fromRGBO(255, 255, 255, 1);

const defaultPadding = 16.0;

const defaultHeightButton = 50;

final GetStorage _storage = GetStorage();

String getApiBaseUrl() {
  const defaultIp = '192.168.15.2';
  final savedIp = _storage.read('server_ip') ?? defaultIp;
  return 'http://$savedIp/smartmushroom-api/';
}
