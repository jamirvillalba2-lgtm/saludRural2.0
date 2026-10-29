import 'package:flutter/material.dart';

import '../../../controllers/cita_controller.dart';
import '../../../services/api_client.dart';
import 'login_paciente.dart';
import 'paciente_mis_citas.dart';
import 'paciente_mis_citas_disponibles.dart';

/// ===============================================================
/// DASHBOARD DEL PACIENTE
/// Proyecto: Salud Rural
///
/// Funciones:
/// - Agendar citas
/// - Consultar y gestionar citas
/// - Ver notificaciones
/// - Consultar perfil
/// - Cerrar sesión
/// ===============================================================
class PacienteDashboard extends StatefulWidget {
  final String nombre;
  final String cc;
  final String direccion;
  final String vereda;
  final String municipio;
  final String telefono;
  final String correo;
  final String eps;
  final String rh;
  final String fechaNacimiento;
  final String sexo;

  // Se conserva para mantener compatibilidad con el código
  // que actualmente crea este Dashboard.
  final VoidCallback onCerrarSesion;

  const PacienteDashboard({
    super.key,
    required this.nombre,
    required this.cc,
    required this.direccion,
    required this.vereda,
    required this.municipio,
    required this.telefono,
    required this.correo,
    required this.eps,
    required this.rh,
    required this.fechaNacimiento,
    required this.sexo,
    required this.onCerrarSesion,
  });

  @override
  State<PacienteDashboard> createState() => _PacienteDashboardState();
}

class _PacienteDashboardState extends State<PacienteDashboard> {
  // ===============================================================
  // COLORES
  // ===============================================================

  static const Color verdePrincipal = Color(0xFF0E7C57);
  static const Color verdeOscuro = Color(0xFF075B40);
  static const Color verdeClaro = Color(0xFFE8F5EF);
  static const Color fondo = Color(0xFFF5F8F7);
  static const Color textoPrincipal = Color(0xFF1F2937);
  static const Color textoSecundario = Color(0xFF6B7280);
  static const Color rojoCerrarSesion = Color(0xFFB42318);

  // ===============================================================
  // ESTADO
  // ===============================================================

  List<Map<String, dynamic>> _misCitas = [];
  final List<Map<String, dynamic>> _notificaciones = [];

  bool _cargando = true;
  String? _errorCarga;

  // ===============================================================
  // DATOS DERIVADOS
  // ===============================================================

  String get nombreCorto {
    final nombre = widget.nombre.trim();

    if (nombre.isEmpty) {
      return 'Paciente';
    }

    final partes = nombre.split(RegExp(r'\s+'));

    return partes.first;
  }

  // ===============================================================
  // CICLO DE VIDA
  // ===============================================================

  @override
  void initState() {
    super.initState();
    _cargarDatos();
  }

  // ===============================================================
  // CARGAR DATOS
  // ===============================================================

