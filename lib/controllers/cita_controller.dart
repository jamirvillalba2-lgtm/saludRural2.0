import '../services/api_client.dart';
import '../services/cita_api_service.dart';

/// Controlador centralizado para la gestión de citas médicas del paciente.
class CitaController {
  CitaController(this._service);

  final CitaApiService _service;

  /// Obtiene el historial de citas agendadas de un paciente específico.
  Future<List<Map<String, dynamic>>> listar({
    String? documentoPaciente,
  }) {
    return _service.listar(documentoPaciente: documentoPaciente);
  }

  /// Consulta las citas publicadas como 'Disponible' por el hospital,
  /// permitiendo filtrar opcionalmente por especialidad médica.
  Future<List<Map<String, dynamic>>> listarDisponibles({
    String? especialidad,
  }) {
    return _service.listarDisponibles(especialidad: especialidad);
  }

  /// Toma un cupo disponible y lo asigna al paciente actual.
  Future<Map<String, dynamic>> reservar(
    String citaId,
    String documentoPaciente,
  ) {
    return _service.reservar(citaId, documentoPaciente);
  }

  /// Método tradicional para crear una cita (si aplica según el flujo).
  Future<Map<String, dynamic>> crear(Map<String, dynamic> datos) {
    return _service.crear(datos);
  }

  /// Actualiza los datos de una cita existente.
  Future<Map<String, dynamic>> actualizar(
    String id,
    Map<String, dynamic> datos,
  ) {
    return _service.actualizar(id, datos);
  }

  /// Cancela o libera una cita activa.
  Future<void> cancelar(String id) => _service.cancelar(id);
}

// Instancia global reutilizable en la aplicación
final citaController = CitaController(CitaApiService(ApiClient()));
