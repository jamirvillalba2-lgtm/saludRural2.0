import 'package:flutter/material.dart';

import '../../../controllers/cita_controller.dart';
import '../../../services/api_client.dart';

/// Pantalla para consultar y reservar citas médicas publicadas por el hospital.
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
  static const Color _colorVerdeInstitucional = Color(0xFF0E7C57);

  static const List<String> _especialidades = [
    'Medicina General',
    'Pediatría',
    'Ginecología',
    'Medicina Interna',
  ];

  String? _especialidadSeleccionada;
  List<Map<String, dynamic>> _citasDisponibles = [];

  bool _cargando = false;
  bool _reservando = false;
  String? _errorCarga;

  @override
  void initState() {
    super.initState();
    _especialidadSeleccionada = _especialidades.first;
    _buscarCitasDisponibles();
  }

  Future<void> _buscarCitasDisponibles() async {
    setState(() {
      _cargando = true;
      _errorCarga = null;
    });

    try {
      final resultado = await citaController.listarDisponibles(
        especialidad: _especialidadSeleccionada,
      );

      if (!mounted) return;
      setState(() {
        _citasDisponibles = resultado;
      });
    } on ApiException catch (error) {
      if (!mounted) return;
      setState(() {
        _errorCarga = error.message;
      });
      _mostrarMensaje(error.message, esError: true);
    } finally {
      if (mounted) setState(() => _cargando = false);
    }
  }

  Future<void> _reservarCita(String citaId) async {
    if (citaId.isEmpty || _reservando) return;
    setState(() => _reservando = true);
    try {
      await citaController.reservar(citaId, widget.documentoPaciente);
      if (!mounted) return;
      _mostrarDialogoExito();
    } on ApiException catch (error) {
      if (!mounted) return;
      _mostrarMensaje(error.message, esError: true);
    } finally {
      if (mounted) setState(() => _reservando = false);
    }
  }

  void _mostrarDialogoExito() {
    showDialog<void>(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => AlertDialog(
        icon: const Icon(
          Icons.check_circle,
          color: _colorVerdeInstitucional,
          size: 48,
        ),
        title: Text(
          widget.citaReagendarId == null
              ? '¡Cita Reservada!'
              : '¡Cita Reagendada!',
        ),
        content: const Text(
          'Tu cita quedó reservada correctamente.',
        ),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _colorVerdeInstitucional,
            ),
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

  void _mostrarMensaje(String mensaje, {bool esError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(mensaje),
        backgroundColor: esError ? Colors.redAccent : _colorVerdeInstitucional,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F7),
      appBar: AppBar(
        backgroundColor: _colorVerdeInstitucional,
        foregroundColor: Colors.white,
        title: Text(
          widget.citaReagendarId == null
              ? 'Buscar Citas Disponibles'
              : 'Reagendar Cita',
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(18.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Filtro por Especialidad',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: DropdownButtonFormField<String>(
                    initialValue: _especialidadSeleccionada,
                    decoration: const InputDecoration(
                      labelText: 'Seleccione especialidad',
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.white,
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
                      setState(() => _especialidadSeleccionada = value);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                FilledButton.icon(
                  style: FilledButton.styleFrom(
                    backgroundColor: _colorVerdeInstitucional,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 16,
                    ),
                  ),
                  onPressed: _cargando ? null : _buscarCitasDisponibles,
                  icon: const Icon(Icons.search),
                  label: const Text('Buscar'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            const Text(
              'Horarios disponibles publicados',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 10),
            Expanded(
              child: _cargando
                  ? const Center(child: CircularProgressIndicator())
                  : _errorCarga != null
                      ? Center(
                          child: Text(
                            _errorCarga!,
                            style: const TextStyle(color: Colors.red),
                          ),
                        )
                      : _citasDisponibles.isEmpty
                          ? const Center(
                              child: Text(
                                'No hay turnos disponibles para esta especialidad.',
                                style: TextStyle(color: Colors.black54),
                              ),
                            )
                          : ListView.builder(
                              itemCount: _citasDisponibles.length,
                              itemBuilder: (context, index) {
                                final cita = _citasDisponibles[index];
                                final medicoNombre = _texto(
                                  cita['medico_nombre'],
                                  'Personal médico',
                                );
                                final especialidad =
                                    _texto(cita['especialidad']);
                                final fechaHora = _texto(cita['fecha_hora']);
                                final citaId =
                                    cita['cita_id']?.toString() ?? '';

                                return Card(
                                  margin: const EdgeInsets.only(bottom: 12),
                                  elevation: 2,
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Padding(
                                    padding: const EdgeInsets.all(16.0),
                                    child: Row(
                                      children: [
                                        const CircleAvatar(
                                          backgroundColor: Color(0xFFE1F5FE),
                                          child: Icon(
                                            Icons.medical_services,
                                            color: _colorVerdeInstitucional,
                                          ),
                                        ),
                                        const SizedBox(width: 14),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                medicoNombre,
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                ),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Especialidad: $especialidad',
                                                style: const TextStyle(
                                                    color: Colors.black54),
                                              ),
                                              const SizedBox(height: 4),
                                              Text(
                                                'Fecha y Hora: $fechaHora',
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.w600,
                                                  color:
                                                      _colorVerdeInstitucional,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        FilledButton(
                                          style: FilledButton.styleFrom(
                                            backgroundColor:
                                                _colorVerdeInstitucional,
                                          ),
                                          onPressed:
                                              _reservando || citaId.isEmpty
                                                  ? null
                                                  : () => _reservarCita(citaId),
                                          child: const Text('Reservar'),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
            ),
          ],
        ),
      ),
    );
  }

  String _texto(dynamic value, [String fallback = '']) {
    if (value == null) return fallback;
    final text = value.toString().trim();
    return text.isEmpty ? fallback : text;
  }
}
