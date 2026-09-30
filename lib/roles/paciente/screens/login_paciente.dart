import 'package:flutter/material.dart';
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

  /// Función para simular o validar el inicio de sesión
  void login() async {
    if (!_key.currentState!.validate()) return;

    setState(() => loading = true);
    await Future.delayed(const Duration(seconds: 1));

    // TODO: Validar credenciales con Supabase en el futuro
    // final res = await Supabase.instance.client.from('pacientes').select().eq('cc', ccCtrl.text).eq('password', passCtrl.text).single();

    if (!mounted) return;
    setState(() => loading = false);

    // Navegación hacia el Dashboard pasando todos los parámetros requeridos
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => PacienteDashboard(
          nombre: "JAMIR ENRIQUE VILLALBA ORO",
          cc: ccCtrl.text,
          direccion: "mz A lote 44",
          vereda: "Asturias",
          municipio: "turbaco",
          telefono: "3205504708",
          correo:
              "jamir.villalba@example.com", // <-- Parámetro agregado para evitar errores
          eps: "salud total",
          fechaNacimiento: "07-AGO-1995",
          rh: "O+",
          sexo: "M",
          onCerrarSesion: () {
            // Lógica para regresar al login al cerrar sesión
            Navigator.popUntil(context, (route) => route.isFirst);
          }, // <-- Parámetro agregado requerido por el dashboard
        ),
      ),
      (r) => false,
    );
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
