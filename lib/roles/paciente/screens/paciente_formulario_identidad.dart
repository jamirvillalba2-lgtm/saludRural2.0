import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class PacienteFormularioIdentidad extends StatefulWidget {
  final String tipoDocumentoInicial;
  final String numeroInicial;
  final String nombresInicial;
  final String apellidosInicial;
  final String fechaNacimientoInicial;
  final String lugarNacimientoInicial;
  final String sexoInicial;
  final String rhInicial;
  final String estaturaInicial;
  final String fechaExpedicionInicial;
  final String lugarExpedicionInicial;

  final void Function({
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
  }) onChanged;

  const PacienteFormularioIdentidad({
    super.key,
    this.tipoDocumentoInicial = 'Cédula de ciudadanía',
    this.numeroInicial = '',
    this.nombresInicial = '',
    this.apellidosInicial = '',
    this.fechaNacimientoInicial = '',
    this.lugarNacimientoInicial = '',
    this.sexoInicial = '',
    this.rhInicial = '',
    this.estaturaInicial = '',
    this.fechaExpedicionInicial = '',
    this.lugarExpedicionInicial = '',
    required this.onChanged,
  });

  @override
  State<PacienteFormularioIdentidad> createState() =>
      _PacienteFormularioIdentidadState();
}

class _PacienteFormularioIdentidadState
    extends State<PacienteFormularioIdentidad> {
  late final TextEditingController numeroCtrl;
  late final TextEditingController nombresCtrl;
  late final TextEditingController apellidosCtrl;
  late final TextEditingController fechaNacimientoCtrl;
  late final TextEditingController lugarNacimientoCtrl;
  late final TextEditingController rhCtrl;
  late final TextEditingController estaturaCtrl;
  late final TextEditingController fechaExpedicionCtrl;
  late final TextEditingController lugarExpedicionCtrl;

  late String tipoDocumento;
  String sexo = '';

  @override
  void initState() {
    super.initState();

    tipoDocumento = widget.tipoDocumentoInicial;
    sexo = widget.sexoInicial;

    numeroCtrl = TextEditingController(text: widget.numeroInicial);
    nombresCtrl = TextEditingController(text: widget.nombresInicial);
    apellidosCtrl = TextEditingController(text: widget.apellidosInicial);
    fechaNacimientoCtrl =
        TextEditingController(text: widget.fechaNacimientoInicial);
    lugarNacimientoCtrl =
        TextEditingController(text: widget.lugarNacimientoInicial);
    rhCtrl = TextEditingController(text: widget.rhInicial);
    estaturaCtrl = TextEditingController(text: widget.estaturaInicial);
    fechaExpedicionCtrl =
        TextEditingController(text: widget.fechaExpedicionInicial);
    lugarExpedicionCtrl =
        TextEditingController(text: widget.lugarExpedicionInicial);

    for (final controller in [
      numeroCtrl,
      nombresCtrl,
      apellidosCtrl,
      fechaNacimientoCtrl,
      lugarNacimientoCtrl,
      rhCtrl,
      estaturaCtrl,
      fechaExpedicionCtrl,
      lugarExpedicionCtrl,
    ]) {
      controller.addListener(_notificarCambios);
    }
  }

  void _notificarCambios() {
    widget.onChanged(
      tipoDocumento: tipoDocumento,
      numero: numeroCtrl.text.trim(),
      nombres: nombresCtrl.text.trim(),
      apellidos: apellidosCtrl.text.trim(),
      fechaNacimiento: fechaNacimientoCtrl.text.trim(),
      lugarNacimiento: lugarNacimientoCtrl.text.trim(),
      sexo: sexo.trim(),
      rh: rhCtrl.text.trim(),
      estatura: estaturaCtrl.text.trim(),
      fechaExpedicion: fechaExpedicionCtrl.text.trim(),
      lugarExpedicion: lugarExpedicionCtrl.text.trim(),
    );
  }

  @override
  void dispose() {
    numeroCtrl.dispose();
    nombresCtrl.dispose();
    apellidosCtrl.dispose();
    fechaNacimientoCtrl.dispose();
    lugarNacimientoCtrl.dispose();
    rhCtrl.dispose();
    estaturaCtrl.dispose();
    fechaExpedicionCtrl.dispose();
    lugarExpedicionCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
      child: Column(
        children: [
          DropdownButtonFormField<String>(
            initialValue: tipoDocumento,
            decoration: _decoracion(
              'Tipo de documento',
              Icons.badge_outlined,
            ),
            items: const [
              DropdownMenuItem(
                value: 'Cédula de ciudadanía',
                child: Text('Cédula de ciudadanía'),
              ),
              DropdownMenuItem(
                value: 'Tarjeta de identidad',
                child: Text('Tarjeta de identidad'),
              ),
            ],
            onChanged: (value) {
              if (value == null) return;

              setState(() {
                tipoDocumento = value;
              });

              _notificarCambios();
            },
          ),
          const SizedBox(height: 12),
          _campo(
            numeroCtrl,
            'Número de documento *',
            Icons.numbers,
            keyboardType: TextInputType.number,
            formatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
          ),
          const SizedBox(height: 12),
          _campo(
            nombresCtrl,
            'Nombres *',
            Icons.person_outline,
            capitalizacion: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          _campo(
            apellidosCtrl,
            'Apellidos *',
            Icons.person_outline,
            capitalizacion: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          _campo(
            fechaNacimientoCtrl,
            'Fecha de nacimiento',
            Icons.cake_outlined,
            hint: 'DD/MM/AAAA',
          ),
          const SizedBox(height: 12),
          _campo(
            lugarNacimientoCtrl,
            'Lugar de nacimiento',
            Icons.location_on_outlined,
            capitalizacion: TextCapitalization.words,
          ),
          const SizedBox(height: 12),
          DropdownButtonFormField<String>(
            initialValue: sexo.isEmpty ? null : sexo,
            decoration: _decoracion(
              'Sexo',
              Icons.person_outline,
            ),
            items: const [
              DropdownMenuItem(
                value: 'M',
                child: Text('Masculino'),
              ),
              DropdownMenuItem(
                value: 'F',
                child: Text('Femenino'),
              ),
            ],
            onChanged: (value) {
              setState(() {
                sexo = value ?? '';
              });

              _notificarCambios();
            },
          ),
          const SizedBox(height: 12),
          _campo(
            rhCtrl,
            'RH',
            Icons.bloodtype_outlined,
            capitalizacion: TextCapitalization.characters,
          ),
          const SizedBox(height: 12),
          _campo(
            estaturaCtrl,
            'Estatura',
            Icons.height,
            keyboardType: const TextInputType.numberWithOptions(
              decimal: true,
            ),
          ),
          const SizedBox(height: 12),
          _campo(
            fechaExpedicionCtrl,
            'Fecha de expedición',
            Icons.event_outlined,
            hint: 'DD/MM/AAAA',
          ),
          const SizedBox(height: 12),
          _campo(
            lugarExpedicionCtrl,
            'Lugar de expedición',
            Icons.location_city_outlined,
            capitalizacion: TextCapitalization.words,
          ),
        ],
      ),
    );
  }

  Widget _campo(
    TextEditingController controller,
    String etiqueta,
    IconData icono, {
    TextInputType? keyboardType,
    TextCapitalization capitalizacion = TextCapitalization.none,
    String? hint,
    List<TextInputFormatter>? formatters,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: keyboardType,
      textCapitalization: capitalizacion,
      inputFormatters: formatters,
      decoration: _decoracion(
        etiqueta,
        icono,
        hint: hint,
      ),
    );
  }

  InputDecoration _decoracion(
    String etiqueta,
    IconData icono, {
    String? hint,
  }) {
    return InputDecoration(
      labelText: etiqueta,
      hintText: hint,
      prefixIcon: const Icon(
        Icons.circle,
        color: Color(0xFF0E7C57),
      ),
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(
          color: Colors.grey.shade200,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: const BorderSide(
          color: Color(0xFF0E7C57),
          width: 1.5,
        ),
      ),
    );
  }
}
