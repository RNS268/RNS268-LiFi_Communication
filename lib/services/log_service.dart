import 'package:esp8266_controller_app/models/esp_log.dart';
import 'package:esp8266_controller_app/services/esp_log_storage.dart';

class LogService {
  LogService({EspLogStorage? storage}) : _storage = storage ?? EspLogStorage();

  final EspLogStorage _storage;

  Future<void> saveLog(EspLog log) => _storage.saveLog(log);

  Future<List<EspLog>> getLogs() => _storage.getLogs();

  Future<void> clearLogs() => _storage.clearLogs();
}

