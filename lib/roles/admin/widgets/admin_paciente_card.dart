import 'package:flutter/material.dart';

/// Tarjeta que representa un paciente registrado
/// dentro del panel administrativo.
///
/// Posteriormente los datos podrán llegar desde
/// la base de datos o desde una API.
class AdminPacienteCard extends StatelessWidget {
  final String nombre;
  final String cedula;
  final String confianzaOcr;
  final VoidCallback? onTap;

  const AdminPacienteCard({
    super.key,
    this.nombre = 'JAMIR ENRIQUE VILLALBA DE ORO',
    this.cedula = '1049483358',
    this.confianzaOcr = 'OCR 100%',
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE4EAE7),
            ),
          ),
          child: Row(
            children: [
              // Icono identificador del paciente.
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.person_rounded,
                  color: Color(0xFF2E7D32),
                  size: 28,
                ),
              ),

              const SizedBox(width: 14),

              // Información principal del paciente.
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Paciente registrado',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      nombre,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 12,
                        color: Colors.black87,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      'CC: $cedula',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),

              // Porcentaje de confianza obtenido mediante OCR.
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 9,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  confianzaOcr,
                  style: const TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
