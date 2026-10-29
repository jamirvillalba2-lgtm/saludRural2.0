import 'package:flutter/material.dart';
import '../../../controllers/paciente_controller.dart';
import '../../../services/api_client.dart';
import 'paciente_dashboard.dart';

/// Pantalla de inicio de sesión para el paciente rural.
class LoginPacienteScreen extends StatefulWidget {
  const LoginPacienteScreen({super.key});

  @override
  State<LoginPacienteScreen> createState() => _LoginPacienteScreenState();
}

class _LoginPacienteScreenState extends State<LoginPacienteScreen> {
  // Controladores para los campos de texto
  final ccCtrl = TextEditingController();
  final passCtrl = TextEditingController();

  // Estados de la interfaz
  bool ver = false;
  bool loading = false;

  // Clave global para el formulario
  final _key = GlobalKey<FormState>();

  @override
  void dispose() {
    // Liberación de controladores para evitar fugas de memoria
    ccCtrl.dispose();
    passCtrl.dispose();
    super.dispose();
  }

  Future<void> login() async {
    if (!_key.currentState!.validate()) return;

    setState(() => loading = true);
    try {
      final paciente = await pacienteController.iniciarSesion(
        documento: ccCtrl.text,
        password: passCtrl.text,
      );
      if (!mounted) return;

      final documentoRecibido =
          _valor(paciente, ['documento', 'cc', 'numeroDocumento']);
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => PacienteDashboard(
            nombre: _valor(paciente, ['nombre', 'nombres']).isEmpty
                ? 'Paciente'
                : _valor(paciente, ['nombre', 'nombres']),
            cc: documentoRecibido.isEmpty
                ? ccCtrl.text.trim()
                : documentoRecibido,
            direccion: _valor(paciente, ['direccion']),
            vereda: _valor(paciente, ['vereda']),
            municipio: _valor(paciente, ['municipio']),
            telefono: _valor(paciente, ['telefono', 'celular']),
            correo: _valor(paciente, ['correo', 'email']),
            eps: _valor(paciente, ['eps']),
            fechaNacimiento: _valor(paciente, ['fechaNacimiento']),
            rh: _valor(paciente, ['rh']),
            sexo: _valor(paciente, ['sexo']),
            onCerrarSesion: () {
              Navigator.popUntil(context, (route) => route.isFirst);
            },
          ),
        ),
        (route) => false,
      );
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  String _valor(Map<String, dynamic> data, List<String> keys) {
    for (final key in keys) {
      final value = data[key];
      if (value != null && value.toString().trim().isNotEmpty) {
        return value.toString().trim();
      }
    }
    return '';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Iniciar Sesión Paciente'),
        backgroundColor: const Color(0xFF0E7C57),
        foregroundColor: Colors.white,
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _key,
          child: Column(
            children: [
              // Campo de Cédula
              TextFormField(
                controller: ccCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Cédula',
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.badge),
                ),
                validator: (v) => (v == null || v.isEmpty) ? "Requerido" : null,
              ),
              const SizedBox(height: 16),

              // Campo de Contraseña
              TextFormField(
                controller: passCtrl,
                obscureText: !ver,
                decoration: InputDecoration(
                  labelText: 'Contraseña',
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock),
                  suffixIcon: IconButton(
                    icon: Icon(
                      ver ? Icons.visibility_off : Icons.visibility,
                    ),
                    onPressed: () => setState(() => ver = !ver),
                  ),
                ),
                validator: (v) =>
                    (v == null || v.length < 6) ? "Mínimo 6 caracteres" : null,
              ),
              const SizedBox(height: 24),

              // Botón de Entrar
              SizedBox(
                width: double.infinity,
                height: 56,
                child: loading
                    ? const Center(child: CircularProgressIndicator())
                    : FilledButton(
                        style: FilledButton.styleFrom(
                          backgroundColor: const Color(0xFF0E7C57),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        onPressed: login,
                        child: const Text(
                          'Entrar al Dashboard',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
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
