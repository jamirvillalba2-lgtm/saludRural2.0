import 'package:shared_preferences/shared_preferences.dart';

class PacienteLocalService {
  static const String _registradoKey = 'paciente_registrado';
  static const String _ccKey = 'paciente_cc';
  static const String _passwordKey = 'paciente_password';

  static const String _nombreKey = 'paciente_nombre';
  static const String _direccionKey = 'paciente_direccion';
  static const String _veredaKey = 'paciente_vereda';
  static const String _municipioKey = 'paciente_municipio';
  static const String _telefonoKey = 'paciente_telefono';
  static const String _correoKey = 'paciente_correo';
  static const String _epsKey = 'paciente_eps';

  static const String _rhKey = 'paciente_rh';
  static const String _fechaNacimientoKey = 'paciente_fecha_nacimiento';
  static const String _sexoKey = 'paciente_sexo';

  // ---------------------------------------------------------------
  // GUARDAR PACIENTE
  // ---------------------------------------------------------------

  static Future<void> guardarPaciente({
    required String cc,
    required String password,
    required String nombre,
    required String direccion,
    required String vereda,
    required String municipio,
    required String telefono,
    required String correo,
    required String eps,
    required String rh,
    required String fechaNacimiento,
    required String sexo,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.setBool(
      _registradoKey,
      true,
    );

    await prefs.setString(
      _ccKey,
      cc.trim(),
    );

    await prefs.setString(
      _passwordKey,
      password,
    );

    await prefs.setString(
      _nombreKey,
      nombre.trim(),
    );

    await prefs.setString(
      _direccionKey,
      direccion.trim(),
    );

    await prefs.setString(
      _veredaKey,
      vereda.trim(),
    );

    await prefs.setString(
      _municipioKey,
      municipio.trim(),
    );

    await prefs.setString(
      _telefonoKey,
      telefono.trim(),
    );

    await prefs.setString(
      _correoKey,
      correo.trim(),
    );

    await prefs.setString(
      _epsKey,
      eps.trim(),
    );

    await prefs.setString(
      _rhKey,
      rh.trim(),
    );

    await prefs.setString(
      _fechaNacimientoKey,
      fechaNacimiento.trim(),
    );

    await prefs.setString(
      _sexoKey,
      sexo.trim(),
    );
  }

  // ---------------------------------------------------------------
  // VALIDAR LOGIN
  // ---------------------------------------------------------------

  static Future<bool> validarCredenciales({
    required String cc,
    required String password,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final registrado = prefs.getBool(_registradoKey) ?? false;

    if (!registrado) {
      return false;
    }

    final ccGuardada = prefs.getString(_ccKey) ?? '';

    final passwordGuardada = prefs.getString(_passwordKey) ?? '';

    return cc.trim() == ccGuardada && password == passwordGuardada;
  }

  // ---------------------------------------------------------------
  // OBTENER DATOS DEL PACIENTE
  // ---------------------------------------------------------------

  static Future<Map<String, String>> obtenerPaciente() async {
    final prefs = await SharedPreferences.getInstance();

    return {
      'cc': prefs.getString(_ccKey) ?? '',
      'nombre': prefs.getString(_nombreKey) ?? '',
      'direccion': prefs.getString(_direccionKey) ?? '',
      'vereda': prefs.getString(_veredaKey) ?? '',
      'municipio': prefs.getString(_municipioKey) ?? '',
      'telefono': prefs.getString(_telefonoKey) ?? '',
      'correo': prefs.getString(_correoKey) ?? '',
      'eps': prefs.getString(_epsKey) ?? '',
      'rh': prefs.getString(_rhKey) ?? '',
      'fechaNacimiento': prefs.getString(_fechaNacimientoKey) ?? '',
      'sexo': prefs.getString(_sexoKey) ?? '',
    };
  }

  // ---------------------------------------------------------------
  // SABER SI EXISTE UN REGISTRO
  // ---------------------------------------------------------------

  static Future<bool> existePaciente() async {
    final prefs = await SharedPreferences.getInstance();

    return prefs.getBool(_registradoKey) ?? false;
  }

  // ---------------------------------------------------------------
  // ELIMINAR REGISTRO LOCAL
  // ---------------------------------------------------------------

  static Future<void> eliminarPaciente() async {
    final prefs = await SharedPreferences.getInstance();

    await prefs.remove(_registradoKey);
    await prefs.remove(_ccKey);
    await prefs.remove(_passwordKey);
    await prefs.remove(_nombreKey);
    await prefs.remove(_direccionKey);
    await prefs.remove(_veredaKey);
    await prefs.remove(_municipioKey);
    await prefs.remove(_telefonoKey);
    await prefs.remove(_correoKey);
    await prefs.remove(_epsKey);
    await prefs.remove(_rhKey);
    await prefs.remove(_fechaNacimientoKey);
    await prefs.remove(_sexoKey);
  }
}
