import 'package:flutter/material.dart';
import 'app.dart';
import 'core/storage/hive_service.dart';
import 'core/storage/initial_data.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await HiveService.init();
  await InitialData.loadIfEmpty();
  runApp(const VaultApp());
}
