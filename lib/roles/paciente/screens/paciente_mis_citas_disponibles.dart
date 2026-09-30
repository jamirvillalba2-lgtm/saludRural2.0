import 'package:flutter/material.dart';

import '../services/citas_local_service.dart';

class PacienteCitasDisponiblesScreen extends StatefulWidget {
  final String? citaReagendarId;

  const PacienteCitasDisponiblesScreen({
    super.key,
    this.citaReagendarId,
  });

  @override
  State<PacienteCitasDisponiblesScreen> createState() =>
      _PacienteCitasDisponiblesScreenState();
}

class _PacienteCitasDisponiblesScreenState
    extends State<PacienteCitasDisponiblesScreen> {
  static const Color verde = Color(0xFF0E7C57);
  static const Color verdeClaro = Color(0xFFE8F5EF);

  String especialidad = 'Medicina general';
  String sede = 'Todas las sedes';
  String fecha = '';

  bool mostrandoCercanas = false;

  List<Map<String, String>> resultados = [];

  @override
  void initState() {
    super.initState();
    _buscar();
  }

  void _buscar() {
    setState(() {
      mostrandoCercanas = false;

      resultados = CitasLocalService.buscarDisponibilidades(
        especialidad: especialidad,
        sede: sede,
        fecha: fecha,
      );
    });
  }

  void _buscarCercanas() {
    setState(() {
      mostrandoCercanas = true;

      resultados = CitasLocalService.obtenerCitasCercanas(
        especialidad: especialidad,
      );
    });
  }

  Future<void> _seleccionarCita(
    Map<String, String> cita,
  ) async {
    final confirmar = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            'Confirmar cita',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _detalle('Especialidad', cita['especialidad']!),
              _detalle('Profesional', cita['medico']!),
              _detalle('Fecha', cita['fecha']!),
              _detalle('Hora', cita['hora']!),
              _detalle('Sede', cita['sede']!),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: verde,
              ),
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Confirmar cita'),
            ),
          ],
        );
      },
    );

    if (confirmar != true || !mounted) {
      return;
    }

    if (widget.citaReagendarId != null) {
      await CitasLocalService.reagendarCita(
        idAnterior: widget.citaReagendarId!,
        nuevaCita: cita,
      );

      await CitasLocalService.guardarNotificacion(
        'Cita reagendada',
        '${cita['especialidad']} con ${cita['medico']} '
            'el ${cita['fecha']} a las ${cita['hora']}.',
      );

      if (!mounted) return;

      _mostrarResultado(
        'Cita reagendada',
        'Tu nueva cita fue registrada correctamente.',
      );

      return;
    }

    await CitasLocalService.guardarCita(cita);

    await CitasLocalService.guardarNotificacion(
      'Cita confirmada',
      '${cita['especialidad']} con ${cita['medico']} '
          'el ${cita['fecha']} a las ${cita['hora']}.',
    );

    if (!mounted) return;

    _mostrarResultado(
      'Cita apartada',
      'Tu cita fue registrada correctamente.',
    );
  }

  void _mostrarResultado(
    String titulo,
    String mensaje,
  ) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          icon: const Icon(
            Icons.check_circle_rounded,
            color: verde,
            size: 50,
          ),
          title: Text(
            titulo,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          content: Text(
            mensaje,
            textAlign: TextAlign.center,
          ),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: verde,
              ),
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context, true);
              },
              child: const Text('Continuar'),
            ),
          ],
        );
      },
    );
  }

  Widget _detalle(String titulo, String valor) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 4,
            child: Text(
              titulo,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 12,
              ),
            ),
          ),
          Expanded(
            flex: 6,
            child: Text(
              valor,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _seleccionarFecha() async {
    final ahora = DateTime.now();

    final fechaSeleccionada = await showDatePicker(
      context: context,
      firstDate: ahora,
      lastDate: ahora.add(
        const Duration(days: 90),
      ),
      initialDate: ahora,
    );

    if (fechaSeleccionada == null) {
      return;
    }

    final dia = fechaSeleccionada.day.toString().padLeft(2, '0');

    final mes = fechaSeleccionada.month.toString().padLeft(2, '0');

    setState(() {
      fecha = '$dia/$mes/${fechaSeleccionada.year}';
    });

    _buscar();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F7),
      appBar: AppBar(
        backgroundColor: verde,
        foregroundColor: Colors.white,
        title: Text(
          widget.citaReagendarId == null ? 'Agendar cita' : 'Reagendar cita',
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _encabezado(),
            const SizedBox(height: 18),
            _filtros(),
            const SizedBox(height: 22),
            Row(
              children: [
                const Expanded(
                  child: Text(
                    'Citas disponibles',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                Text(
                  '${resultados.length} disponibles',
                  style: const TextStyle(
                    color: verde,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            if (resultados.isEmpty)
              _sinResultados()
            else
              ...resultados.map(_tarjetaCita),
          ],
        ),
      ),
    );
  }

  Widget _encabezado() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: verde,
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.calendar_month_rounded,
            color: Colors.white,
            size: 35,
          ),
          SizedBox(height: 12),
          Text(
            'Encuentra tu cita',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w800,
            ),
          ),
          SizedBox(height: 5),
          Text(
            'Selecciona la especialidad y consulta las '
            'citas disponibles por fecha y sede.',
            style: TextStyle(
              color: Colors.white70,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  Widget _filtros() {
    return Card(
      elevation: 0,
      color: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
      ),
      child: Padding(
        padding: const EdgeInsets.all(17),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Buscar cita',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 15),
            DropdownButtonFormField<String>(
              initialValue: especialidad,
              decoration: const InputDecoration(
                labelText: 'Especialidad',
                prefixIcon: Icon(
                  Icons.medical_services_outlined,
                ),
                border: OutlineInputBorder(),
              ),
              items: CitasLocalService.especialidades
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(item),
                    ),
                  )
                  .toList(),
              onChanged: (valor) {
                if (valor == null) return;

                setState(() {
                  especialidad = valor;
                  fecha = '';
                });

                _buscar();
              },
            ),
            const SizedBox(height: 13),
            DropdownButtonFormField<String>(
              initialValue: sede,
              decoration: const InputDecoration(
                labelText: 'Sede',
                prefixIcon: Icon(
                  Icons.location_on_outlined,
                ),
                border: OutlineInputBorder(),
              ),
              items: CitasLocalService.sedes
                  .map(
                    (item) => DropdownMenuItem(
                      value: item,
                      child: Text(
                        item,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  )
                  .toList(),
              onChanged: (valor) {
                if (valor == null) return;

                setState(() {
                  sede = valor;
                });

                _buscar();
              },
            ),
            const SizedBox(height: 13),
            InkWell(
              onTap: _seleccionarFecha,
              borderRadius: BorderRadius.circular(12),
              child: InputDecorator(
                decoration: const InputDecoration(
                  labelText: 'Fecha',
                  prefixIcon: Icon(
                    Icons.calendar_today_outlined,
                  ),
                  border: OutlineInputBorder(),
                ),
                child: Text(
                  fecha.isEmpty ? 'Todas las fechas' : fecha,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: _buscar,
                    icon: const Icon(Icons.search),
                    label: const Text('Buscar cita'),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: _buscarCercanas,
                    style: FilledButton.styleFrom(
                      backgroundColor: verde,
                    ),
                    icon: const Icon(
                      Icons.near_me_outlined,
                    ),
                    label: const Text('Más cercana'),
                  ),
                ),
              ],
            ),
            if (mostrandoCercanas) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(11),
                decoration: BoxDecoration(
                  color: verdeClaro,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Row(
                  children: [
                    Icon(
                      Icons.info_outline,
                      color: verde,
                    ),
                    SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Mostrando las primeras opciones '
                        'disponibles para esta especialidad.',
                        style: TextStyle(
                          color: verde,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _tarjetaCita(Map<String, String> cita) {
    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      padding: const EdgeInsets.all(17),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 45,
                height: 45,
                decoration: BoxDecoration(
                  color: verdeClaro,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: const Icon(
                  Icons.event_available_rounded,
                  color: verde,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  cita['especialidad']!,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 15),
          _fila(
            Icons.person_outline,
            'Profesional',
            cita['medico']!,
          ),
          _fila(
            Icons.calendar_today_outlined,
            'Fecha',
            cita['fecha']!,
          ),
          _fila(
            Icons.access_time_outlined,
            'Hora',
            cita['hora']!,
          ),
          _fila(
            Icons.location_on_outlined,
            'Sede',
            cita['sede']!,
          ),
          const SizedBox(height: 10),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: () => _seleccionarCita(cita),
              style: FilledButton.styleFrom(
                backgroundColor: verde,
                padding: const EdgeInsets.symmetric(
                  vertical: 13,
                ),
              ),
              child: Text(
                widget.citaReagendarId == null
                    ? 'Seleccionar cita'
                    : 'Seleccionar nueva cita',
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _fila(
    IconData icon,
    String titulo,
    String valor,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Row(
        children: [
          Icon(
            icon,
            size: 19,
            color: verde,
          ),
          const SizedBox(width: 9),
          Text(
            '$titulo: ',
            style: const TextStyle(
              color: Colors.grey,
              fontSize: 13,
            ),
          ),
          Expanded(
            child: Text(
              valor,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sinResultados() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(30),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Column(
        children: [
          Icon(
            Icons.event_busy_outlined,
            size: 55,
            color: Colors.grey,
          ),
          SizedBox(height: 12),
          Text(
            'No encontramos citas disponibles',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
            ),
          ),
          SizedBox(height: 6),
          Text(
            'Prueba otra fecha, sede o especialidad.',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.grey,
            ),
          ),
        ],
      ),
    );
  }
}
