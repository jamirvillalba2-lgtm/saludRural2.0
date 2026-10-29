import '../services/api_client.dart';
import '../services/cita_api_service.dart';

class CitaController {
  CitaController(this._service);

  final CitaApiService _service;

  Future<List<Map<String, dynamic>>> listar({
    String? documentoPaciente,
  }) {
    return _service.listar(documentoPaciente: documentoPaciente);
  }

  Future<Map<String, dynamic>> crear(Map<String, dynamic> datos) {
    return _service.crear(datos);
  }

  Future<Map<String, dynamic>> actualizar(
    String id,
    Map<String, dynamic> datos,
  ) {
    return _service.actualizar(id, datos);
  }

  Future<void> cancelar(String id) => _service.cancelar(id);
}

final citaController = CitaController(CitaApiService(ApiClient()));
