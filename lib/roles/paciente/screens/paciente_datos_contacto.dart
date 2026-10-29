import 'dart:io';

import 'package:flutter/material.dart';

import '../../../controllers/paciente_controller.dart';
import '../../../services/api_client.dart';
import '../../../services/ocr_service.dart';
import 'paciente_dashboard.dart';

class PacienteDatosContacto extends StatefulWidget {
  final String cc;
  final String nombre;
  final String fechaNacimiento;
  final String lugarNacimiento;
  final String rh;
  final String estatura;
  final String sexo;
  final String fechaExpedicion;
  final String lugarExpedicion;
  final String tipoDocumento;
  final File? documentoFrente;
  final File? documentoReverso;
  final OcrResult? ocrFrente;
  final OcrResult? ocrReverso;
  final bool aceptoDatos;

  const PacienteDatosContacto({
    super.key,
    required this.cc,
    required this.nombre,
    this.fechaNacimiento = '',
    this.lugarNacimiento = '',
    this.rh = '',
    this.estatura = '',
    this.sexo = '',
    this.fechaExpedicion = '',
    this.lugarExpedicion = '',
    this.tipoDocumento = 'Cédula de ciudadanía',
    this.documentoFrente,
    this.documentoReverso,
    this.ocrFrente,
    this.ocrReverso,
    this.aceptoDatos = false,
  });

  @override
  State<PacienteDatosContacto> createState() => _PacienteDatosContactoState();
}

