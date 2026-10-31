import 'api_client.dart';

/// Servicio responsable de gestionar todas las peticiones HTTP
/// relacionadas con el módulo de citas médicas.
class CitaApiService {
  CitaApiService(this._apiClient);

  final ApiClient _apiClient;

  /// Obtiene el historial de citas agendadas, con filtro opcional por paciente.
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

    return _parsearListaCitas(
      response,
      'El servidor devolvió una lista de citas inválida.',
    );
  }

  /// Consulta las citas publicadas como 'Disponible' por el hospital,
  /// permitiendo filtrar opcionalmente por especialidad médica.
  Future<List<Map<String, dynamic>>> listarDisponibles({
    String? especialidad,
  }) async {
    final query = <String, String>{};
    if (especialidad != null && especialidad.trim().isNotEmpty) {
      query['especialidad'] = especialidad.trim();
    }

    final response = await _apiClient.get(
      '/citas/disponibles',
      queryParameters: query,
    );

    return _parsearListaCitas(
      response,
      'El servidor devolvió una lista de citas disponibles inválida.',
    );
  }

  /// Reserva un cupo disponible asignándolo al paciente mediante su documento.
  Future<Map<String, dynamic>> reservar(
    String citaId,
    String documentoPaciente,
  ) async {
    return _asMap(
      await _apiClient.put(
        '/citas/reservar/${Uri.encodeComponent(citaId)}',
        body: {'documentoPaciente': documentoPaciente},
      ),
    );
  }

  /// Método tradicional para crear una cita nueva.
  Future<Map<String, dynamic>> crear(
    Map<String, dynamic> datos,
  ) async {
    return _asMap(await _apiClient.post('/citas', body: datos));
  }

  /// Actualiza los datos de una cita existente o su horario.
  Future<Map<String, dynamic>> actualizar(
    String id,
    Map<String, dynamic> datos,
  ) async {
    return _asMap(
      await _apiClient.put('/citas/${Uri.encodeComponent(id)}', body: datos),
    );
  }

  /// Cancela o libera una cita médica.
  Future<void> cancelar(String id) async {
    await _apiClient.delete('/citas/${Uri.encodeComponent(id)}');
  }

  /// Método auxiliar robusto para parsear y validar listas JSON anidadas.
  List<Map<String, dynamic>> _parsearListaCitas(
    dynamic response,
    String mensajeError,
  ) {
    dynamic value = response;
    for (var depth = 0; depth < 3 && value is Map; depth++) {
      final nested = value['citasDisponibles'] ?? value['citas'] ?? value['items'] ?? value['data'];
      if (nested is List) {
        value = nested;
        break;
      }
      value = nested;
    }

    if (value is! List) {
      throw ApiException(mensajeError);
    }
    if (value.any((item) => item is! Map)) {
      throw const ApiException('El servidor devolvió una cita con formato inválido.');
    }

    return value.map((item) => Map<String, dynamic>.from(item)).toList();
  }

  /// Método auxiliar para asegurar formato de mapa en respuestas individuales.
  Map<String, dynamic> _asMap(dynamic response) {
    if (response == null) return <String, dynamic>{};
    if (response is Map) return Map<String, dynamic>.from(response);
    throw const ApiException(
      'El servidor devolvió una respuesta de cita inválida.',
    );
  }
}
