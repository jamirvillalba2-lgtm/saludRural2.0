import 'package:flutter/material.dart';

/// Widget que muestra el estado general de los servicios
/// utilizados por el panel administrativo.
class AdminEstadoSistema extends StatelessWidget {
  final bool servidorActivo;
  final bool baseDatosActiva;
  final bool ocrActivo;

  const AdminEstadoSistema({
    super.key,
    this.servidorActivo = true,
    this.baseDatosActiva = true,
    this.ocrActivo = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFFE4EAE7),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.monitor_heart_rounded,
                  color: Color(0xFF2E7D32),
                  size: 23,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Estado del sistema',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 3),
                    Text(
                      'Servicios principales',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F5E9),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'Operativo',
                  style: TextStyle(
                    color: Color(0xFF2E7D32),
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 18),
          _ServicioEstado(
            titulo: 'Servidor',
            activo: servidorActivo,
            icono: Icons.dns_rounded,
          ),
          const Divider(height: 20),
          _ServicioEstado(
            titulo: 'Base de datos',
            activo: baseDatosActiva,
            icono: Icons.storage_rounded,
          ),
          const Divider(height: 20),
          _ServicioEstado(
            titulo: 'Reconocimiento OCR',
            activo: ocrActivo,
            icono: Icons.document_scanner_rounded,
          ),
        ],
      ),
    );
  }
}

class _ServicioEstado extends StatelessWidget {
  final String titulo;
  final bool activo;
  final IconData icono;

  const _ServicioEstado({
    required this.titulo,
    required this.activo,
    required this.icono,
  });

  @override
  Widget build(BuildContext context) {
    final color = activo ? const Color(0xFF2E7D32) : const Color(0xFFC62828);

    return Row(
      children: [
        Icon(
          icono,
          color: Colors.grey.shade600,
          size: 20,
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            titulo,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        Icon(
          activo ? Icons.check_circle_rounded : Icons.cancel_rounded,
          color: color,
          size: 20,
        ),
        const SizedBox(width: 6),
        Text(
          activo ? 'Activo' : 'Inactivo',
          style: TextStyle(
            color: color,
            fontSize: 12,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}
