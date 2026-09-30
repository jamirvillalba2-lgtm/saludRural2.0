import 'package:flutter/material.dart';

class AdminValidacionPaciente extends StatefulWidget {
  const AdminValidacionPaciente({super.key});

  @override
  State<AdminValidacionPaciente> createState() =>
      _AdminValidacionPacienteState();
}

class _AdminValidacionPacienteState extends State<AdminValidacionPaciente> {
  final List<Map<String, String>> _pacientes = [
    {
      'nombre': 'María López',
      'documento': 'CC 1.234.567',
      'confianza': '88%',
      'estado': 'Naranja',
    },
    {
      'nombre': 'Carlos Rodríguez',
      'documento': 'CC 1.098.765',
      'confianza': '96%',
      'estado': 'Verde',
    },
  ];

  void _aprobarPaciente(int index) {
    final paciente = _pacientes[index];

    setState(() {
      _pacientes.removeAt(index);
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          '${paciente['nombre']} ha sido validado correctamente.',
        ),
        backgroundColor: const Color(0xFF0E7C57),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _editarPaciente(int index) {
    final paciente = _pacientes[index];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(
                Icons.edit_rounded,
                color: Color(0xFFF39C12),
              ),
              SizedBox(width: 10),
              Text('Revisar paciente'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Nombre',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                paciente['nombre'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Documento',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                paciente['documento'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                'Confianza OCR',
                style: TextStyle(
                  fontSize: 12,
                  color: Colors.grey.shade600,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                paciente['confianza'] ?? '',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 14),
              const Text(
                'La información debe revisarse antes de aprobar el registro.',
                style: TextStyle(
                  fontSize: 13,
                  color: Color(0xFF71807A),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CERRAR'),
            ),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _aprobarPaciente(index);
              },
              icon: const Icon(Icons.check_rounded),
              label: const Text('VALIDAR'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF0E7C57),
                foregroundColor: Colors.white,
              ),
            ),
          ],
        );
      },
    );
  }

  Color _colorSemaforo(String estado) {
    switch (estado.toLowerCase()) {
      case 'verde':
        return const Color(0xFF0E7C57);

      case 'naranja':
        return const Color(0xFFF39C12);

      case 'rojo':
        return const Color(0xFFE74C3C);

      default:
        return Colors.grey;
    }
  }

  IconData _iconoSemaforo(String estado) {
    switch (estado.toLowerCase()) {
      case 'verde':
        return Icons.check_circle_rounded;

      case 'naranja':
        return Icons.warning_rounded;

      case 'rojo':
        return Icons.error_rounded;

      default:
        return Icons.help_rounded;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F7),
      appBar: AppBar(
        title: const Text(
          'Validar Pacientes',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF0E7C57),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _pacientes.isEmpty
          ? _buildSinSolicitudes()
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _pacientes.length,
              itemBuilder: (context, index) {
                final paciente = _pacientes[index];

                return _buildPacienteCard(
                  paciente: paciente,
                  index: index,
                );
              },
            ),
    );
  }

  Widget _buildPacienteCard({
    required Map<String, String> paciente,
    required int index,
  }) {
    final estado = paciente['estado'] ?? '';
    final colorSemaforo = _colorSemaforo(estado);

    return Container(
      margin: const EdgeInsets.only(bottom: 18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 15,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Row(
              children: [
                Container(
                  width: 58,
                  height: 58,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE8F6F0),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: const Icon(
                    Icons.person_rounded,
                    color: Color(0xFF0E7C57),
                    size: 30,
                  ),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        paciente['nombre'] ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF26332E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        paciente['documento'] ?? '',
                        style: const TextStyle(
                          color: Color(0xFF71807A),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: colorSemaforo.withOpacity(0.10),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: colorSemaforo.withOpacity(0.25),
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    _iconoSemaforo(estado),
                    color: colorSemaforo,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Semáforo de validación',
                          style: TextStyle(
                            fontSize: 12,
                            color: colorSemaforo,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          estado,
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                            color: colorSemaforo,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 15),
            Row(
              children: [
                const Icon(
                  Icons.document_scanner_outlined,
                  size: 21,
                  color: Color(0xFF0E7C57),
                ),
                const SizedBox(width: 10),
                const Expanded(
                  child: Text(
                    'Confianza OCR',
                    style: TextStyle(
                      fontSize: 13,
                      color: Color(0xFF71807A),
                    ),
                  ),
                ),
                Text(
                  paciente['confianza'] ?? '',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Color(0xFF26332E),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFFFFF8E1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Row(
                children: [
                  Icon(
                    Icons.info_outline_rounded,
                    color: Color(0xFF9A7600),
                  ),
                  SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      'El resultado naranja requiere revisión antes de validar.',
                      style: TextStyle(
                        fontSize: 13,
                        color: Color(0xFF735B00),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 18),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () {
                      _editarPaciente(index);
                    },
                    icon: const Icon(
                      Icons.edit_rounded,
                    ),
                    label: const Text('Revisar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFF39C12),
                      side: const BorderSide(
                        color: Color(0xFFF39C12),
                      ),
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () {
                      _aprobarPaciente(index);
                    },
                    icon: const Icon(
                      Icons.check_circle_outline_rounded,
                    ),
                    label: const Text('Validar'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0E7C57),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(
                        vertical: 14,
                      ),
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSinSolicitudes() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 90,
              height: 90,
              decoration: const BoxDecoration(
                color: Color(0xFFE8F6F0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_user_rounded,
                size: 48,
                color: Color(0xFF0E7C57),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No hay pacientes pendientes',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF26332E),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Los nuevos registros de pacientes aparecerán aquí.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Color(0xFF71807A),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
