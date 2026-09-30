import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class CitasLocalService {
  static const String _citasKey = 'paciente_citas';

  static const List<Map<String, String>> _disponibilidades = [
    {
      'id': 'CITA001',
      'especialidad': 'Medicina general',
      'medico': 'Dr. Carlos Pérez',
      'fecha': '01/10/2026',
      'hora': '08:00 AM',
      'sede': 'Centro de Salud El Guamo',
      'ubicacion': 'El Guamo',
    },
    {
      'id': 'CITA002',
      'especialidad': 'Medicina general',
      'medico': 'Dra. María López',
      'fecha': '01/10/2026',
      'hora': '10:30 AM',
      'sede': 'Centro de Salud El Guamo',
      'ubicacion': 'El Guamo',
    },
    {
      'id': 'CITA003',
      'especialidad': 'Medicina general',
      'medico': 'Dr. Andrés Martínez',
      'fecha': '02/10/2026',
      'hora': '09:00 AM',
      'sede': 'Puesto de Salud Nervití',
      'ubicacion': 'Nervití',
    },
    {
      'id': 'CITA004',
      'especialidad': 'Odontología',
      'medico': 'Dra. Laura Gómez',
      'fecha': '02/10/2026',
      'hora': '08:30 AM',
      'sede': 'Centro de Salud El Guamo',
      'ubicacion': 'El Guamo',
    },
    {
      'id': 'CITA005',
      'especialidad': 'Odontología',
      'medico': 'Dr. Juan Rodríguez',
      'fecha': '03/10/2026',
      'hora': '02:00 PM',
      'sede': 'Puesto de Salud Tasajera',
      'ubicacion': 'Tasajera',
    },
    {
      'id': 'CITA006',
      'especialidad': 'Enfermería',
      'medico': 'Enf. Ana Torres',
      'fecha': '03/10/2026',
      'hora': '09:30 AM',
      'sede': 'Puesto de Salud Robles',
      'ubicacion': 'Robles',
    },
    {
      'id': 'CITA007',
      'especialidad': 'Psicología',
      'medico': 'Dra. Daniela Castro',
      'fecha': '05/10/2026',
      'hora': '10:00 AM',
      'sede': 'Centro de Salud El Guamo',
      'ubicacion': 'El Guamo',
    },
    {
      'id': 'CITA008',
      'especialidad': 'Nutrición',
      'medico': 'Dra. Carolina Ruiz',
      'fecha': '06/10/2026',
      'hora': '08:00 AM',
      'sede': 'Puesto de Salud San José de Lata',
      'ubicacion': 'San José de Lata',
    },
    {
      'id': 'CITA009',
      'especialidad': 'Medicina familiar',
      'medico': 'Dr. Felipe Mendoza',
      'fecha': '07/10/2026',
      'hora': '11:00 AM',
      'sede': 'Puesto de Salud Santa Cruz de La Enea',
      'ubicacion': 'Santa Cruz de La Enea',
    },
    {
      'id': 'CITA010',
      'especialidad': 'Pediatría',
      'medico': 'Dra. Sofía Herrera',
      'fecha': '08/10/2026',
      'hora': '09:00 AM',
      'sede': 'Centro de Salud El Guamo',
      'ubicacion': 'El Guamo',
    },
    {
      'id': 'CITA011',
      'especialidad': 'Ginecología',
      'medico': 'Dra. Valentina Moreno',
      'fecha': '09/10/2026',
      'hora': '08:30 AM',
      'sede': 'Centro de Salud El Guamo',
      'ubicacion': 'El Guamo',
    },
  ];

  static List<String> get especialidades => const [
        'Medicina general',
        'Odontología',
        'Medicina familiar',
        'Pediatría',
        'Psicología',
        'Nutrición',
        'Ginecología',
        'Enfermería',
      ];

  static List<String> get sedes => const [
        'Todas las sedes',
        'Centro de Salud El Guamo',
        'Puesto de Salud Nervití',
        'Puesto de Salud Tasajera',
        'Puesto de Salud Robles',
        'Puesto de Salud San José de Lata',
        'Puesto de Salud Santa Cruz de La Enea',
      ];

  static List<Map<String, String>> buscarDisponibilidades({
    required String especialidad,
    String sede = 'Todas las sedes',
    String fecha = '',
  }) {
    return _disponibilidades.where((cita) {
      final coincideEspecialidad = cita['especialidad'] == especialidad;

      final coincideSede = sede == 'Todas las sedes' || cita['sede'] == sede;

      final coincideFecha = fecha.isEmpty || cita['fecha'] == fecha;

      return coincideEspecialidad && coincideSede && coincideFecha;
    }).toList();
  }

  static List<Map<String, String>> obtenerCitasCercanas({
    required String especialidad,
  }) {
    return _disponibilidades
        .where((cita) => cita['especialidad'] == especialidad)
        .take(6)
        .toList();
  }

  static Future<List<Map<String, dynamic>>> obtenerMisCitas() async {
    final prefs = await SharedPreferences.getInstance();

    final contenido = prefs.getString(_citasKey);

    if (contenido == null || contenido.isEmpty) {
      return [];
    }

    final lista = jsonDecode(contenido);

    if (lista is! List) {
      return [];
    }

    return lista
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
        )
        .toList();
  }

  static Future<void> guardarCita(
    Map<String, String> disponibilidad,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final citas = await obtenerMisCitas();

    final nuevaCita = <String, dynamic>{
      ...disponibilidad,
      'estado': 'CONFIRMADA',
      'fechaReserva': DateTime.now().toIso8601String(),
    };

    citas.add(nuevaCita);

    await prefs.setString(
      _citasKey,
      jsonEncode(citas),
    );
  }

  static Future<void> cancelarCita(String id) async {
    final prefs = await SharedPreferences.getInstance();

    final citas = await obtenerMisCitas();

    final actualizadas = citas.map((cita) {
      if (cita['id'] == id) {
        return {
          ...cita,
          'estado': 'CANCELADA',
        };
      }

      return cita;
    }).toList();

    await prefs.setString(
      _citasKey,
      jsonEncode(actualizadas),
    );
  }

  static Future<void> reagendarCita({
    required String idAnterior,
    required Map<String, String> nuevaCita,
  }) async {
    final prefs = await SharedPreferences.getInstance();

    final citas = await obtenerMisCitas();

    final actualizadas = citas.map((cita) {
      if (cita['id'] == idAnterior) {
        return <String, dynamic>{
          ...nuevaCita,
          'estado': 'CONFIRMADA',
          'fechaReserva': DateTime.now().toIso8601String(),
        };
      }

      return cita;
    }).toList();

    await prefs.setString(
      _citasKey,
      jsonEncode(actualizadas),
    );
  }

  static Future<void> guardarNotificacion(
    String titulo,
    String mensaje,
  ) async {
    final prefs = await SharedPreferences.getInstance();

    final contenido = prefs.getString('paciente_notificaciones');

    List<dynamic> notificaciones = [];

    if (contenido != null) {
      final datos = jsonDecode(contenido);

      if (datos is List) {
        notificaciones = datos;
      }
    }

    notificaciones.insert(0, {
      'titulo': titulo,
      'mensaje': mensaje,
      'fecha': DateTime.now().toIso8601String(),
      'leida': false,
    });

    await prefs.setString(
      'paciente_notificaciones',
      jsonEncode(notificaciones),
    );
  }

  static Future<List<Map<String, dynamic>>> obtenerNotificaciones() async {
    final prefs = await SharedPreferences.getInstance();

    final contenido = prefs.getString('paciente_notificaciones');

    if (contenido == null) {
      return [];
    }

    final datos = jsonDecode(contenido);

    if (datos is! List) {
      return [];
    }

    return datos
        .map<Map<String, dynamic>>(
          (item) => Map<String, dynamic>.from(item),
        )
        .toList();
  }
}
