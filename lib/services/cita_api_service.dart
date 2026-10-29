import 'api_client.dart';

class CitaApiService {
  CitaApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Map<String, dynamic>>> listar({
    String? documentoPaciente,
  }) async {
    final query = <String, String>{};
    if (documentoPaciente != null && documentoPaciente.trim().isNotEmpty) {
      query['documentoPaciente'] = documentoPaciente.trim();
    }
    final response = await _apiClient.get(
      '/citas',
      queryParameters: query,
    );
    dynamic value = response;
    for (var depth = 0; depth < 3 && value is Map; depth++) {
      final nested = value['citas'] ?? value['items'] ?? value['data'];
      if (nested is List) {
        value = nested;
        break;
      }
      value = nested;
    }
    if (value is! List) {
      throw const ApiException(
        'El servidor devolvió una lista de citas inválida.',
      );
    }
    if (value.any((item) => item is! Map)) {
      throw const ApiException(
        'El servidor devolvió una cita con formato inválido.',
      );
    }
    return value.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  Future<Map<String, dynamic>> crear(
    Map<String, dynamic> datos,
  ) async {
    return _asMap(await _apiClient.post('/citas', body: datos));
  }

  Future<Map<String, dynamic>> actualizar(
    String id,
    Map<String, dynamic> datos,
  ) async {
    return _asMap(
      await _apiClient.put('/citas/${Uri.encodeComponent(id)}', body: datos),
    );
  }

  Future<void> cancelar(String id) async {
    await _apiClient.delete('/citas/${Uri.encodeComponent(id)}');
  }

  Map<String, dynamic> _asMap(dynamic response) {
    if (response == null) return <String, dynamic>{};
    if (response is Map) return Map<String, dynamic>.from(response);
    throw const ApiException(
      'El servidor devolvió una respuesta de cita inválida.',
    );
  }
}
