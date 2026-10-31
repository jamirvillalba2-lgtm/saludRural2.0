import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class ApiException implements Exception {
  const ApiException(
    this.message, {
    this.statusCode,
  });

  final String message;
  final int? statusCode;

  @override
  String toString() => message;
}

class ApiClient {
  ApiClient({
    http.Client? client,
    String? baseUrl,
  })  : _client = client ?? http.Client(),
        _baseUrl = (baseUrl ??
                const String.fromEnvironment(
                  'API_BASE_URL',
                  defaultValue:
                      'http://192.168.40.170:3000/api', // Actualizado para red Wi-Fi local
                ))
            .replaceFirst(RegExp(r'/$'), '');

  final http.Client _client;
  final String _baseUrl;

  Future<dynamic> get(
    String path, {
    Map<String, String> queryParameters = const {},
  }) {
    return _send(
      'GET',
      path,
      queryParameters: queryParameters,
    );
  }

  Future<dynamic> post(
    String path, {
    Map<String, dynamic> body = const {},
  }) {
    return _send('POST', path, body: body);
  }

  Future<dynamic> put(
    String path, {
    required Map<String, dynamic> body,
  }) {
    return _send('PUT', path, body: body);
  }

  Future<dynamic> delete(String path) => _send('DELETE', path);

  Uri _uri(String path, Map<String, String> queryParameters) {
    final uri = Uri.parse('$_baseUrl$path');
    return uri.replace(
      queryParameters: queryParameters.isEmpty ? null : queryParameters,
    );
  }

  Future<dynamic> _send(
    String method,
    String path, {
    Map<String, String> queryParameters = const {},
    Map<String, dynamic>? body,
  }) async {
    final uri = _uri(path, queryParameters);
    const headers = {
      'Accept': 'application/json',
      'Content-Type': 'application/json; charset=utf-8',
    };

    try {
      late final http.Response response;
      final encodedBody = body == null ? null : jsonEncode(body);

      switch (method) {
        case 'GET':
          response = await _client.get(uri, headers: headers).timeout(
                const Duration(seconds: 20),
              );
          break;
        case 'POST':
          response = await _client
              .post(uri, headers: headers, body: encodedBody)
              .timeout(const Duration(seconds: 30));
          break;
        case 'PUT':
          response = await _client
              .put(uri, headers: headers, body: encodedBody)
              .timeout(const Duration(seconds: 30));
          break;
        case 'DELETE':
          response = await _client.delete(uri, headers: headers).timeout(
                const Duration(seconds: 20),
              );
          break;
        default:
          throw ArgumentError.value(method, 'method', 'Método no soportado');
      }

      final data = _decodeResponse(response);
      if (response.statusCode < 200 || response.statusCode >= 300) {
        final message = _errorMessage(data);
        if (response.statusCode == 409) {
          throw ApiException(
            message ?? 'Ese horario acaba de ser ocupado. Elige otro.',
            statusCode: response.statusCode,
          );
        }
        throw ApiException(
          message ?? 'No fue posible completar la solicitud.',
          statusCode: response.statusCode,
        );
      }
      return data;
    } on ApiException {
      rethrow;
    } on SocketException {
      throw const ApiException(
        'No se pudo conectar con el servidor. Verifica tu conexión e inténtalo de nuevo.',
      );
    } on TimeoutException {
      throw const ApiException(
        'El servidor tardó demasiado en responder. Inténtalo de nuevo.',
      );
    } on http.ClientException {
      throw const ApiException(
        'Ocurrió un problema de red al comunicarse con el servidor.',
      );
    } on FormatException {
      throw const ApiException(
        'El servidor devolvió una respuesta inválida.',
      );
    }
  }

  dynamic _decodeResponse(http.Response response) {
    if (response.bodyBytes.isEmpty) return null;
    final text = utf8.decode(response.bodyBytes);
    if (text.trim().isEmpty) return null;
    return jsonDecode(text);
  }

  String? _errorMessage(dynamic data) {
    if (data is! Map) return null;
    for (final key in const ['message', 'error', 'detail']) {
      final value = data[key];
      if (value is String && value.trim().isNotEmpty) {
        return value.trim();
      }
    }
    return null;
  }
}