  Future<void> _cargarDatos() async {
    try {
      final citas = await citaController.listar(
        documentoPaciente: widget.cc,
      );

      if (!mounted) return;

      setState(() {
        _misCitas = citas;
        _errorCarga = null;
        _cargando = false;
      });
    } on ApiException catch (error) {
      if (!mounted) return;

      setState(() {
        _errorCarga = error.message;
        _cargando = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    }
  } // ===============================================================
  // BUILD PRINCIPAL
  // ===============================================================

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: fondo,
      appBar: _buildAppBar(),
      body: RefreshIndicator(
        color: verdePrincipal,
        onRefresh: _cargarDatos,
        child: SafeArea(
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(16, 18, 16, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildWelcome(),
                if (_errorCarga != null) ...[
                  const SizedBox(height: 12),
                  _buildLoadError(),
                ],
                const SizedBox(height: 20),
                _buildAgendarPrincipal(),
                const SizedBox(height: 22),
                _buildSectionTitle(
                  'Mi atención',
                  'Consulta y administra tus citas médicas.',
                ),
                const SizedBox(height: 12),
                _buildProximaCita(),
                const SizedBox(height: 22),
                _buildSectionTitle(
                  'Acciones rápidas',
                  'Accede a las funciones principales.',
                ),
                const SizedBox(height: 12),
                _buildQuickActions(),
                const SizedBox(height: 22),
                _buildNotificacionesResumen(),
                const SizedBox(height: 22),
                _buildAtencionRural(),
                const SizedBox(height: 28),
                _buildLogoutButton(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadError() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF3E0),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          const Icon(Icons.cloud_off_outlined, color: Color(0xFF9A6700)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'No se pudieron cargar tus citas: $_errorCarga',
              style: const TextStyle(color: Color(0xFF6D4C00)),
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // APP BAR
  // ===============================================================

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      elevation: 0,
      backgroundColor: verdePrincipal,
      foregroundColor: Colors.white,
      titleSpacing: 18,
      title: const Row(
        children: [
          Icon(
            Icons.health_and_safety_rounded,
            size: 28,
          ),
          SizedBox(width: 10),
          Text(
            'Salud Rural',
            style: TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
            ),
          ),
        ],
      ),
      actions: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            IconButton(
              tooltip: 'Notificaciones',
              icon: const Icon(
                Icons.notifications_none_rounded,
              ),
              onPressed: _mostrarNotificaciones,
            ),
            if (_notificaciones.isNotEmpty)
              Positioned(
                right: 7,
                top: 7,
                child: Container(
                  width: 18,
                  height: 18,
                  decoration: BoxDecoration(
                    color: const Color(0xFFD92D20),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: verdePrincipal,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      _notificaciones.length > 9
                          ? '9+'
                          : '${_notificaciones.length}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 8,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        IconButton(
          tooltip: 'Mi perfil',
          icon: const Icon(
            Icons.account_circle_outlined,
          ),
          onPressed: _mostrarPerfil,
        ),
        IconButton(
          tooltip: 'Cerrar sesión',
          icon: const Icon(
            Icons.logout_rounded,
          ),
          onPressed: _confirmarCerrarSesion,
        ),
        const SizedBox(width: 6),
      ],
    );
  }

  // ===============================================================
  // SALUDO
  // ===============================================================

  Widget _buildWelcome() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Hola, $nombreCorto 👋',
          style: const TextStyle(
            fontSize: 27,
            fontWeight: FontWeight.w800,
            color: textoPrincipal,
          ),
        ),
        const SizedBox(height: 5),
        const Text(
          '¿Qué atención necesitas hoy?',
          style: TextStyle(
            fontSize: 15,
            color: textoSecundario,
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // AGENDAR CITA
  // ===============================================================

  Widget _buildAgendarPrincipal() {
    return Material(
      color: Colors.transparent,
      borderRadius: BorderRadius.circular(24),
      child: InkWell(
        onTap: _agendarCita,
        borderRadius: BorderRadius.circular(24),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(22),
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                verdePrincipal,
                verdeOscuro,
              ],
            ),
            borderRadius: BorderRadius.circular(24),
            boxShadow: [
              BoxShadow(
                color: verdePrincipal.withValues(alpha: 0.22),
                blurRadius: 18,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: const Row(
            children: [
              SizedBox(
                width: 58,
                height: 58,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Color(0x2BFFFFFF),
                    borderRadius: BorderRadius.all(
                      Radius.circular(18),
                    ),
                  ),
                  child: Icon(
                    Icons.calendar_month_rounded,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
              SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Agendar cita',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    SizedBox(height: 5),
                    Text(
                      'Busca una atención disponible por especialidad, fecha y sede.',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 13,
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              Icon(
                Icons.arrow_forward_ios_rounded,
                color: Colors.white,
                size: 18,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // TÍTULO DE SECCIÓN
  // ===============================================================

  Widget _buildSectionTitle(
    String title,
    String subtitle,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 19,
            fontWeight: FontWeight.w800,
            color: textoPrincipal,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          subtitle,
          style: const TextStyle(
            fontSize: 13,
            color: textoSecundario,
          ),
        ),
      ],
    );
  }

  // ===============================================================
  // PRÓXIMA CITA
  // ===============================================================

  Widget _buildProximaCita() {
    if (_cargando) {
      return _buildLoadingCard();
    }

    final citasActivas = _misCitas.where((cita) {
      final estado = _valor(
        cita['estado'],
        '',
      ).toUpperCase();

      return estado != 'CANCELADA';
    }).toList();

    if (citasActivas.isEmpty) {
      return _buildEmptyAppointmentCard();
    }

    final cita = citasActivas.first;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.025),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: verdeClaro,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Text(
                  'PRÓXIMA CITA',
                  style: TextStyle(
                    color: verdePrincipal,
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.6,
                  ),
                ),
              ),
              const Spacer(),
              const Icon(
                Icons.event_available_rounded,
                color: verdePrincipal,
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            _valor(
              cita['especialidad'],
              'Atención médica',
            ),
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: textoPrincipal,
            ),
          ),
          const SizedBox(height: 8),
          _buildAppointmentInfo(
            Icons.person_outline_rounded,
            _valor(
              cita['medico'] ?? cita['profesional'],
              'Profesional no registrado',
            ),
          ),
          const SizedBox(height: 7),
          _buildAppointmentInfo(
            Icons.calendar_today_outlined,
            _valor(
              cita['fecha'],
              'Fecha no registrada',
            ),
          ),
          const SizedBox(height: 7),
          _buildAppointmentInfo(
            Icons.access_time_rounded,
            _valor(
              cita['hora'],
              'Hora no registrada',
            ),
          ),
          const SizedBox(height: 7),
          _buildAppointmentInfo(
            Icons.location_on_outlined,
            _valor(
              cita['sede'],
              'Sede no registrada',
            ),
          ),
          const SizedBox(height: 16),
          SizedBox(
            width: double.infinity,
            child: OutlinedButton(
              onPressed: _verMisCitas,
              style: OutlinedButton.styleFrom(
                foregroundColor: verdePrincipal,
                side: const BorderSide(
                  color: verdePrincipal,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Ver mis citas',
                style: TextStyle(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentInfo(
    IconData icon,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: textoSecundario,
        ),
        const SizedBox(width: 9),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: textoSecundario,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      width: double.infinity,
      height: 180,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          color: verdePrincipal,
        ),
      ),
    );
  }

  Widget _buildEmptyAppointmentCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFFE5E7EB),
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 58,
            height: 58,
            decoration: BoxDecoration(
              color: verdeClaro,
              borderRadius: BorderRadius.circular(18),
            ),
            child: const Icon(
              Icons.event_note_outlined,
              color: verdePrincipal,
              size: 29,
            ),
          ),
          const SizedBox(height: 13),
          const Text(
            'No tienes citas próximas',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w800,
              color: textoPrincipal,
            ),
          ),
          const SizedBox(height: 5),
          const Text(
            'Puedes buscar una atención disponible en cualquier sede.',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 13,
              color: textoSecundario,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
          FilledButton(
            onPressed: _agendarCita,
            style: FilledButton.styleFrom(
              backgroundColor: verdePrincipal,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(13),
              ),
            ),
            child: const Text('Agendar cita'),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // ACCIONES RÁPIDAS
  // ===============================================================

  Widget _buildQuickActions() {
    return Row(
      children: [
        Expanded(
          child: _buildActionCard(
            icon: Icons.event_note_outlined,
            title: 'Mis citas',
            subtitle: 'Consultar y gestionar',
            onTap: _verMisCitas,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildActionCard(
            icon: Icons.person_outline_rounded,
            title: 'Mi perfil',
            subtitle: 'Mis datos',
            onTap: _mostrarPerfil,
          ),
        ),
      ],
    );
  }

  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(18),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(18),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  color: verdeClaro,
                  borderRadius: BorderRadius.circular(13),
                ),
                child: Icon(
                  icon,
                  color: verdePrincipal,
                  size: 23,
                ),
              ),
              const SizedBox(height: 13),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                  color: textoPrincipal,
                ),
              ),
              const SizedBox(height: 3),
              Text(
                subtitle,
                style: const TextStyle(
                  fontSize: 12,
                  color: textoSecundario,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // NOTIFICACIONES - RESUMEN
  // ===============================================================

  Widget _buildNotificacionesResumen() {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: _mostrarNotificaciones,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(17),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE5E7EB),
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: verdeClaro,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(
                  Icons.notifications_active_outlined,
                  color: verdePrincipal,
                  size: 25,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Notificaciones',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w800,
                        color: textoPrincipal,
                      ),
                    ),
                    const SizedBox(height: 3),
                    Text(
                      _notificaciones.isEmpty
                          ? 'No tienes notificaciones nuevas.'
                          : 'Tienes ${_notificaciones.length} notificación(es).',
                      style: const TextStyle(
                        fontSize: 12,
                        color: textoSecundario,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: textoSecundario,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===============================================================
  // ATENCIÓN RURAL
  // ===============================================================

  Widget _buildAtencionRural() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: verdeClaro,
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.location_on_rounded,
            color: verdePrincipal,
            size: 28,
          ),
          SizedBox(width: 13),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Atención en zonas rurales',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    color: textoPrincipal,
                  ),
                ),
                SizedBox(height: 5),
                Text(
                  'Consulta disponibilidad de citas en las diferentes sedes y puestos de salud.',
                  style: TextStyle(
                    fontSize: 13,
                    color: textoSecundario,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // CERRAR SESIÓN
  // ===============================================================

  Widget _buildLogoutButton() {
    return SizedBox(
      width: double.infinity,
      height: 54,
      child: OutlinedButton.icon(
        onPressed: _confirmarCerrarSesion,
        icon: const Icon(
          Icons.logout_rounded,
        ),
        label: const Text(
          'Cerrar sesión',
          style: TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: rojoCerrarSesion,
          side: const BorderSide(
            color: Color(0xFFF0B8B3),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
      ),
    );
  }

  void _confirmarCerrarSesion() {
    showDialog<void>(
      context: context,
      builder: (dialogContext) {
        return AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Row(
            children: [
              Icon(
                Icons.logout_rounded,
                color: rojoCerrarSesion,
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text('Cerrar sesión'),
              ),
            ],
          ),
          content: const Text(
            '¿Deseas cerrar tu sesión actual?',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: const Text('Cancelar'),
            ),
            FilledButton(
              onPressed: () {
                Navigator.pop(dialogContext);
                _cerrarSesionReal();
              },
              style: FilledButton.styleFrom(
                backgroundColor: verdePrincipal,
              ),
              child: const Text('Cerrar sesión'),
            ),
          ],
        );
      },
    );
  }

  /// Cierra completamente la navegación del paciente y vuelve al login.
  ///
  /// Se utiliza pushAndRemoveUntil para evitar que el usuario pueda
  /// regresar al Dashboard con el botón "Atrás".
  Future<void> _cerrarSesionReal() async {
    if (!mounted) return;

    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute(
        builder: (_) => const LoginPacienteScreen(),
      ),
      (route) => false,
    );
  }

  // ===============================================================
  // NAVEGAR A AGENDAR CITA
  // ===============================================================

  Future<void> _agendarCita() async {
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
      await _cargarDatos();

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
            'Cita agendada correctamente.',
          ),
          backgroundColor: verdePrincipal,
        ),
      );
    }
  }

  // ===============================================================
  // NAVEGAR A MIS CITAS
  // ===============================================================

  Future<void> _verMisCitas() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PacienteMisCitas(
          cc: widget.cc,
          nombre: widget.nombre,
        ),
      ),
    );

    if (!mounted) return;

    await _cargarDatos();
  }

  // ===============================================================
  // PERFIL
  // ===============================================================

  void _mostrarPerfil() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.82,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            top: false,
            child: SingleChildScrollView(
              padding: const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                30,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSheetHandle(),
                  const SizedBox(height: 22),
                  _buildProfileHeader(),
                  const SizedBox(height: 20),
                  _buildProfileItem(
                    Icons.person_rounded,
                    'Nombre completo',
                    widget.nombre,
                  ),
                  _buildProfileItem(
                    Icons.badge_outlined,
                    'Documento de identidad',
                    widget.cc,
                  ),
                  _buildProfileItem(
                    Icons.cake_outlined,
                    'Fecha de nacimiento',
                    _mostrarValor(widget.fechaNacimiento),
                  ),
                  _buildProfileItem(
                    Icons.wc_outlined,
                    'Sexo',
                    _mostrarValor(widget.sexo),
                  ),
                  _buildProfileItem(
                    Icons.bloodtype_outlined,
                    'Grupo sanguíneo',
                    _mostrarValor(widget.rh),
                  ),
                  _buildProfileItem(
                    Icons.phone_outlined,
                    'Teléfono',
                    _mostrarValor(widget.telefono),
                  ),
                  _buildProfileItem(
                    Icons.email_outlined,
                    'Correo electrónico',
                    _mostrarValor(widget.correo),
                  ),
                  _buildProfileItem(
                    Icons.home_outlined,
                    'Dirección',
                    _mostrarValor(widget.direccion),
                  ),
                  _buildProfileItem(
                    Icons.landscape_outlined,
                    'Vereda',
                    _mostrarValor(widget.vereda),
                  ),
                  _buildProfileItem(
                    Icons.location_city_outlined,
                    'Municipio',
                    _mostrarValor(widget.municipio),
                  ),
                  _buildProfileItem(
                    Icons.local_hospital_outlined,
                    'EPS / SISBÉN',
                    _mostrarValor(widget.eps),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSheetHandle() {
    return Center(
      child: Container(
        width: 42,
        height: 4,
        decoration: BoxDecoration(
          color: const Color(0xFFD1D5DB),
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: verdeClaro,
            borderRadius: BorderRadius.circular(15),
          ),
          child: const Icon(
            Icons.person_outline_rounded,
            color: verdePrincipal,
            size: 27,
          ),
        ),
        const SizedBox(width: 13),
        const Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mi perfil',
                style: TextStyle(
                  fontSize: 21,
                  fontWeight: FontWeight.w800,
                  color: textoPrincipal,
                ),
              ),
              SizedBox(height: 3),
              Text(
                'Información personal registrada',
                style: TextStyle(
                  fontSize: 12,
                  color: textoSecundario,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildProfileItem(
    IconData icon,
    String label,
    String value,
  ) {
    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            color: verdePrincipal,
            size: 21,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    fontSize: 11,
                    color: textoSecundario,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 14,
                    color: textoPrincipal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // NOTIFICACIONES
  // ===============================================================

  void _mostrarNotificaciones() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetContext) {
        return Container(
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.75,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(28),
            ),
          ),
          child: SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                20,
                12,
                20,
                30,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSheetHandle(),
                  const SizedBox(height: 22),
                  Row(
                    children: [
                      Container(
                        width: 46,
                        height: 46,
                        decoration: BoxDecoration(
                          color: verdeClaro,
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: const Icon(
                          Icons.notifications_active_outlined,
                          color: verdePrincipal,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Text(
                        'Notificaciones',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: textoPrincipal,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 18),
                  Flexible(
                    child: _notificaciones.isEmpty
                        ? const Center(
                            child: Padding(
                              padding: EdgeInsets.all(30),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.notifications_none_rounded,
                                    size: 48,
                                    color: textoSecundario,
                                  ),
                                  SizedBox(height: 12),
                                  Text(
                                    'No tienes notificaciones',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: textoPrincipal,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Text(
                                    'Aquí aparecerán avisos relacionados con tus citas.',
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: textoSecundario,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : ListView.separated(
                            shrinkWrap: true,
                            itemCount: _notificaciones.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(height: 8),
                            itemBuilder: (context, index) {
                              final notificacion = _notificaciones[index];

                              return _buildNotificationItem(
                                notificacion,
                              );
                            },
                          ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationItem(
    Map<String, dynamic> notificacion,
  ) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: fondo,
        borderRadius: BorderRadius.circular(15),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(
            Icons.info_outline_rounded,
            color: verdePrincipal,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _valor(
                    notificacion['titulo'],
                    'Notificación',
                  ),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w800,
                    color: textoPrincipal,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  _valor(
                    notificacion['mensaje'],
                    '',
                  ),
                  style: const TextStyle(
                    fontSize: 12,
                    color: textoSecundario,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===============================================================
  // UTILIDADES
  // ===============================================================

  String _valor(
    dynamic valor,
    String defecto,
  ) {
    if (valor == null) {
      return defecto;
    }

    final texto = valor.toString().trim();

    return texto.isEmpty ? defecto : texto;
  }

  String _mostrarValor(String valor) {
    final limpio = valor.trim();

    return limpio.isEmpty ? 'No registrado' : limpio;
  }
}
