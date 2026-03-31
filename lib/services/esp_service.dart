import 'dart:async';
import 'dart:io';

import 'package:http/http.dart' as http;

class EspService {
  EspService({http.Client? client, this.timeout = const Duration(seconds: 5)})
      : _client = client ?? http.Client();

  final http.Client _client;
  final Duration timeout;

  /// Sends a simple request to `http://<ip>/` to check reachability.
  ///
  /// Returns 'Connected' or 'Not reachable'.
  Future<String> checkConnection(String ip) async {
    final uri = _buildBaseUri(ip);
    if (uri == null) return 'Not reachable';

    try {
      final response = await _client.get(uri).timeout(timeout);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        return 'Connected';
      }
      return 'Not reachable';
    } on TimeoutException {
      return 'Not reachable';
    } on SocketException {
      return 'Not reachable';
    } on http.ClientException {
      return 'Not reachable';
    } on FormatException {
      return 'Not reachable';
    } catch (_) {
      return 'Not reachable';
    }
  }

  /// Sends: `http://<ip>/?data=<message>`
  ///
  /// Returns a simple success/failure message.
  Future<String> sendData(String ip, String message) async {
    final uri = _buildUri(ip, message);
    if (uri == null) return 'Failure: Invalid IP';

    try {
      final response = await _client.get(uri).timeout(timeout);

      if (response.statusCode >= 200 && response.statusCode < 300) {
        return 'Success';
      }

      return 'Failure: HTTP ${response.statusCode}';
    } on TimeoutException {
      return 'Failure: Timeout';
    } on SocketException {
      return 'Failure: No connection';
    } on http.ClientException {
      return 'Failure: No connection';
    } on FormatException {
      return 'Failure: Invalid IP';
    } catch (e) {
      return 'Failure: ${e.toString()}';
    }
  }

  Uri? _buildUri(String ip, String message) {
    final trimmedIp = ip.trim();
    if (trimmedIp.isEmpty || trimmedIp.contains(' ')) return null;

    final encodedMessage = Uri.encodeQueryComponent(message);
    final url = 'http://$trimmedIp/?data=$encodedMessage';

    try {
      return Uri.parse(url);
    } on FormatException {
      return null;
    }
  }

  Uri? _buildBaseUri(String ip) {
    final trimmedIp = ip.trim();
    if (trimmedIp.isEmpty || trimmedIp.contains(' ')) return null;

    try {
      return Uri.parse('http://$trimmedIp/');
    } on FormatException {
      return null;
    }
  }
}

