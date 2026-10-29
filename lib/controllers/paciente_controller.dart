import 'dart:io';

import '../services/api_client.dart';
import '../services/paciente_api_service.dart';

class PacienteController {
  PacienteController(this._service);

  final PacienteApiService _service;

  Future<Map<String, dynamic>> registrar({
    required Map<String, dynamic> datos,
    File? documentoFrente,
    File? documentoReverso,
  }) {
    return _service.registrar(
      datos: datos,
      documentoFrente: documentoFrente,
      documentoReverso: documentoReverso,
    );
  }

  Future<Map<String, dynamic>> iniciarSesion({
    required String documento,
    required String password,
  }) {
    return _service.iniciarSesion(
      documento: documento,
      password: password,
    );
  }
}

final pacienteController = PacienteController(
  PacienteApiService(ApiClient()),
);
