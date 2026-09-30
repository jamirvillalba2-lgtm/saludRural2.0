import 'package:flutter/material.dart';

import '../widgets/admin_acceso_rapido.dart';
import '../widgets/admin_estado_sistema.dart';
import '../widgets/admin_medico_card.dart';
import '../widgets/admin_paciente_card.dart';
import '../widgets/admin_stat_card.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  State<AdminDashboard> createState() => _AdminDashboardState();
}

class _AdminDashboardState extends State<AdminDashboard> {
  int pacientes = 24;
  int medicos = 8;
  int pendientes = 3;
  int validados = 21;

  void _mensaje(String texto) {
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(texto),
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _actualizar() async {
    await Future.delayed(const Duration(milliseconds: 500));

    if (!mounted) {
      return;
    }

    setState(() {});
    _mensaje('Información actualizada correctamente.');
  }

  void _validarMedico() {
    if (pendientes > 0) {
      setState(() {
        pendientes--;
        medicos++;
      });
    }

    _mensaje('Médico validado correctamente.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F7),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0E7C57),
        foregroundColor: Colors.white,
        elevation: 0,
        title: const Text(
          'Panel administrativo',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            tooltip: 'Actualizar',
            onPressed: _actualizar,
            icon: const Icon(Icons.refresh_rounded),
          ),
        ],
      ),
      drawer: _crearDrawer(),
      body: RefreshIndicator(
        onRefresh: _actualizar,
        child: ListView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          children: [
            _crearBienvenida(),
            const SizedBox(height: 22),
            _titulo(
              'Resumen general',
              'Estado actual de la plataforma',
            ),
            const SizedBox(height: 12),
            _estadisticas(),
            const SizedBox(height: 24),
            _titulo(
              'Accesos rápidos',
              'Gestión administrativa',
            ),
            const SizedBox(height: 12),
            _accesosRapidos(),
            const SizedBox(height: 24),
            _titulo(
              'Actividad reciente',
              'Registros del sistema',
            ),
            const SizedBox(height: 12),
            AdminPacienteCard(
              nombre: 'JAMIR ENRIQUE VILLALBA DE ORO',
              cedula: '1049483358',
              confianzaOcr: 'OCR 100%',
              onTap: () {
                _mensaje('Información del paciente.');
              },
            ),
            const SizedBox(height: 12),
            AdminMedicoCard(
              nombre: 'Médico pendiente de validación',
              especialidad: 'Profesional de salud',
              registro: 'Registro RETHUS pendiente de revisión',
              estado: 'Pendiente',
              onRevisar: () {
                _mensaje('Revisando información del médico.');
              },
              onValidar: _validarMedico,
            ),
            const SizedBox(height: 24),
            _titulo(
              'Estado del sistema',
              'Servicios principales',
            ),
            const SizedBox(height: 12),
            const AdminEstadoSistema(),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _crearBienvenida() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0E7C57),
            Color(0xFF159A6B),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
      ),
      child: const Row(
        children: [
          CircleAvatar(
            radius: 29,
            backgroundColor: Colors.white24,
            child: Icon(
              Icons.admin_panel_settings_rounded,
              color: Colors.white,
              size: 32,
            ),
          ),
          SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Bienvenido, Administrador',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Gestiona pacientes, médicos y validaciones.',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _titulo(String titulo, String subtitulo) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          titulo,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          subtitulo,
          style: TextStyle(
            color: Colors.grey.shade600,
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _estadisticas() {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.28,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        AdminStatCard(
          titulo: 'Pacientes registrados',
          valor: '$pacientes',
          icono: Icons.people_alt_rounded,
          color: const Color(0xFF1976D2),
        ),
        AdminStatCard(
          titulo: 'Médicos registrados',
          valor: '$medicos',
          icono: Icons.medical_services_rounded,
          color: const Color(0xFF2E7D32),
        ),
        AdminStatCard(
          titulo: 'Pendientes',
          valor: '$pendientes',
          icono: Icons.pending_actions_rounded,
          color: const Color(0xFFF57C00),
        ),
        AdminStatCard(
          titulo: 'Pacientes validados',
          valor: '$validados',
          icono: Icons.verified_user_rounded,
          color: const Color(0xFF7B1FA2),
        ),
      ],
    );
  }

  Widget _accesosRapidos() {
    return GridView.count(
      crossAxisCount: 4,
      crossAxisSpacing: 8,
      mainAxisSpacing: 8,
      childAspectRatio: 0.82,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: [
        AdminAccesoRapido(
          icono: Icons.people_alt_rounded,
          titulo: 'Pacientes',
          color: const Color(0xFF1976D2),
          onTap: () {
            _mensaje('Módulo de pacientes.');
          },
        ),
        AdminAccesoRapido(
          icono: Icons.medical_services_rounded,
          titulo: 'Médicos',
          color: const Color(0xFF2E7D32),
          onTap: () {
            _mensaje('Módulo de médicos.');
          },
        ),
        AdminAccesoRapido(
          icono: Icons.fact_check_rounded,
          titulo: 'Validaciones',
          color: const Color(0xFFF57C00),
          onTap: () {
            _mensaje('Módulo de validaciones.');
          },
        ),
        AdminAccesoRapido(
          icono: Icons.bar_chart_rounded,
          titulo: 'Reportes',
          color: const Color(0xFF7B1FA2),
          onTap: () {
            _mensaje('Módulo de reportes.');
          },
        ),
      ],
    );
  }

  Drawer _crearDrawer() {
    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(22),
              color: const Color(0xFF0E7C57),
              child: const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: Colors.white,
                    child: Icon(
                      Icons.admin_panel_settings_rounded,
                      color: Color(0xFF0E7C57),
                      size: 34,
                    ),
                  ),
                  SizedBox(height: 14),
                  Text(
                    'Administrador',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 3),
                  Text(
                    'Salud Rural',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8),
            _itemDrawer(
              Icons.dashboard_rounded,
              'Panel principal',
              () {
                Navigator.pop(context);
              },
            ),
            _itemDrawer(
              Icons.people_alt_rounded,
              'Pacientes',
              () {
                Navigator.pop(context);
                _mensaje('Módulo de pacientes.');
              },
            ),
            _itemDrawer(
              Icons.medical_services_rounded,
              'Médicos',
              () {
                Navigator.pop(context);
                _mensaje('Módulo de médicos.');
              },
            ),
            _itemDrawer(
              Icons.fact_check_rounded,
              'Validaciones',
              () {
                Navigator.pop(context);
                _mensaje('Módulo de validaciones.');
              },
            ),
            _itemDrawer(
              Icons.bar_chart_rounded,
              'Reportes',
              () {
                Navigator.pop(context);
                _mensaje('Módulo de reportes.');
              },
            ),
            const Spacer(),
            const Divider(),
            _itemDrawer(
              Icons.logout_rounded,
              'Cerrar sesión',
              () {
                Navigator.pop(context);
                _mensaje('Sesión cerrada.');
              },
              color: const Color(0xFFC62828),
            ),
          ],
        ),
      ),
    );
  }

  Widget _itemDrawer(
    IconData icono,
    String titulo,
    VoidCallback onTap, {
    Color color = const Color(0xFF37474F),
  }) {
    return ListTile(
      leading: Icon(
        icono,
        color: color,
      ),
      title: Text(
        titulo,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
      onTap: onTap,
    );
  }
}
