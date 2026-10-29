import 'package:flutter/material.dart';

import '../../../controllers/cita_controller.dart';
import '../../../services/api_client.dart';
import 'paciente_mis_citas_disponibles.dart';

/// ===============================================================
/// MIS CITAS DEL PACIENTE
/// Proyecto: Salud Rural
///
/// Funciones:
/// - Consultar citas registradas
/// - Ver detalle
/// - Cancelar cita
/// - Reagendar cita
/// - Agendar una nueva cita
/// ===============================================================
class PacienteMisCitas extends StatefulWidget {
  /// Se conservan estos datos para mantener compatibilidad
  /// con el dashboard actual.
  final String cc;
  final String nombre;

  const PacienteMisCitas({
    super.key,
    required this.cc,
    required this.nombre,
  });

  @override
  State<PacienteMisCitas> createState() => _PacienteMisCitasState();
}

class _PacienteMisCitasState extends State<PacienteMisCitas> {
  // ===============================================================
  // COLORES
  // ===============================================================

  static const Color verdePrincipal = Color(0xFF0E7C57);
  static const Color verdeClaro = Color(0xFFE8F5EF);
  static const Color fondo = Color(0xFFF5F8F7);
  static const Color textoPrincipal = Color(0xFF1F2937);
  static const Color textoSecundario = Color(0xFF6B7280);
  static const Color rojo = Color(0xFFB42318);

  // ===============================================================
  // ESTADO
  // ===============================================================

  List<Map<String, dynamic>> _citas = [];

  bool _cargando = true;

  // ===============================================================
  // CICLO DE VIDA
  // ===============================================================

  @override
  void initState() {
    super.initState();
    _cargarCitas();
  }

  // ===============================================================
  // CARGAR CITAS
  // ===============================================================

  Future<void> _cargarCitas() async {
    try {
      final citas = await citaController.listar(
        documentoPaciente: widget.cc,
      );

      if (!mounted) return;

      setState(() {
        _citas = citas;
        _cargando = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() {
        _citas = [];
        _cargando = false;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  }

  // ===============================================================
  // AGENDAR NUEVA CITA
  // ===============================================================

  Future<void> _agendarNuevaCita() async {
    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PacienteCitasDisponiblesScreen(
          documentoPaciente: widget.cc,
        ),
      ),
    );

    if (!mounted) return;

    if (resultado == true) {
      await _cargarCitas();
    }
  }

  // ===============================================================
  // REAGENDAR CITA
  // ===============================================================

  Future<void> _reagendarCita(
    Map<String, dynamic> cita,
  ) async {
    final id = (cita['id'] ?? cita['_id'])?.toString();

    if (id == null || id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se encontró el identificador de la cita.',
          ),
        ),
      );
      return;
    }

