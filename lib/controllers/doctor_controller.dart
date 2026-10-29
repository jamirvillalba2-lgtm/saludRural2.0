import '../services/api_client.dart';
import '../services/doctor_api_service.dart';

class DoctorController {
  DoctorController(this._service);

  final DoctorApiService _service;

  Future<List<Map<String, dynamic>>> listar({String? especialidad}) {
    return _service.listar(especialidad: especialidad);
  }

  Future<Map<String, dynamic>> registrar({
    required String nombre,
    required String numeroRethus,
    required String especialidad,
  }) {
    return _service.registrar(
      nombre: nombre,
      numeroRethus: numeroRethus,
      especialidad: especialidad,
    );
  }
}

final doctorController = DoctorController(DoctorApiService(ApiClient()));
