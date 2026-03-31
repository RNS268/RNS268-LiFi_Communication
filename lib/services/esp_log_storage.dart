import 'dart:convert';

import 'package:esp8266_controller_app/models/esp_log.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EspLogStorage {
  static const String _key = 'esp_logs';

  Future<void> saveLog(EspLog log) async {
    final prefs = await SharedPreferences.getInstance();
    final logs = await getLogs();
    logs.add(log);
    final jsonString = jsonEncode(logs.map((e) => e.toJson()).toList());
    await prefs.setString(_key, jsonString);
  }

  Future<List<EspLog>> getLogs() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_key);
    if (raw == null || raw.isEmpty) return <EspLog>[];

    try {
      final decoded = jsonDecode(raw);
      if (decoded is! List) return <EspLog>[];
      return decoded
          .whereType<Map>()
          .map((m) => EspLog.fromJson(Map<String, dynamic>.from(m)))
          .toList();
    } catch (_) {
      return <EspLog>[];
    }
  }

  Future<void> clearLogs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_key);
  }
}