    final resultado = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => PacienteCitasDisponiblesScreen(
          documentoPaciente: widget.cc,
          citaReagendarId: id,
        ),
      ),
    );

    if (!mounted) return;

    if (resultado == true) {
      await _cargarCitas();
    }
  }

  // ===============================================================
  // CANCELAR CITA
  // ===============================================================

  Future<void> _cancelarCita(
    Map<String, dynamic> cita,
  ) async {
    final id = (cita['id'] ?? cita['_id'])?.toString();

    if (id == null || id.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'No se encontró el identificador de la cita.',
          ),
        ),
      );
      return;
    }

    final confirmar = await showDialog<bool>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          ),
          title: const Text(
            'Cancelar cita',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            '¿Deseas cancelar la cita de '
            '${_valor(cita['especialidad'], 'atención médica')} '
            'con ${_valor(cita['medico'], 'el profesional asignado')}?',
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(dialogContext, false);
              },
              child: const Text('No'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: rojo,
              ),
              onPressed: () {
                Navigator.pop(dialogContext, true);
              },
              child: const Text('Sí, cancelar'),
            ),
          ],
        );
      },
    );

    if (confirmar != true) return;

    try {
      await citaController.cancelar(id);
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
      return;
    }

    if (!mounted) return;

    await _cargarCitas();

    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text(
          'La cita fue cancelada correctamente.',
        ),
      ),
    );
  }

  // ===============================================================
  // DETALLE DE CITA
  // ===============================================================

  void _mostrarDetalle(
    Map<String, dynamic> cita,
  ) {
    final estado = _estadoCita(cita);

    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      backgroundColor: Colors.white,
      builder: (sheetContext) {
        return SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(
              20,
              8,
              20,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Detalle de la cita',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.w800,
                    color: textoPrincipal,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  _valor(
                    cita['especialidad'],
                    'Atención médica',
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    color: textoSecundario,
                  ),
                ),
                const SizedBox(height: 20),
                _dato(
                  'Especialidad',
                  cita['especialidad'],
                ),
                _dato(
                  'Profesional',
                  cita['medico'] ?? cita['profesional'],
                ),
                _dato(
                  'Fecha',
                  cita['fecha'],
                ),
                _dato(
                  'Hora',
                  cita['hora'],
                ),
                _dato(
                  'Sede',
                  cita['sede'],
                ),
                _dato(
                  'Ubicación',
                  cita['ubicacion'],
                ),
                _dato(
                  'Estado',
                  estado,
                ),
                const SizedBox(height: 14),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: estado == 'CANCELADA'
                        ? null
                        : () {
                            Navigator.pop(sheetContext);
                            _reagendarCita(cita);
                          },
                    icon: const Icon(
                      Icons.edit_calendar_outlined,
                    ),
                    label: const Text(
                      'Reagendar cita',
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  // ===============================================================
  // DATO DE DETALLE
  // ===============================================================

  Widget _dato(
    String titulo,
    dynamic valor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(
        bottom: 11,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 105,
            child: Text(
              '$titulo:',
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: textoPrincipal,
              ),
            ),
          ),
          Expanded(
            child: Text(
              _valor(
                valor,
                'No disponible',
              ),
              style: const TextStyle(
                color: textoSecundario,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // BUILD
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,
      appBar: AppBar(
        backgroundColor: verdePrincipal,
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Mis citas',
          style: TextStyle(
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
      body: _cargando
          ? const Center(
              child: CircularProgressIndicator(
                color: verdePrincipal,
              ),
            )
          : RefreshIndicator(
              color: verdePrincipal,
              onRefresh: _cargarCitas,
              child: _citas.isEmpty ? _buildEmptyState() : _buildCitasList(),
            ),
    );
  }

  // ===============================================================
  // ESTADO VACÍO
  // ===============================================================

  Widget _buildEmptyState() {
    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.fromLTRB(
        24,
        70,
        24,
        30,
      ),
      children: [
        Center(
          child: Container(
            width: 82,
            height: 82,
            decoration: BoxDecoration(
              color: verdeClaro,
              borderRadius: BorderRadius.circular(24),
            ),
            child: const Icon(
              Icons.calendar_month_outlined,
              size: 42,
              color: verdePrincipal,
            ),
          ),
        ),
        const SizedBox(height: 22),
        const Text(
          'No tienes citas registradas',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: textoPrincipal,
          ),
        ),
        const SizedBox(height: 8),
        const Text(
          'Puedes buscar una cita disponible '
          'en las diferentes sedes de atención.',
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 14,
            color: textoSecundario,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 26),
        SizedBox(
          height: 52,
          child: FilledButton.icon(
            onPressed: _agendarNuevaCita,
            icon: const Icon(
              Icons.add_circle_outline_rounded,
            ),
            label: const Text(
              'Agendar cita',
              style: TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: verdePrincipal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(15),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // LISTA DE CITAS
  // ===============================================================

  Widget _buildCitasList() {
    return ListView.builder(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.all(16),
      itemCount: _citas.length,
      itemBuilder: (context, index) {
        final cita = _citas[index];

        return _buildCitaCard(cita);
      },
    );
  }

  // ===============================================================
  // TARJETA DE CITA
  // ===============================================================

  Widget _buildCitaCard(
    Map<String, dynamic> cita,
  ) {
    final estado = _estadoCita(cita);
    final cancelada = estado == 'CANCELADA';

    return Card(
      margin: const EdgeInsets.only(
        bottom: 14,
      ),
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: const BorderSide(
          color: Color(0xFFE5E7EB),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 46,
                  height: 46,
                  decoration: BoxDecoration(
                    color: cancelada ? const Color(0xFFFDECEC) : verdeClaro,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    cancelada
                        ? Icons.event_busy_rounded
                        : Icons.event_available_rounded,
                    color: cancelada ? rojo : verdePrincipal,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _valor(
                      cita['especialidad'],
                      'Servicio de salud',
                    ),
                    style: const TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: textoPrincipal,
                    ),
                  ),
                ),
                _buildEstadoChip(
                  estado,
                  cancelada,
                ),
              ],
            ),
            const SizedBox(height: 16),
            _dato(
              'Profesional',
              cita['medico'] ?? cita['profesional'],
            ),
            _dato(
              'Fecha',
              cita['fecha'],
            ),
            _dato(
              'Hora',
              cita['hora'],
            ),
            _dato(
              'Sede',
              cita['sede'],
            ),
            const SizedBox(height: 8),
            _buildActionButtons(
              cita,
              cancelada,
            ),
          ],
        ),
      ),
    );
  }

  // ===============================================================
  // ESTADO
  // ===============================================================

  Widget _buildEstadoChip(
    String estado,
    bool cancelada,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 9,
        vertical: 6,
      ),
      decoration: BoxDecoration(
        color: cancelada ? const Color(0xFFFDECEC) : verdeClaro,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        estado,
        style: TextStyle(
          color: cancelada ? rojo : verdePrincipal,
          fontSize: 10,
          fontWeight: FontWeight.w800,
        ),
      ),
    );
  }

  // ===============================================================
  // BOTONES DE CITA
  // ===============================================================

  Widget _buildActionButtons(
    Map<String, dynamic> cita,
    bool cancelada,
  ) {
    return Row(
      children: [
        Expanded(
          child: OutlinedButton(
            onPressed: () => _mostrarDetalle(cita),
            style: OutlinedButton.styleFrom(
              foregroundColor: verdePrincipal,
              side: const BorderSide(
                color: verdePrincipal,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text(
              'Ver detalle',
            ),
          ),
        ),
        if (!cancelada) ...[
          const SizedBox(width: 8),
          Expanded(
            child: OutlinedButton(
              onPressed: () => _reagendarCita(cita),
              style: OutlinedButton.styleFrom(
                foregroundColor: verdePrincipal,
                side: const BorderSide(
                  color: verdePrincipal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: const Text(
                'Reagendar',
              ),
            ),
          ),
          const SizedBox(width: 4),
          IconButton(
            tooltip: 'Cancelar cita',
            onPressed: () => _cancelarCita(cita),
            color: rojo,
            icon: const Icon(
              Icons.cancel_outlined,
            ),
          ),
        ],
      ],
    );
  }

  // ===============================================================
  // UTILIDADES
  // ===============================================================

  String _estadoCita(
    Map<String, dynamic> cita,
  ) {
    final estado = cita['estado']?.toString().trim();

    if (estado == null || estado.isEmpty) {
      return 'CONFIRMADA';
    }

    return estado.toUpperCase();
  }

  String _valor(
    dynamic valor,
    String defecto,
  ) {
    if (valor == null) {
      return defecto;
    }

    final texto = valor.toString().trim();

    if (texto.isEmpty) {
      return defecto;
    }

    return texto;
  }
}
