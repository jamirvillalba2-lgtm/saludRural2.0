import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../../../services/ocr_service.dart';
import 'paciente_datos_contacto.dart';
import 'paciente_formulario_identidad.dart';

class PacienteRegistroOcrScreen extends StatefulWidget {
  const PacienteRegistroOcrScreen({super.key});

  @override
  State<PacienteRegistroOcrScreen> createState() =>
      _PacienteRegistroOcrScreenState();
}

class _PacienteRegistroOcrScreenState extends State<PacienteRegistroOcrScreen> {
  final ImagePicker _picker = ImagePicker();
  final OcrService _ocrService = OcrService();

  File? _imagenFrente;
  File? _imagenReverso;

  OcrResult? _resultadoFrente;
  OcrResult? _resultadoReverso;

  bool _procesandoFrente = false;
  bool _procesandoReverso = false;
  bool _aceptaHabeas = false;

  // ---------------------------------------------------------------
  // DATOS INGRESADOS MANUALMENTE
  // ---------------------------------------------------------------

  String _tipoDocumento = 'Cédula de ciudadanía';
  String _cc = '';
  String _nombres = '';
  String _apellidos = '';
  String _nombre = '';

  String _fechaNacimiento = '';
  String _lugarNacimiento = '';
  String _rh = '';
  String _estatura = '';
  String _sexo = '';
  String _fechaExpedicion = '';
  String _lugarExpedicion = '';

  // ---------------------------------------------------------------
  // ACTUALIZAR FORMULARIO
  // ---------------------------------------------------------------

  void _actualizarFormulario({
    required String tipoDocumento,
    required String numero,
    required String nombres,
    required String apellidos,
    required String fechaNacimiento,
    required String lugarNacimiento,
    required String sexo,
    required String rh,
    required String estatura,
    required String fechaExpedicion,
    required String lugarExpedicion,
  }) {
    setState(() {
      _tipoDocumento = tipoDocumento;
      _cc = numero;
      _nombres = nombres;
      _apellidos = apellidos;
      _nombre = '$nombres $apellidos'.trim();

      _fechaNacimiento = fechaNacimiento;
      _lugarNacimiento = lugarNacimiento;
      _sexo = sexo;
      _rh = rh;
      _estatura = estatura;
      _fechaExpedicion = fechaExpedicion;
      _lugarExpedicion = lugarExpedicion;
    });
  }

  // ---------------------------------------------------------------
  // VALIDAR DATOS MANUALES
  // ---------------------------------------------------------------

  bool _datosBasicosCompletos() {
    return _cc.trim().isNotEmpty &&
        _nombres.trim().isNotEmpty &&
        _apellidos.trim().isNotEmpty;
  }

  void _validarAntesDeFoto() {
    if (!_datosBasicosCompletos()) {
      _mostrarAdvertencia(
        'Primero completa tipo de documento, número, nombres y apellidos.',
      );
    }
  }

  // ---------------------------------------------------------------
  // SELECCIONAR IMAGEN
  // ---------------------------------------------------------------