class _PacienteDatosContactoState extends State<PacienteDatosContacto> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  late final TextEditingController direccionCtrl;
  late final TextEditingController veredaCtrl;
  late final TextEditingController municipioCtrl;
  late final TextEditingController telefonoCtrl;
  late final TextEditingController correoCtrl;
  late final TextEditingController epsCtrl;
  late final TextEditingController passCtrl;
  late final TextEditingController pass2Ctrl;

  bool verPass = false;
  bool loading = false;

  @override
  void initState() {
    super.initState();

    // -------------------------------------------------------------
    // CAMPOS DE CONTACTO
    // -------------------------------------------------------------

    direccionCtrl = TextEditingController();
    veredaCtrl = TextEditingController();
    municipioCtrl = TextEditingController();
    telefonoCtrl = TextEditingController();
    correoCtrl = TextEditingController();
    epsCtrl = TextEditingController();

    // -------------------------------------------------------------
    // SEGURIDAD
    // -------------------------------------------------------------

    passCtrl = TextEditingController();
    pass2Ctrl = TextEditingController();
  }

  @override
  void dispose() {
    direccionCtrl.dispose();
    veredaCtrl.dispose();
    municipioCtrl.dispose();
    telefonoCtrl.dispose();
    correoCtrl.dispose();
    epsCtrl.dispose();
    passCtrl.dispose();
    pass2Ctrl.dispose();

    super.dispose();
  }

  // ---------------------------------------------------------------
  // FINALIZAR REGISTRO
  // ---------------------------------------------------------------

  Future<void> _finalizarRegistro() async {
    FocusScope.of(context).unfocus();

    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!widget.aceptoDatos) {
      _mostrarAdvertencia(
        'No se encontró la autorización de tratamiento de datos.',
      );
      return;
    }

    if (passCtrl.text != pass2Ctrl.text) {
      _mostrarAdvertencia(
        'Las contraseñas no coinciden.',
      );
      return;
    }

    setState(() {
      loading = true;
    });

    try {
      await pacienteController.registrar(
        datos: {
          'tipoDocumento': widget.tipoDocumento,
          'documento': widget.cc.trim(),
          'nombre': widget.nombre.trim(),
          'fechaNacimiento': widget.fechaNacimiento,
          'lugarNacimiento': widget.lugarNacimiento,
          'rh': widget.rh,
          'estatura': widget.estatura,
          'sexo': widget.sexo,
          'fechaExpedicion': widget.fechaExpedicion,
          'lugarExpedicion': widget.lugarExpedicion,
          'ocr': {
            'frente': _datosOcr(widget.ocrFrente),
            'reverso': _datosOcr(widget.ocrReverso),
          },
          'direccion': direccionCtrl.text.trim(),
          'vereda': veredaCtrl.text.trim(),
          'municipio': municipioCtrl.text.trim(),
          'telefono': telefonoCtrl.text.trim(),
          'correo': correoCtrl.text.trim(),
          'eps': epsCtrl.text.trim(),
          'password': passCtrl.text,
          'autorizacionTratamiento': widget.aceptoDatos,
        },
        documentoFrente: widget.documentoFrente,
        documentoReverso: widget.documentoReverso,
      );

      if (!mounted) return;
      _entrarAlDashboard();
    } on ApiException catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.message)),
      );
    } finally {
      if (mounted) {
        setState(() {
          loading = false;
        });
      }
    }
  }

  Map<String, dynamic>? _datosOcr(OcrResult? resultado) {
    if (resultado == null) return null;
    return {
      'documento': resultado.cc,
      'nombre': resultado.nombre,
      'fechaNacimiento': resultado.fechaNac,
      'lugarNacimiento': resultado.lugarNac,
      'estatura': resultado.estatura,
      'rh': resultado.rh,
      'sexo': resultado.sexo,
      'fechaExpedicion': resultado.fechaExp,
      'lugarExpedicion': resultado.lugarExp,
      'confianza': resultado.confianza,
      'textoCompleto': resultado.textoCompleto,
    };
  }

  // ---------------------------------------------------------------
  // IR AL DASHBOARD
  // ---------------------------------------------------------------

  void _entrarAlDashboard() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(
        builder: (_) => PacienteDashboard(
          nombre: widget.nombre,
          cc: widget.cc,
          direccion: direccionCtrl.text.trim(),
          vereda: veredaCtrl.text.trim(),
          municipio: municipioCtrl.text.trim(),
          telefono: telefonoCtrl.text.trim(),
          correo: correoCtrl.text.trim(),
          eps: epsCtrl.text.trim(),
          rh: widget.rh,
          fechaNacimiento: widget.fechaNacimiento,
          sexo: widget.sexo,
          onCerrarSesion: () {
            Navigator.popUntil(
              context,
              (route) => route.isFirst,
            );
          },
        ),
      ),
      (route) => false,
    );
  }

  // ---------------------------------------------------------------
  // VALIDAR CORREO
  // ---------------------------------------------------------------

  String? _validarCorreo(String? valor) {
    final correo = valor?.trim() ?? '';

    // El correo es opcional.
    if (correo.isEmpty) {
      return null;
    }

    final emailRegex = RegExp(
      r'^[\w\.-]+@([\w-]+\.)+[\w-]{2,}$',
    );

    if (!emailRegex.hasMatch(correo)) {
      return 'Correo electrónico inválido';
    }

    return null;
  }

  // ---------------------------------------------------------------
  // VALIDAR TELÉFONO
  // ---------------------------------------------------------------

  String? _validarTelefono(String? valor) {
    final telefono = valor?.replaceAll(
          RegExp(r'[^0-9]'),
          '',
        ) ??
        '';

    if (telefono.isEmpty) {
      return 'El celular es obligatorio';
    }

    if (telefono.length < 10) {
      return 'Debe tener al menos 10 dígitos';
    }

    return null;
  }

  // ---------------------------------------------------------------
  // VALIDAR CONTRASEÑA
  // ---------------------------------------------------------------

  String? _validarPassword(String? valor) {
    final password = valor ?? '';

    if (password.isEmpty) {
      return 'La contraseña es obligatoria';
    }

    if (password.length < 6) {
      return 'Mínimo 6 caracteres';
    }

    return null;
  }

  // ---------------------------------------------------------------
  // TARJETA DE IDENTIDAD
  // ---------------------------------------------------------------

  Widget _tarjetaIdentidad() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFFE8F5E9),
            Color(0xFFF4FBF7),
          ],
        ),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: const Color(0xFF0E7C57).withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 46,
            height: 46,
            decoration: const BoxDecoration(
              color: Color(0xFF0E7C57),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.nombre,
                  style: const TextStyle(
                    fontSize: 17,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  'Documento: ${widget.cc}',
                  style: const TextStyle(
                    color: Colors.black87,
                  ),
                ),
                if (widget.rh.trim().isNotEmpty ||
                    widget.sexo.trim().isNotEmpty) ...[
                  const SizedBox(height: 3),
                  Text(
                    [
                      if (widget.rh.trim().isNotEmpty) 'RH ${widget.rh}',
                      if (widget.sexo.trim().isNotEmpty) 'Sexo ${widget.sexo}',
                    ].join('  •  '),
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 13,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // CAMPO GENERAL
  // ---------------------------------------------------------------

  InputDecoration _decoracion(
    String label,
    IconData icono, {
    String? hint,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.shade300,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF0E7C57),
          width: 1.5,
        ),
      ),
      prefixIcon: Icon(
        icono,
        color: const Color(0xFF0E7C57),
      ),
    );
  }

  // ---------------------------------------------------------------
  // SECCIÓN
  // ---------------------------------------------------------------

  Widget _tituloSeccion(
    String titulo,
    String descripcion,
    IconData icono,
  ) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: const Color(0xFFE8F5E9),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Icon(
            icono,
            color: const Color(0xFF0E7C57),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
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
                descripcion,
                style: const TextStyle(
                  color: Colors.black54,
                  fontSize: 13,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ---------------------------------------------------------------
  // AVISO
  // ---------------------------------------------------------------

  Widget _aviso() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(13),
      decoration: BoxDecoration(
        color: const Color(0xFFFFF8E1),
        borderRadius: BorderRadius.circular(14),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline,
            color: Color(0xFF8A6500),
          ),
          SizedBox(width: 9),
          Expanded(
            child: Text(
              'Tus datos de identidad provienen del formulario '
              'que acabas de diligenciar. El OCR se utiliza como '
              'verificación y no reemplaza tus datos manuales.',
              style: TextStyle(
                fontSize: 12,
                height: 1.4,
                color: Color(0xFF6D5600),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // BUILD
  // ---------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final teclado = MediaQuery.of(context).viewInsets.bottom;

    return Scaffold(
      backgroundColor: const Color(0xFFF5F8F7),
      appBar: AppBar(
        elevation: 0,
        backgroundColor: const Color(0xFF0E7C57),
        foregroundColor: Colors.white,
        title: const Text(
          'Datos de contacto',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          padding: EdgeInsets.fromLTRB(
            16,
            16,
            16,
            30 + teclado,
          ),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ---------------------------------------------------
                // IDENTIDAD
                // ---------------------------------------------------

                _tarjetaIdentidad(),

                const SizedBox(height: 14),

                _aviso(),

                const SizedBox(height: 22),

                // ---------------------------------------------------
                // DATOS DE CONTACTO
                // ---------------------------------------------------

                _tituloSeccion(
                  'Datos de contacto',
                  'Completa la información necesaria para poder '
                      'contactarte.',
                  Icons.contact_phone_outlined,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: direccionCtrl,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'La dirección es obligatoria';
                    }
                    return null;
                  },
                  decoration: _decoracion(
                    'Dirección / Casa *',
                    Icons.home_outlined,
                    hint: 'Ej. Calle 10 # 20-30',
                  ),
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: veredaCtrl,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'La vereda o corregimiento es obligatorio';
                    }
                    return null;
                  },
                  decoration: _decoracion(
                    'Vereda / Corregimiento *',
                    Icons.landscape_outlined,
                    hint: 'Ej. Robles',
                  ),
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: municipioCtrl,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'El municipio es obligatorio';
                    }
                    return null;
                  },
                  decoration: _decoracion(
                    'Municipio *',
                    Icons.location_city_outlined,
                    hint: 'Ej. El Guamo',
                  ),
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: telefonoCtrl,
                  keyboardType: TextInputType.phone,
                  textInputAction: TextInputAction.next,
                  validator: _validarTelefono,
                  decoration: _decoracion(
                    'Celular / WhatsApp *',
                    Icons.phone_android_outlined,
                    hint: 'Ej. 3001234567',
                  ),
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: correoCtrl,
                  keyboardType: TextInputType.emailAddress,
                  textInputAction: TextInputAction.next,
                  validator: _validarCorreo,
                  decoration: _decoracion(
                    'Correo electrónico',
                    Icons.email_outlined,
                    hint: 'Ej. usuario@correo.com',
                  ),
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: epsCtrl,
                  textCapitalization: TextCapitalization.words,
                  textInputAction: TextInputAction.next,
                  validator: (valor) {
                    if (valor == null || valor.trim().isEmpty) {
                      return 'La EPS / SISBÉN es obligatoria';
                    }
                    return null;
                  },
                  decoration: _decoracion(
                    'EPS / SISBÉN *',
                    Icons.local_hospital_outlined,
                    hint: 'Ej. Salud Total',
                  ),
                ),

                const SizedBox(height: 24),

                const Divider(),

                const SizedBox(height: 12),

                // ---------------------------------------------------
                // SEGURIDAD
                // ---------------------------------------------------

                _tituloSeccion(
                  'Seguridad de la cuenta',
                  'Crea una contraseña para ingresar posteriormente.',
                  Icons.lock_outline,
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: passCtrl,
                  obscureText: !verPass,
                  textInputAction: TextInputAction.next,
                  validator: _validarPassword,
                  decoration: InputDecoration(
                    labelText: 'Crear contraseña *',
                    hintText: 'Mínimo 6 caracteres',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      color: Color(0xFF0E7C57),
                    ),
                    suffixIcon: IconButton(
                      tooltip:
                          verPass ? 'Ocultar contraseña' : 'Mostrar contraseña',
                      icon: Icon(
                        verPass ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          verPass = !verPass;
                        });
                      },
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                TextFormField(
                  controller: pass2Ctrl,
                  obscureText: !verPass,
                  textInputAction: TextInputAction.done,
                  validator: (valor) {
                    if (valor == null || valor.isEmpty) {
                      return 'Confirma la contraseña';
                    }

                    if (valor != passCtrl.text) {
                      return 'Las contraseñas no coinciden';
                    }

                    return null;
                  },
                  onFieldSubmitted: (_) {
                    if (!loading) {
                      _finalizarRegistro();
                    }
                  },
                  decoration: InputDecoration(
                    labelText: 'Confirmar contraseña *',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                    prefixIcon: const Icon(
                      Icons.lock_reset_outlined,
                      color: Color(0xFF0E7C57),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                // ---------------------------------------------------
                // BOTÓN
                // ---------------------------------------------------

                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: FilledButton.icon(
                    onPressed: loading ? null : _finalizarRegistro,
                    style: FilledButton.styleFrom(
                      backgroundColor: const Color(0xFF0E7C57),
                      disabledBackgroundColor:
                          const Color(0xFF0E7C57).withValues(alpha: 0.45),
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                    ),
                    icon: loading
                        ? const SizedBox(
                            width: 21,
                            height: 21,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              color: Colors.white,
                            ),
                          )
                        : const Icon(
                            Icons.person_add_alt_1,
                          ),
                    label: Text(
                      loading ? 'Creando cuenta...' : 'Crear cuenta y entrar',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 12),

                const Center(
                  child: Text(
                    'Al crear la cuenta se utilizarán los datos '
                    'proporcionados en este formulario.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black45,
                      fontSize: 11,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // SNACKBAR
  // ---------------------------------------------------------------

  void _mostrarAdvertencia(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.orange.shade800,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }
}
