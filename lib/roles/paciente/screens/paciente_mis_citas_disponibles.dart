import 'package:flutter/material.dart';

import '../../../controllers/cita_controller.dart';
import '../../../controllers/doctor_controller.dart';
import '../../../services/api_client.dart';

class PacienteCitasDisponiblesScreen extends StatefulWidget {
  final String documentoPaciente;
  final String? citaReagendarId;

  const PacienteCitasDisponiblesScreen({
    super.key,
    required this.documentoPaciente,
    this.citaReagendarId,
  });

  @override
  State<PacienteCitasDisponiblesScreen> createState() =>
      _PacienteCitasDisponiblesScreenState();
}

class _PacienteCitasDisponiblesScreenState
    extends State<PacienteCitasDisponiblesScreen> {
  static const Color verde = Color(0xFF0E7C57);

  List<Map<String, dynamic>> _doctores = [];
  List<String> _especialidades = [];
  String? _especialidad;
  String? _doctorId;
  DateTime? _fecha;
  TimeOfDay? _hora;
  bool _cargandoDoctores = true;
  bool _enviando = false;
  String? _errorCarga;

  @override
  void initState() {
    super.initState();
    _cargarEspecialidades();
  }

  Future<void> _cargarEspecialidades() async {
    try {
      final doctores = await doctorController.listar();
      final especialidades = doctores
          .map((doctor) => _valor(doctor, ['especialidad']))
          .where((value) => value.isNotEmpty)
          .toSet()
          .toList()
        ..sort();
      if (!mounted) return;
      setState(() {
        _especialidades = especialidades;
        _especialidad = especialidades.isEmpty ? null : especialidades.first;
        _doctores = doctores;
        _cargandoDoctores = false;
        _errorCarga = null;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _cargandoDoctores = false;
        _errorCarga = error.message;
      });
      _mostrarError(error.message);
    }
  }

  Future<void> _cargarDoctoresPorEspecialidad(String especialidad) async {
    setState(() {
      _cargandoDoctores = true;
      _doctorId = null;
      _doctores = [];
    });
    try {
      final doctores =
          await doctorController.listar(especialidad: especialidad);
      if (!mounted) return;
      setState(() {
        _doctores = doctores;
        _cargandoDoctores = false;
        _errorCarga = null;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _cargandoDoctores = false;
        _errorCarga = error.message;
      });
      _mostrarError(error.message);
    }
  }

  Future<void> _seleccionarFecha() async {
    final ahora = DateTime.now();
    final seleccionada = await showDatePicker(
      context: context,
      firstDate: DateTime(ahora.year, ahora.month, ahora.day),
      lastDate: ahora.add(const Duration(days: 180)),
      initialDate: _fecha ?? ahora,
    );
    if (seleccionada != null) {
      setState(() => _fecha = seleccionada);
    }
  }

  Future<void> _seleccionarHora() async {
    final seleccionada = await showTimePicker(
      context: context,
      initialTime: _hora ?? TimeOfDay.now(),
    );
    if (seleccionada != null) {
      setState(() => _hora = seleccionada);
    }
  }

  Future<void> _confirmarCita() async {
    if (_doctorId == null || _fecha == null || _hora == null) {
      _mostrarError('Selecciona el profesional, la fecha y la hora.');
      return;
    }

    final doctor = _doctores.firstWhere(
      (item) => _idDoctor(item) == _doctorId,
    );
    final datos = <String, dynamic>{
      'documentoPaciente': widget.documentoPaciente,
      'doctorId': _doctorId,
      'medico': _valor(doctor, ['nombre', 'nombreCompleto']),
      'especialidad': _valor(doctor, ['especialidad']),
      'sede': _valor(doctor, ['sede', 'centroSalud']),
      'fecha': _fechaIso(_fecha!),
      'hora': '${_hora!.hour.toString().padLeft(2, '0')}:'
          '${_hora!.minute.toString().padLeft(2, '0')}',
    };

    setState(() => _enviando = true);
    try {
      final id = widget.citaReagendarId;
      if (id == null) {
        await citaController.crear(datos);
      } else {
        await citaController.actualizar(id, datos);
      }
      if (!mounted) return;
      _mostrarResultado();
    } on ApiException catch (error) {
      if (!mounted) return;
      _mostrarError(error.message);
    } finally {
      if (mounted) setState(() => _enviando = false);
    }
  }

  void _mostrarResultado() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(Icons.check_circle, color: verde, size: 48),
        title: Text(
          widget.citaReagendarId == null ? 'Cita agendada' : 'Cita reagendada',
        ),
        content: const Text(
          'El servidor confirmó el horario y registró la cita.',
        ),
        actions: [
          FilledButton(
            onPressed: () {
              Navigator.pop(dialogContext);
              Navigator.pop(context, true);
            },
            child: const Text('Continuar'),
          ),
        ],
      ),
    );
  }

  String _idDoctor(Map<String, dynamic> doctor) {
    return _valor(doctor, ['id', '_id', 'doctorId']);
  }

  String _valor(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return '';
  }

  String _fechaIso(DateTime fecha) {
    return '${fecha.year.toString().padLeft(4, '0')}-'
        '${fecha.month.toString().padLeft(2, '0')}-'
        '${fecha.day.toString().padLeft(2, '0')}';
  }

  void _mostrarError(String mensaje) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(mensaje)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final doctorSeleccionado = _doctores.where(
      (doctor) => _idDoctor(doctor) == _doctorId,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F7),
      appBar: AppBar(
        backgroundColor: verde,
        foregroundColor: Colors.white,
        title: Text(
          widget.citaReagendarId == null ? 'Agendar cita' : 'Reagendar cita',
        ),
      ),
      body: _cargandoDoctores
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
              onRefresh: _cargarEspecialidades,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(18),
                children: [
                  const Text(
                    'Elige profesional y horario',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'La disponibilidad se valida en el servidor al guardar. '
                    'Si alguien toma el horario primero, podrás elegir otro.',
                    style: TextStyle(color: Colors.black54, height: 1.4),
                  ),
                  const SizedBox(height: 20),
                  if (_errorCarga != null)
                    Card(
                      child: ListTile(
                        leading: const Icon(Icons.cloud_off, color: Colors.red),
                        title: Text(_errorCarga!),
                        trailing: IconButton(
                          onPressed: _cargarEspecialidades,
                          icon: const Icon(Icons.refresh),
                        ),
                      ),
                    ),
                  if (_especialidades.isNotEmpty) ...[
                    DropdownButtonFormField<String>(
                      key: ValueKey(_especialidad),
                      initialValue: _especialidad,
                      decoration: const InputDecoration(
                        labelText: 'Especialidad',
                        border: OutlineInputBorder(),
                      ),
                      items: _especialidades
                          .map(
                            (item) => DropdownMenuItem(
                              value: item,
                              child: Text(item),
                            ),
                          )
                          .toList(),
                      onChanged: (value) {
                        if (value == null) return;
                        setState(() => _especialidad = value);
                        _cargarDoctoresPorEspecialidad(value);
                      },
                    ),
                    const SizedBox(height: 14),
                  ],
                  if (_doctores.isNotEmpty)
                    DropdownButtonFormField<String>(
                      key: ValueKey(_doctorId),
                      initialValue: _doctorId,
                      isExpanded: true,
                      decoration: const InputDecoration(
                        labelText: 'Profesional',
                        border: OutlineInputBorder(),
                      ),
                      items: _doctores
                          .map((doctor) {
                            final id = _idDoctor(doctor);
                            final nombre = _valor(
                              doctor,
                              ['nombre', 'nombreCompleto'],
                            );
                            return DropdownMenuItem(
                              value: id,
                              child: Text(
                                nombre.isEmpty ? 'Profesional $id' : nombre,
                                overflow: TextOverflow.ellipsis,
                              ),
                            );
                          })
                          .where((item) => item.value?.isNotEmpty ?? false)
                          .toList(),
                      onChanged: (value) => setState(() => _doctorId = value),
                    )
                  else
                    const Card(
                      child: Padding(
                        padding: EdgeInsets.all(16),
                        child: Text('No hay profesionales para mostrar.'),
                      ),
                    ),
                  if (doctorSeleccionado.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    Text(
                      'Especialidad: ${_valor(doctorSeleccionado.first, [
                            'especialidad'
                          ])}',
                      style: const TextStyle(color: Colors.black54),
                    ),
                  ],
                  const SizedBox(height: 18),
                  OutlinedButton.icon(
                    onPressed: _seleccionarFecha,
                    icon: const Icon(Icons.calendar_today),
                    label: Text(
                      _fecha == null
                          ? 'Seleccionar fecha'
                          : '${_fecha!.day.toString().padLeft(2, '0')}/'
                              '${_fecha!.month.toString().padLeft(2, '0')}/'
                              '${_fecha!.year}',
                    ),
                  ),
                  const SizedBox(height: 10),
                  OutlinedButton.icon(
                    onPressed: _seleccionarHora,
                    icon: const Icon(Icons.access_time),
                    label: Text(
                      _hora?.format(context) ?? 'Seleccionar hora',
                    ),
                  ),
                  const SizedBox(height: 24),
                  FilledButton(
                    onPressed:
                        _enviando || _doctores.isEmpty ? null : _confirmarCita,
                    style: FilledButton.styleFrom(
                      backgroundColor: verde,
                      padding: const EdgeInsets.symmetric(vertical: 15),
                    ),
                    child: _enviando
                        ? const SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: Colors.white,
                            ),
                          )
                        : Text(
                            widget.citaReagendarId == null
                                ? 'Confirmar cita'
                                : 'Guardar nuevo horario',
                          ),
                  ),
                ],
              ),
            ),
    );
  }
}