  Future<File?> _seleccionarImagen() async {
    try {
      final opcion = await showModalBottomSheet<int>(
        context: context,
        backgroundColor: Colors.white,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(
            top: Radius.circular(24),
          ),
        ),
        builder: (context) {
          return SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 45,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.grey.shade300,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'Seleccionar imagen',
                    style: TextStyle(
                      fontSize: 19,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Elige cómo deseas obtener la imagen del documento.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.black54,
                    ),
                  ),
                  const SizedBox(height: 20),
                  ListTile(
                    leading: _iconoOpcion(Icons.camera_alt),
                    title: const Text(
                      'Tomar fotografía',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Usar la cámara del teléfono',
                    ),
                    onTap: () => Navigator.pop(context, 1),
                  ),
                  ListTile(
                    leading: _iconoOpcion(Icons.photo_library),
                    title: const Text(
                      'Seleccionar de galería',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    subtitle: const Text(
                      'Usar una imagen existente',
                    ),
                    onTap: () => Navigator.pop(context, 2),
                  ),
                ],
              ),
            ),
          );
        },
      );

      if (opcion == null) return null;

      final XFile? imagen = await _picker.pickImage(
        source: opcion == 1 ? ImageSource.camera : ImageSource.gallery,
        imageQuality: 95,
        maxWidth: 2400,
        maxHeight: 2400,
      );

      if (imagen == null) return null;

      return File(imagen.path);
    } catch (e) {
      if (!mounted) return null;

      _mostrarError(
        'No fue posible obtener la imagen.\n\n$e',
      );

      return null;
    }
  }

  // ---------------------------------------------------------------
  // PROCESAR FRENTE
  // ---------------------------------------------------------------

  Future<void> _procesarFrente() async {
    if (!_datosBasicosCompletos()) {
      _validarAntesDeFoto();
      return;
    }

    final imagen = await _seleccionarImagen();

    if (imagen == null) return;

    setState(() {
      _imagenFrente = imagen;
      _resultadoFrente = null;
      _procesandoFrente = true;
    });

    try {
      final resultado = await _ocrService.procesarFrente(imagen);

      if (!mounted) return;

      setState(() {
        _resultadoFrente = resultado;
        _procesandoFrente = false;
      });

      if (resultado.confianza < 0.5) {
        _mostrarAdvertencia(
          'El OCR tiene baja confianza. '
          'Los datos manuales se conservarán y podrás revisarlos.',
        );
      } else {
        _mostrarMensaje(
          'Frente procesado. Se comparará con los datos ingresados.',
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _procesandoFrente = false;
      });

      _mostrarError(
        'No fue posible procesar el frente.\n\n$e',
      );
    }
  }

  // ---------------------------------------------------------------
  // PROCESAR REVERSO
  // ---------------------------------------------------------------

  Future<void> _procesarReverso() async {
    if (!_datosBasicosCompletos()) {
      _validarAntesDeFoto();
      return;
    }

    if (_imagenFrente == null) {
      _mostrarAdvertencia(
        'Primero captura el frente del documento.',
      );
      return;
    }

    final imagen = await _seleccionarImagen();

    if (imagen == null) return;

    setState(() {
      _imagenReverso = imagen;
      _resultadoReverso = null;
      _procesandoReverso = true;
    });

    try {
      final resultado = await _ocrService.procesarReverso(imagen);

      if (!mounted) return;

      setState(() {
        _resultadoReverso = resultado;
        _procesandoReverso = false;
      });

      if (resultado.confianza < 0.5) {
        _mostrarAdvertencia(
          'El reverso tiene baja confianza OCR. '
          'Puedes continuar y revisar los datos manualmente.',
        );
      } else {
        _mostrarMensaje(
          'Reverso procesado correctamente.',
        );
      }
    } catch (e) {
      if (!mounted) return;

      setState(() {
        _procesandoReverso = false;
      });

      _mostrarError(
        'No fue posible procesar el reverso.\n\n$e',
      );
    }
  }

  // ---------------------------------------------------------------
  // NORMALIZAR TEXTO PARA COMPARAR
  // ---------------------------------------------------------------

  String _normalizar(String texto) {
    return texto
        .trim()
        .toUpperCase()
        .replaceAll('Á', 'A')
        .replaceAll('É', 'E')
        .replaceAll('Í', 'I')
        .replaceAll('Ó', 'O')
        .replaceAll('Ú', 'U')
        .replaceAll('Ü', 'U')
        .replaceAll(RegExp(r'\s+'), ' ');
  }

  String _soloNumeros(String texto) {
    return texto.replaceAll(RegExp(r'[^0-9]'), '');
  }

  // ---------------------------------------------------------------
  // COMPARAR DOCUMENTO
  // ---------------------------------------------------------------

  bool _documentoCoincide() {
    if (_resultadoFrente == null) return false;

    final manual = _soloNumeros(_cc);
    final ocr = _soloNumeros(_resultadoFrente!.cc);

    if (manual.isEmpty || ocr.isEmpty) return false;

    return manual == ocr;
  }

  // ---------------------------------------------------------------
  // COMPARAR NOMBRE
  // ---------------------------------------------------------------

  bool _nombreCoincide() {
    if (_resultadoFrente == null) return false;

    final manual = _normalizar(_nombre);
    final ocr = _normalizar(_resultadoFrente!.nombre);

    if (manual.isEmpty || ocr.isEmpty) return false;

    return manual == ocr || manual.contains(ocr) || ocr.contains(manual);
  }

  // ---------------------------------------------------------------
  // RESULTADOS OCR
  // ---------------------------------------------------------------

  Widget _resultadoComparacion() {
    final frente = _resultadoFrente;
    final reverso = _resultadoReverso;

    if (frente == null && reverso == null) {
      return const SizedBox.shrink();
    }

    final documentoOk = _documentoCoincide();
    final nombreOk = _nombreCoincide();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: const Color(0xFF0E7C57).withValues(alpha: 0.15),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.fact_check_outlined,
                color: Color(0xFF0E7C57),
              ),
              SizedBox(width: 8),
              Text(
                'Verificación OCR',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (frente != null) ...[
            _estadoComparacion(
              titulo: 'Número de documento',
              correcto: documentoOk,
              manual: _cc,
              ocr: frente.cc,
            ),
            const SizedBox(height: 10),
            _estadoComparacion(
              titulo: 'Nombre completo',
              correcto: nombreOk,
              manual: _nombre,
              ocr: frente.nombre,
            ),
            const SizedBox(height: 12),
            _confianza(
              'Frente',
              frente.confianza,
            ),
          ],
          if (reverso != null) ...[
            const SizedBox(height: 8),
            _confianza(
              'Reverso',
              reverso.confianza,
            ),
          ],
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: const Color(0xFFFFF8E1),
              borderRadius: BorderRadius.circular(12),
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
                    'La lectura OCR sirve como verificación. '
                    'Los datos ingresados manualmente no serán '
                    'reemplazados automáticamente.',
                    style: TextStyle(
                      fontSize: 12,
                      height: 1.4,
                      color: Color(0xFF6D5600),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // ESTADO DE COMPARACIÓN
  // ---------------------------------------------------------------

  Widget _estadoComparacion({
    required String titulo,
    required bool correcto,
    required String manual,
    required String ocr,
  }) {
    final tieneOcr = ocr.trim().isNotEmpty;

    if (!tieneOcr) {
      return _filaEstado(
        titulo: titulo,
        icono: Icons.help_outline,
        color: Colors.orange,
        mensaje: 'No detectado por OCR',
      );
    }

    return _filaEstado(
      titulo: titulo,
      icono:
          correcto ? Icons.check_circle_outline : Icons.warning_amber_rounded,
      color: correcto ? const Color(0xFF0E7C57) : Colors.orange,
      mensaje: correcto ? 'Coincide con el documento' : 'Revisar datos',
    );
  }

  Widget _filaEstado({
    required String titulo,
    required IconData icono,
    required Color color,
    required String mensaje,
  }) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Row(
        children: [
          Icon(
            icono,
            color: color,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              titulo,
              style: const TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            mensaje,
            style: TextStyle(
              color: color,
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // CONFIANZA OCR
  // ---------------------------------------------------------------

  Widget _confianza(
    String titulo,
    double confianza,
  ) {
    final porcentaje = (confianza.clamp(0.0, 1.0) * 100).round();

    final Color color;

    if (porcentaje < 50) {
      color = Colors.red;
    } else if (porcentaje < 80) {
      color = Colors.orange;
    } else {
      color = const Color(0xFF0E7C57);
    }

    return Container(
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Icon(
            Icons.verified_outlined,
            size: 18,
            color: color,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              'Confianza OCR - $titulo',
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Text(
            '$porcentaje%',
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // HABEAS DATA
  // ---------------------------------------------------------------

  Widget _tarjetaHabeas() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.grey.shade200,
        ),
      ),
      child: CheckboxListTile(
        value: _aceptaHabeas,
        onChanged: (valor) {
          setState(() {
            _aceptaHabeas = valor ?? false;
          });
        },
        activeColor: const Color(0xFF0E7C57),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 14,
          vertical: 8,
        ),
        controlAffinity: ListTileControlAffinity.leading,
        title: const Text(
          'Autorización de tratamiento de datos',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: const Padding(
          padding: EdgeInsets.only(top: 5),
          child: Text(
            'Autorizo el tratamiento de mis datos personales '
            'para los fines relacionados con la prestación y '
            'gestión de los servicios de Salud Rural.',
            style: TextStyle(
              fontSize: 12,
              height: 1.4,
              color: Colors.black54,
            ),
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // CONTINUAR
  // ---------------------------------------------------------------

  void _continuar() {
    if (!_datosBasicosCompletos()) {
      _mostrarAdvertencia(
        'Completa número de documento, nombres y apellidos.',
      );
      return;
    }

    if (!_aceptaHabeas) {
      _mostrarAdvertencia(
        'Debes aceptar el tratamiento de datos personales '
        'para continuar.',
      );
      return;
    }

    if (_resultadoFrente == null && _resultadoReverso == null) {
      _mostrarAdvertencia(
        'Puedes continuar, pero se recomienda procesar '
        'al menos una cara del documento.',
      );
    }

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => PacienteDatosContacto(
          cc: _cc,
          nombre: _nombre,
          fechaNacimiento: _fechaNacimiento,
          lugarNacimiento: _lugarNacimiento,
          rh: _rh,
          estatura: _estatura,
          sexo: _sexo,
          fechaExpedicion: _fechaExpedicion,
          lugarExpedicion: _lugarExpedicion,
          tipoDocumento: _tipoDocumento,
          documentoFrente: _imagenFrente,
          documentoReverso: _imagenReverso,
          ocrFrente: _resultadoFrente,
          ocrReverso: _resultadoReverso,
          aceptoDatos: _aceptaHabeas,
        ),
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
          'Registro del paciente',
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
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _encabezado(),
              const SizedBox(height: 18),
              _tarjetaFormulario(),
              const SizedBox(height: 18),
              _tarjetaFrente(),
              const SizedBox(height: 16),
              _tarjetaReverso(),
              const SizedBox(height: 16),
              if (_resultadoFrente != null || _resultadoReverso != null) ...[
                _resultadoComparacion(),
                const SizedBox(height: 16),
              ],
              _tarjetaHabeas(),
              const SizedBox(height: 20),
              _botonContinuar(),
            ],
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // ENCABEZADO
  // ---------------------------------------------------------------

  Widget _encabezado() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [
            Color(0xFF0E7C57),
            Color(0xFF15966C),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.person_add_alt_1,
            color: Colors.white,
            size: 42,
          ),
          SizedBox(height: 12),
          Text(
            'Registro de identidad',
            style: TextStyle(
              color: Colors.white,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          SizedBox(height: 7),
          Text(
            'Primero ingresa tus datos manualmente. '
            'Después podremos verificar el documento mediante OCR.',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // FORMULARIO MANUAL
  // ---------------------------------------------------------------

  Widget _tarjetaFormulario() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(
                Icons.edit_note,
                color: Color(0xFF0E7C57),
              ),
              SizedBox(width: 8),
              Expanded(
                child: Text(
                  '1. Datos personales',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          const Text(
            'Completa tus datos antes de fotografiar el documento.',
            style: TextStyle(
              color: Colors.black54,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 16),
          PacienteFormularioIdentidad(
            tipoDocumentoInicial: _tipoDocumento,
            numeroInicial: _cc,
            nombresInicial: _nombres,
            apellidosInicial: _apellidos,
            fechaNacimientoInicial: _fechaNacimiento,
            lugarNacimientoInicial: _lugarNacimiento,
            sexoInicial: _sexo,
            rhInicial: _rh,
            estaturaInicial: _estatura,
            fechaExpedicionInicial: _fechaExpedicion,
            lugarExpedicionInicial: _lugarExpedicion,
            onChanged: _actualizarFormulario,
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // TARJETA FRENTE
  // ---------------------------------------------------------------

  Widget _tarjetaFrente() {
    return _tarjetaPaso(
      numero: '2',
      titulo: 'Verificar frente',
      descripcion: 'El OCR leerá el documento y comparará el número y nombre.',
      icono: Icons.credit_card,
      completado: _resultadoFrente != null,
      child: Column(
        children: [
          if (_imagenFrente != null) ...[
            _vistaPreviaImagen(_imagenFrente!),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: _procesandoFrente ? null : _procesarFrente,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0E7C57),
                disabledBackgroundColor:
                    const Color(0xFF0E7C57).withValues(alpha: 0.45),
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              icon: _procesandoFrente
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.camera_alt),
              label: Text(
                _procesandoFrente
                    ? 'Analizando documento...'
                    : _resultadoFrente == null
                        ? 'Capturar frente'
                        : 'Volver a capturar',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // TARJETA REVERSO
  // ---------------------------------------------------------------

  Widget _tarjetaReverso() {
    return _tarjetaPaso(
      numero: '3',
      titulo: 'Verificar reverso',
      descripcion: 'El OCR intentará leer fecha, RH, sexo y demás información.',
      icono: Icons.flip,
      completado: _resultadoReverso != null,
      child: Column(
        children: [
          if (_imagenReverso != null) ...[
            _vistaPreviaImagen(_imagenReverso!),
            const SizedBox(height: 12),
          ],
          SizedBox(
            width: double.infinity,
            height: 52,
            child: FilledButton.icon(
              onPressed: (_imagenFrente == null || _procesandoReverso)
                  ? null
                  : _procesarReverso,
              style: FilledButton.styleFrom(
                backgroundColor: const Color(0xFF0E7C57),
                disabledBackgroundColor: Colors.grey.shade300,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              icon: _procesandoReverso
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : const Icon(Icons.camera_alt),
              label: Text(
                _procesandoReverso
                    ? 'Analizando documento...'
                    : _resultadoReverso == null
                        ? 'Capturar reverso'
                        : 'Volver a capturar',
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // TARJETA DE PASO
  // ---------------------------------------------------------------

  Widget _tarjetaPaso({
    required String numero,
    required String titulo,
    required String descripcion,
    required IconData icono,
    required bool completado,
    required Widget child,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: BoxDecoration(
                  color: completado
                      ? const Color(0xFFE8F5E9)
                      : const Color(0xFFEAF6F1),
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: completado
                      ? const Icon(
                          Icons.check,
                          color: Color(0xFF0E7C57),
                        )
                      : Text(
                          numero,
                          style: const TextStyle(
                            color: Color(0xFF0E7C57),
                            fontWeight: FontWeight.bold,
                            fontSize: 18,
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          icono,
                          size: 19,
                          color: const Color(0xFF0E7C57),
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            titulo,
                            style: const TextStyle(
                              fontSize: 17,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 5),
                    Text(
                      descripcion,
                      style: const TextStyle(
                        fontSize: 13,
                        color: Colors.black54,
                        height: 1.35,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          child,
        ],
      ),
    );
  }

  // ---------------------------------------------------------------
  // VISTA PREVIA
  // ---------------------------------------------------------------

  Widget _vistaPreviaImagen(File imagen) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(15),
      child: SizedBox(
        width: double.infinity,
        height: 180,
        child: Image.file(
          imagen,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) {
            return Container(
              color: Colors.grey.shade200,
              child: const Center(
                child: Icon(
                  Icons.broken_image_outlined,
                  size: 40,
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // ICONO OPCIÓN
  // ---------------------------------------------------------------

  Widget _iconoOpcion(IconData icono) {
    return Container(
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: const Color(0xFFE8F5E9),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Icon(
        icono,
        color: const Color(0xFF0E7C57),
      ),
    );
  }

  // ---------------------------------------------------------------
  // BOTÓN CONTINUAR
  // ---------------------------------------------------------------

  Widget _botonContinuar() {
    final habilitado = _datosBasicosCompletos() && _aceptaHabeas;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: FilledButton.icon(
        onPressed: habilitado ? _continuar : null,
        style: FilledButton.styleFrom(
          backgroundColor: const Color(0xFF0E7C57),
          disabledBackgroundColor: Colors.grey.shade300,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(30),
          ),
        ),
        icon: const Icon(Icons.arrow_forward),
        label: const Text(
          'Continuar con el registro',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  // ---------------------------------------------------------------
  // SNACKBAR MENSAJE
  // ---------------------------------------------------------------

  void _mostrarMensaje(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: const Color(0xFF0E7C57),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  // ---------------------------------------------------------------
  // SNACKBAR ADVERTENCIA
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

  // ---------------------------------------------------------------
  // SNACKBAR ERROR
  // ---------------------------------------------------------------

  void _mostrarError(String mensaje) {
    if (!mounted) return;

    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(mensaje),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
  }

  // ---------------------------------------------------------------
  // DISPOSE
  // ---------------------------------------------------------------

  @override
  void dispose() {
    _ocrService.dispose();
    super.dispose();
  }
}
