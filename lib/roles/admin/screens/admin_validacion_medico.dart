import 'package:flutter/material.dart';

class AdminValidacionMedicos extends StatefulWidget {
  const AdminValidacionMedicos({super.key});

  @override
  State<AdminValidacionMedicos> createState() => _AdminValidacionMedicosState();
}

class _AdminValidacionMedicosState extends State<AdminValidacionMedicos> {
  final List<Map<String, String>> _medicos = [
    {
      'nombre': 'Dr. Juan Pérez',
      'rethus': 'RETHUS 12345',
      'especialidad': 'Medicina General',
      'confianza': '92%',
    },
    {
      'nombre': 'Dra. María González',
      'rethus': 'RETHUS 67890',
      'especialidad': 'Enfermería',
      'confianza': '96%',
    },
  ];

  void _aprobarMedico(int index) {
    final medico = _medicos[index];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Médico aprobado'),
          content: Text(
            '${medico['nombre']} ha sido aprobado correctamente.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('ACEPTAR'),
            ),
          ],
        );
      },
    );

    setState(() {
      _medicos.removeAt(index);
    });
  }

  void _rechazarMedico(int index) {
    final medico = _medicos[index];

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Rechazar registro'),
          content: Text(
            '¿Deseas rechazar la solicitud de ${medico['nombre']}?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCELAR'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);

                setState(() {
                  _medicos.removeAt(index);
                });

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text(
                      'Solicitud rechazada correctamente.',
                    ),
                    backgroundColor: Colors.red,
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('RECHAZAR'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F7),
      appBar: AppBar(
        title: const Text(
          'Validar Médicos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: const Color(0xFF0E7C57),
        foregroundColor: Colors.white,
        elevation: 0,
      ),
      body: _medicos.isEmpty
          ? _buildSinSolicitudes()
          : ListView.builder(
              padding: const EdgeInsets.all(20),
              itemCount: _medicos.length,
              itemBuilder: (context, index) {
                final medico = _medicos[index];

                return _buildMedicoCard(
                  medico: medico,
                  index: index,
                );
              },
            ),
    );
  }

  Widget _buildMedicoCard({
    required Map<String, String> medico,
    required int index,
  }) {
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
                    Icons.medical_services_rounded,
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
                        medico['nombre'] ?? '',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF26332E),
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        medico['especialidad'] ?? '',
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
            _InfoRow(
              icon: Icons.badge_outlined,
              label: 'Registro profesional',
              value: medico['rethus'] ?? '',
            ),
            const SizedBox(height: 10),
            _InfoRow(
              icon: Icons.verified_outlined,
              label: 'Confianza OCR',
              value: medico['confianza'] ?? '',
            ),
            const SizedBox(height: 20),
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
                      'Verifique la información antes de aprobar el registro.',
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
                      _rechazarMedico(index);
                    },
                    icon: const Icon(Icons.close_rounded),
                    label: const Text('Rechazar'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.red,
                      side: const BorderSide(
                        color: Colors.red,
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
                      _aprobarMedico(index);
                    },
                    icon: const Icon(
                      Icons.check_circle_outline_rounded,
                    ),
                    label: const Text('Aprobar'),
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
              decoration: BoxDecoration(
                color: const Color(0xFFE8F6F0),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.verified_rounded,
                size: 48,
                color: Color(0xFF0E7C57),
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No hay solicitudes pendientes',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Color(0xFF26332E),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Las nuevas solicitudes de médicos aparecerán aquí.',
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

class _InfoRow extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;

  const _InfoRow({
    required this.icon,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(
          icon,
          size: 21,
          color: const Color(0xFF0E7C57),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 13,
              color: Color(0xFF71807A),
            ),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF26332E),
          ),
        ),
      ],
    );
  }
}
