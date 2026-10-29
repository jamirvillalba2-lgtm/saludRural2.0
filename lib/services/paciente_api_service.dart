import 'dart:convert';
import 'dart:io';

import 'api_client.dart';

class PacienteApiService {
  PacienteApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<Map<String, dynamic>> registrar({
    required Map<String, dynamic> datos,
    File? documentoFrente,
    File? documentoReverso,
  }) async {
    try {
      final body = Map<String, dynamic>.from(datos);
      final documentos = <String, dynamic>{};
      if (documentoFrente != null) {
        documentos['frente'] = await _archivoComoJson(documentoFrente);
      }
      if (documentoReverso != null) {
        documentos['reverso'] = await _archivoComoJson(documentoReverso);
      }
      if (documentos.isNotEmpty) {
        body['imagenesDocumento'] = documentos;
      }

      return _asMap(
        await _apiClient.post('/pacientes/registro', body: body),
        'El servidor devolvió un registro de paciente inválido.',
      );
    } on FileSystemException {
      throw const ApiException(
        'No se pudo leer la imagen del documento. Selecciónala nuevamente.',
      );
    }
  }

  Future<Map<String, dynamic>> iniciarSesion({
    required String documento,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/pacientes/login',
      body: {
        'documento': documento.trim(),
        'password': password,
      },
    );
    final payload = _nestedMap(
      response,
      const ['paciente', 'user', 'data'],
    );
    return payload ??
        _asMap(
          response,
          'El servidor devolvió una respuesta de inicio de sesión inválida.',
        );
  }

  Future<Map<String, dynamic>> _archivoComoJson(File archivo) async {
    final bytes = await archivo.readAsBytes();
    return {
      'nombre': archivo.uri.pathSegments.last,
      'base64': base64Encode(bytes),
    };
  }

  Map<String, dynamic>? _nestedMap(dynamic value, List<String> keys) {
    if (value is! Map) return null;
    for (final key in keys.where((key) => key != 'data')) {
      final nested = value[key];
      if (nested is Map) {
        return _nestedMap(nested, keys) ?? Map<String, dynamic>.from(nested);
      }
    }
    final data = value['data'];
    if (data is Map) {
      return _nestedMap(data, keys) ?? Map<String, dynamic>.from(data);
    }
    return null;
  }

  Map<String, dynamic> _asMap(dynamic value, String error) {
    if (value is Map) return Map<String, dynamic>.from(value);
    if (value == null) return <String, dynamic>{};
    throw ApiException(error);
  }
}
