import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'roles/paciente/screens/paciente_registro_ocr.dart';
import 'roles/paciente/screens/login_paciente.dart';
import 'roles/medico/screens/medico_registro_rethus.dart';
import 'roles/admin/screens/admin_dashboard.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.white,
      systemNavigationBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(const SaludRuralApp());
}

class SaludRuralApp extends StatelessWidget {
  const SaludRuralApp({super.key});

  static const Color primaryColor = Color(0xFF0E7C57);
  static const Color backgroundColor = Color(0xFFF5F8F7);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Salud Rural',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: primaryColor,
          brightness: Brightness.light,
        ),
        scaffoldBackgroundColor: backgroundColor,
        fontFamily: 'Roboto',
      ),
      home: const AuthWelcomeScreen(),
    );
  }
}

// ============================================================
// PANTALLA INICIAL
// ============================================================

class AuthWelcomeScreen extends StatelessWidget {
  const AuthWelcomeScreen({super.key});

  static const Color primaryColor = Color(0xFF0E7C57);
  static const Color textColor = Color(0xFF26332E);
  static const Color secondaryTextColor = Color(0xFF71807A);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0xFFE8F6F0),
                Color(0xFFF8FBFA),
                Colors.white,
              ],
            ),
          ),
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  maxWidth: 500,
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const _Logo(),
                    const SizedBox(height: 28),
                    const Text(
                      'Salud Rural',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 34,
                        fontWeight: FontWeight.bold,
                        color: primaryColor,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Salud a un clic, estés donde estés',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 16,
                        color: secondaryTextColor,
                      ),
                    ),
                    const SizedBox(height: 40),
                    _WelcomeCard(
                      onLogin: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const LoginPacienteScreen(),
                          ),
                        );
                      },
                      onCreateAccount: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const RoleSelector(),
                          ),
                        );
                      },
                      onForgotPassword: () {
                        _showForgotPasswordDialog(context);
                      },
                    ),
                    const SizedBox(height: 24),
                    const Text(
                      'SALUD RURAL',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                        color: Color(0xFF8A9792),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _showForgotPasswordDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: const Text('Recuperar contraseña'),
          content: const Text(
            'La recuperación de contraseña estará disponible próximamente.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CERRAR'),
            ),
          ],
        );
      },
    );
  }
}

// ============================================================
// TARJETA DE BIENVENIDA
// ============================================================

class _WelcomeCard extends StatelessWidget {
  const _WelcomeCard({
    required this.onLogin,
    required this.onCreateAccount,
    required this.onForgotPassword,
  });

  final VoidCallback onLogin;
  final VoidCallback onCreateAccount;
  final VoidCallback onForgotPassword;

  static const Color primaryColor = Color(0xFF0E7C57);
  static const Color textColor = Color(0xFF26332E);
  static const Color secondaryTextColor = Color(0xFF71807A);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 25,
            offset: const Offset(0, 10),
          ),
        ],
      ),
      child: Column(
        children: [
          const Text(
            'Bienvenido',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: textColor,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Accede a los servicios de Salud Rural',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: secondaryTextColor,
            ),
          ),
          const SizedBox(height: 28),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: ElevatedButton.icon(
              onPressed: onLogin,
              icon: const Icon(Icons.login_rounded),
              label: const Text(
                'INICIAR SESIÓN',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            height: 54,
            child: OutlinedButton.icon(
              onPressed: onCreateAccount,
              icon: const Icon(
                Icons.person_add_alt_1_rounded,
              ),
              label: const Text(
                'CREAR CUENTA',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.5,
                ),
              ),
              style: OutlinedButton.styleFrom(
                foregroundColor: primaryColor,
                side: const BorderSide(
                  color: primaryColor,
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
            ),
          ),
          const SizedBox(height: 18),
          TextButton(
            onPressed: onForgotPassword,
            child: const Text(
              '¿Olvidaste tu contraseña?',
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// LOGO
// ============================================================

class _Logo extends StatelessWidget {
  const _Logo();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 110,
      height: 110,
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipOval(
        child: Image.asset(
          'assets/logo.png',
          fit: BoxFit.contain,
          errorBuilder: (_, __, ___) {
            return const Icon(
              Icons.local_hospital_rounded,
              size: 58,
              color: Color(0xFF0E7C57),
            );
          },
        ),
      ),
    );
  }
}

// ============================================================
// SELECTOR DE ROL
// ============================================================

class RoleSelector extends StatelessWidget {
  const RoleSelector({super.key});

  static const Color primaryColor = Color(0xFF0E7C57);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Crear cuenta',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              const SizedBox(height: 15),
              const Icon(
                Icons.group_rounded,
                size: 70,
                color: primaryColor,
              ),
              const SizedBox(height: 20),
              const Text(
                'Selecciona tu tipo de usuario',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF26332E),
                ),
              ),
              const SizedBox(height: 10),
              const Text(
                'Elige la opción correspondiente para continuar con el registro.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 15,
                  color: Color(0xFF71807A),
                ),
              ),
              const SizedBox(height: 35),
              _RoleButton(
                icon: Icons.person_rounded,
                title: 'Paciente',
                subtitle: 'Registrar paciente mediante documento de identidad',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => PacienteRegistroOcrScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _RoleButton(
                icon: Icons.medical_services_rounded,
                title: 'Médico',
                subtitle: 'Registro y validación profesional RETHUS',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const MedicoRegistroRethus(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),
              _RoleButton(
                icon: Icons.admin_panel_settings_rounded,
                title: 'Administrador',
                subtitle: 'Acceso al panel administrativo',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const AdminDashboard(),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ============================================================
// BOTÓN DE ROL
// ============================================================

class _RoleButton extends StatelessWidget {
  const _RoleButton({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  static const Color primaryColor = Color(0xFF0E7C57);

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(20),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: const Color(0xFFE0E8E4),
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 15,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: BoxDecoration(
                  color: const Color(0xFFE8F6F0),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Icon(
                  icon,
                  color: primaryColor,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF26332E),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFF71807A),
                        height: 1.3,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              const Icon(
                Icons.arrow_forward_ios_rounded,
                size: 18,
                color: primaryColor,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
