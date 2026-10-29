import 'api_client.dart';

class DoctorApiService {
  DoctorApiService(this._apiClient);

  final ApiClient _apiClient;

  Future<List<Map<String, dynamic>>> listar({
    String? especialidad,
  }) async {
    final query = <String, String>{};
    if (especialidad != null && especialidad.trim().isNotEmpty) {
      query['especialidad'] = especialidad.trim();
    }
    return _asList(await _apiClient.get('/doctores', queryParameters: query));
  }

  Future<Map<String, dynamic>> registrar({
    required String nombre,
    required String numeroRethus,
    required String especialidad,
  }) async {
    final response = await _apiClient.post(
      '/doctores/registro',
      body: {
        'nombre': nombre.trim(),
        'numeroRethus': numeroRethus.trim(),
        'especialidad': especialidad.trim(),
      },
    );
    if (response == null) return <String, dynamic>{};
    if (response is Map) return Map<String, dynamic>.from(response);
    throw const ApiException(
      'El servidor devolvió una respuesta de registro médico inválida.',
    );
  }

  List<Map<String, dynamic>> _asList(dynamic response) {
    dynamic value = response;
    for (var depth = 0; depth < 3 && value is Map; depth++) {
      final nested = value['doctores'] ?? value['items'] ?? value['data'];
      if (nested is List) {
        value = nested;
        break;
      }
      value = nested;
    }
    if (value is! List) {
      throw const ApiException(
        'El servidor devolvió una lista de médicos inválida.',
      );
    }
    if (value.any((item) => item is! Map)) {
      throw const ApiException(
        'El servidor devolvió un médico con formato inválido.',
      );
    }
    return value.map((item) => Map<String, dynamic>.from(item)).toList();
  }
}
