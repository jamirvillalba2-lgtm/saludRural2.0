import 'dart:io';

import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class OcrResult {
  final String cc;
  final String nombre;
  final String fechaNac;
  final String lugarNac;
  final String estatura;
  final String rh;
  final String sexo;
  final String fechaExp;
  final String lugarExp;
  final double confianza;
  final String textoCompleto;

  const OcrResult({
    this.cc = '',
    this.nombre = '',
    this.fechaNac = '',
    this.lugarNac = '',
    this.estatura = '',
    this.rh = '',
    this.sexo = '',
    this.fechaExp = '',
    this.lugarExp = '',
    this.confianza = 0,
    this.textoCompleto = '',
  });
}

class OcrService {
  final TextRecognizer _recognizer = TextRecognizer(
    script: TextRecognitionScript.latin,
  );

  bool _cerrado = false;

  // ============================================================
  // FRENTE DE LA CÉDULA
  // ============================================================

  Future<OcrResult> procesarFrente(File archivo) async {
    _validarArchivo(archivo);

    final texto = await _obtenerTexto(archivo);
    final normalizado = _normalizar(texto);

    final cc = _extraerCedula(normalizado);
    final nombre = _extraerNombreCompleto(normalizado);

    final confianza = _calcularConfianzaFrente(
      cc: cc,
      nombre: nombre,
    );

    return OcrResult(
      cc: cc,
      nombre: nombre,
      confianza: confianza,
      textoCompleto: texto,
    );
  }

  // ============================================================
  // REVERSO DE LA CÉDULA
  // ============================================================

  Future<OcrResult> procesarReverso(File archivo) async {
    _validarArchivo(archivo);

    final texto = await _obtenerTexto(archivo);
    final normalizado = _normalizar(texto);

    final fechaNac = _extraerFechaNacimiento(normalizado);
    final lugarNac = _extraerLugarNacimiento(normalizado);
    final estatura = _extraerEstatura(normalizado);
    final rh = _extraerRh(normalizado);
    final sexo = _extraerSexo(normalizado);
    final fechaExp = _extraerFechaExpedicion(normalizado);
    final lugarExp = _extraerLugarExpedicion(normalizado);

    final confianza = _calcularConfianzaReverso(
      fechaNac: fechaNac,
      lugarNac: lugarNac,
      estatura: estatura,
      rh: rh,
      sexo: sexo,
      fechaExp: fechaExp,
      lugarExp: lugarExp,
    );

    return OcrResult(
      fechaNac: fechaNac,
      lugarNac: lugarNac,
      estatura: estatura,
      rh: rh,
      sexo: sexo,
      fechaExp: fechaExp,
      lugarExp: lugarExp,
      confianza: confianza,
      textoCompleto: texto,
    );
  }

  // ============================================================
  // LECTOR ML KIT
  // ============================================================

  Future<String> _obtenerTexto(File archivo) async {
    if (_cerrado) {
      throw StateError('El servicio OCR ya fue cerrado.');
    }

    final inputImage = InputImage.fromFile(archivo);

    final resultado = await _recognizer.processImage(inputImage);

    return resultado.text.trim();
  }

  // ============================================================
  // EXTRAER CÉDULA
  // ============================================================

  String _extraerCedula(String texto) {
    final textoMayus = texto.toUpperCase();

    // ----------------------------------------------------------
    // 1. Buscar después de CC / C.C. / CÉDULA / DOCUMENTO
    // ----------------------------------------------------------

    final patronesDirectos = [
      RegExp(
        r'(?:CC|C\.C\.|CEDULA|CÉDULA|DOCUMENTO|DOCUMENTO DE IDENTIDAD)'
        r'\s*(?:N[Oº°.]*)?\s*[:\-]?\s*'
        r'([0-9][0-9.\-\s]{5,20}[0-9])',
        caseSensitive: false,
      ),
    ];

    for (final patron in patronesDirectos) {
      final match = patron.firstMatch(textoMayus);

      if (match != null) {
        final valor = match.group(1) ?? '';

        final numeros = valor.replaceAll(RegExp(r'\D'), '');

        if (numeros.length >= 6 && numeros.length <= 12) {
          return numeros;
        }
      }
    }

    // ----------------------------------------------------------
    // 2. Buscar números con puntos, guiones o espacios
    // ----------------------------------------------------------

    final patronNumeros = RegExp(
      r'\b\d[\d.\-\s]{5,20}\d\b',
    );

    for (final match in patronNumeros.allMatches(textoMayus)) {
      final valor = match.group(0) ?? '';

      final numeros = valor.replaceAll(RegExp(r'\D'), '');

      if (numeros.length >= 7 && numeros.length <= 12) {
        return numeros;
      }
    }

    // ----------------------------------------------------------
    // 3. Buscar números continuos
    // ----------------------------------------------------------

    final patronContinuo = RegExp(r'\b\d{7,12}\b');

    for (final match in patronContinuo.allMatches(textoMayus)) {
      final numeros = match.group(0) ?? '';

      if (numeros.length >= 7 && numeros.length <= 12) {
        return numeros;
      }
    }

    // ----------------------------------------------------------
    // 4. Intentar corregir errores comunes del OCR
    // ----------------------------------------------------------

    final corregido = textoMayus
        .replaceAll('O', '0')
        .replaceAll('I', '1')
        .replaceAll('L', '1')
        .replaceAll('S', '5')
        .replaceAll('B', '8');

    final patronCorregido = RegExp(
      r'\b\d[\d.\-\s]{5,20}\d\b',
    );

    for (final match in patronCorregido.allMatches(corregido)) {
      final valor = match.group(0) ?? '';

      final numeros = valor.replaceAll(RegExp(r'\D'), '');

      if (numeros.length >= 7 && numeros.length <= 12) {
        return numeros;
      }
    }

    return '';
  }

  // ============================================================
  // EXTRAER NOMBRE COMPLETO
  // ============================================================

  String _extraerNombreCompleto(String texto) {
    final lineas = texto
        .split('\n')
        .map(_limpiarLinea)
        .where((linea) => linea.isNotEmpty)
        .toList();

    String nombres = '';
    String apellidos = '';

    // ----------------------------------------------------------
    // Buscar NOMBRES
    // ----------------------------------------------------------

    for (var i = 0; i < lineas.length; i++) {
      final linea = lineas[i].toUpperCase();

      if (linea.startsWith('NOMBRES')) {
        final valor = lineas[i]
            .substring('NOMBRES'.length)
            .replaceFirst(RegExp(r'^[:\-\s]+'), '')
            .trim();

        if (_esNombreValido(valor)) {
          nombres = valor;
        } else if (i + 1 < lineas.length && _esNombreValido(lineas[i + 1])) {
          nombres = lineas[i + 1];
        }
      }
    }

    // ----------------------------------------------------------
    // Buscar APELLIDOS
    // ----------------------------------------------------------

    for (var i = 0; i < lineas.length; i++) {
      final linea = lineas[i].toUpperCase();

      if (linea.startsWith('APELLIDOS')) {
        final valor = lineas[i]
            .substring('APELLIDOS'.length)
            .replaceFirst(RegExp(r'^[:\-\s]+'), '')
            .trim();

        if (_esNombreValido(valor)) {
          apellidos = valor;
        } else if (i + 1 < lineas.length && _esNombreValido(lineas[i + 1])) {
          apellidos = lineas[i + 1];
        }
      }
    }

    // ----------------------------------------------------------
    // Si encontramos ambos, unirlos
    // ----------------------------------------------------------

    if (nombres.isNotEmpty && apellidos.isNotEmpty) {
      return '$nombres $apellidos'.trim();
    }

    // ----------------------------------------------------------
    // Si solo encontramos NOMBRES, buscar otra línea válida
    // que pueda corresponder a los apellidos.
    // ----------------------------------------------------------

    if (nombres.isNotEmpty) {
      final candidatos = lineas.where((linea) {
        if (!_esNombreValido(linea)) return false;

        final mayus = linea.toUpperCase();

        if (mayus.contains('NOMBRES')) return false;
        if (mayus.contains('APELLIDOS')) return false;
        if (mayus.contains('CEDULA')) return false;
        if (mayus.contains('DOCUMENTO')) return false;
        if (mayus.contains('IDENTIDAD')) return false;

        return true;
      }).toList();

      for (final candidato in candidatos) {
        if (candidato.toUpperCase() != nombres.toUpperCase()) {
          return '$nombres $candidato'.trim();
        }
      }

      return nombres;
    }

    // ----------------------------------------------------------
    // Si no encontró etiquetas, analizar candidatos
    // ----------------------------------------------------------

    final candidatos = lineas.where((linea) {
      return _esNombreValido(linea);
    }).toList();

    // El OCR puede separar:
    //
    // JUAN
    // CARLOS
    // PEREZ
    // GOMEZ
    //
    // Por eso intentamos unir hasta 4 líneas consecutivas.
    if (candidatos.isNotEmpty) {
      final resultado = _buscarNombrePorBloque(lineas);

      if (resultado.isNotEmpty) {
        return resultado;
      }

      return candidatos.first;
    }

    return '';
  }

  // ============================================================
  // BUSCAR BLOQUE DE NOMBRE
  // ============================================================

  String _buscarNombrePorBloque(List<String> lineas) {
    for (var i = 0; i < lineas.length; i++) {
      if (!_esNombreValido(lineas[i])) {
        continue;
      }

      final bloque = <String>[lineas[i]];

      for (var j = i + 1; j < lineas.length && bloque.length < 4; j++) {
        if (_esNombreValido(lineas[j])) {
          bloque.add(lineas[j]);
        } else {
          break;
        }
      }

      if (bloque.length >= 2) {
        final combinado = bloque.join(' ').trim();

        if (_esNombreValido(combinado)) {
          return combinado;
        }
      }
    }

    return '';
  }

  // ============================================================
  // VALIDAR NOMBRE
  // ============================================================

  bool _esNombreValido(String valor) {
    final limpio = valor
        .replaceAll(
          RegExp(r'[^A-Za-zÁÉÍÓÚÜÑáéíóúüñ\s]'),
          ' ',
        )
        .replaceAll(RegExp(r'\s+'), ' ')
        .trim();

    if (limpio.isEmpty) return false;

    final palabras = limpio.split(' ');

    if (palabras.isEmpty) return false;
    if (palabras.length > 8) return false;

    // No aceptar líneas demasiado largas que probablemente
    // sean texto de instrucciones de la cédula.
    if (limpio.length > 70) return false;

    for (final palabra in palabras) {
      if (palabra.length < 2) return false;
    }

    // Evitar palabras que claramente NO son nombres.
    final prohibidas = [
      'REPUBLICA',
      'COLOMBIA',
      'IDENTIDAD',
      'DOCUMENTO',
      'CEDULA',
      'CIUDADANIA',
      'FECHA',
      'NACIMIENTO',
      'EXPEDICION',
      'EXPEDICION',
      'ESTATURA',
      'SEXO',
      'LUGAR',
      'APELLIDOS',
      'NOMBRES',
      'COLOMBIANO',
      'COLOMBIANA',
    ];

    final mayus = limpio.toUpperCase();

    for (final palabra in prohibidas) {
      if (mayus == palabra) {
        return false;
      }
    }

    return true;
  }

  // ============================================================
  // FECHA DE NACIMIENTO
  // ============================================================

  String _extraerFechaNacimiento(String texto) {
    return _extraerDespuesDeEtiquetas(
      texto,
      [
        'FECHA DE NACIMIENTO',
        'FECHA NACIMIENTO',
        'FECHA NAC',
        'NACIMIENTO',
      ],
      buscarFecha: true,
    );
  }

  // ============================================================
  // FECHA EXPEDICIÓN
  // ============================================================

  String _extraerFechaExpedicion(String texto) {
    return _extraerDespuesDeEtiquetas(
      texto,
      [
        'FECHA DE EXPEDICION',
        'FECHA EXPEDICION',
        'FECHA EXP',
        'EXPEDICION',
        'EXPEDIDA',
      ],
      buscarFecha: true,
    );
  }

  // ============================================================
  // LUGAR NACIMIENTO
  // ============================================================

  String _extraerLugarNacimiento(String texto) {
    return _extraerDespuesDeEtiquetas(
      texto,
      [
        'LUGAR DE NACIMIENTO',
        'LUGAR NACIMIENTO',
      ],
    );
  }

  // ============================================================
  // LUGAR EXPEDICIÓN
  // ============================================================

  String _extraerLugarExpedicion(String texto) {
    return _extraerDespuesDeEtiquetas(
      texto,
      [
        'LUGAR DE EXPEDICION',
        'LUGAR EXPEDICION',
      ],
    );
  }

  // ============================================================
  // EXTRAER DATOS DESPUÉS DE ETIQUETAS
  // ============================================================

  String _extraerDespuesDeEtiquetas(
    String texto,
    List<String> etiquetas, {
    bool buscarFecha = false,
  }) {
    final lineas = texto
        .split('\n')
        .map(_limpiarLinea)
        .where((linea) => linea.isNotEmpty)
        .toList();

    for (var i = 0; i < lineas.length; i++) {
      final actual = lineas[i].toUpperCase();

      for (final etiqueta in etiquetas) {
        if (actual.contains(etiqueta)) {
          final mismaLinea = lineas[i]
              .replaceFirst(
                RegExp(
                  RegExp.escape(etiqueta),
                  caseSensitive: false,
                ),
                '',
              )
              .replaceFirst(
                RegExp(r'^[:\-\s]+'),
                '',
              )
              .trim();

          if (buscarFecha) {
            final fecha = _buscarFecha(mismaLinea);

            if (fecha.isNotEmpty) {
              return fecha;
            }
          } else {
            if (_esLugarValido(mismaLinea)) {
              return mismaLinea;
            }
          }

          if (i + 1 < lineas.length) {
            final siguiente = lineas[i + 1];

            if (buscarFecha) {
              final fecha = _buscarFecha(siguiente);

              if (fecha.isNotEmpty) {
                return fecha;
              }
            } else if (_esLugarValido(siguiente)) {
              return siguiente;
            }
          }
        }
      }
    }

    return '';
  }

  // ============================================================
  // BUSCAR FECHA
  // ============================================================

  String _buscarFecha(String texto) {
    final patrones = [
      RegExp(r'\b\d{1,2}[\/\-]\d{1,2}[\/\-]\d{2,4}\b'),
      RegExp(
        r'\b\d{1,2}\s+[A-ZÁÉÍÓÚÑ]{3,12}\s+\d{4}\b',
        caseSensitive: false,
      ),
    ];

    for (final patron in patrones) {
      final match = patron.firstMatch(texto);

      if (match != null) {
        return match.group(0)!.trim();
      }
    }

    return '';
  }

  // ============================================================
  // ESTATURA
  // ============================================================

  String _extraerEstatura(String texto) {
    final patrones = [
      RegExp(
        r'(?:ESTATURA|ALTURA)\s*[:\-]?\s*(\d[.,]\d{2})',
        caseSensitive: false,
      ),
      RegExp(
        r'\b(1[.,]\d{2})\s*(?:M|MT|MTS)?\b',
        caseSensitive: false,
      ),
    ];

    for (final patron in patrones) {
      final match = patron.firstMatch(texto);

      if (match != null) {
        return match.group(1)!.replaceAll(',', '.');
      }
    }

    return '';
  }

  // ============================================================
  // RH
  // ============================================================

  String _extraerRh(String texto) {
    final patron = RegExp(
      r'(?:RH|TIPO\s+DE\s+SANGRE)\s*[:\-]?\s*([OAB][+-])',
      caseSensitive: false,
    );

    final match = patron.firstMatch(texto);

    if (match != null) {
      return match.group(1)!.toUpperCase();
    }

    return '';
  }

  // ============================================================
  // SEXO
  // ============================================================

  String _extraerSexo(String texto) {
    final patron = RegExp(
      r'(?:SEXO)\s*[:\-]?\s*([MF])\b',
      caseSensitive: false,
    );

    final match = patron.firstMatch(texto);

    if (match != null) {
      return match.group(1)!.toUpperCase();
    }

    final textoMayus = texto.toUpperCase();

    if (RegExp(r'\bFEMENINO\b').hasMatch(textoMayus)) {
      return 'F';
    }

    if (RegExp(r'\bMASCULINO\b').hasMatch(textoMayus)) {
      return 'M';
    }

    return '';
  }

  // ============================================================
  // VALIDAR LUGAR
  // ============================================================

  bool _esLugarValido(String texto) {
    if (texto.trim().isEmpty) return false;

    final limpio = texto.trim();

    if (limpio.length < 3) return false;

    if (RegExp(r'^\d+$').hasMatch(limpio)) {
      return false;
    }

    if (_buscarFecha(limpio).isNotEmpty) {
      return false;
    }

    return RegExp(
      r'[A-Za-zÁÉÍÓÚÜÑáéíóúüñ]',
    ).hasMatch(limpio);
  }

  // ============================================================
  // CONFIANZA FRENTE
  // ============================================================

  double _calcularConfianzaFrente({
    required String cc,
    required String nombre,
  }) {
    var puntos = 0;

    if (cc.isNotEmpty) {
      puntos += 50;
    }

    if (nombre.isNotEmpty) {
      puntos += 50;
    }

    return puntos / 100;
  }

  // ============================================================
  // CONFIANZA REVERSO
  // ============================================================

  double _calcularConfianzaReverso({
    required String fechaNac,
    required String lugarNac,
    required String estatura,
    required String rh,
    required String sexo,
    required String fechaExp,
    required String lugarExp,
  }) {
    var encontrados = 0;

    if (fechaNac.isNotEmpty) encontrados++;
    if (lugarNac.isNotEmpty) encontrados++;
    if (estatura.isNotEmpty) encontrados++;
    if (rh.isNotEmpty) encontrados++;
    if (sexo.isNotEmpty) encontrados++;
    if (fechaExp.isNotEmpty) encontrados++;
    if (lugarExp.isNotEmpty) encontrados++;

    return encontrados / 7;
  }

  // ============================================================
  // NORMALIZAR TEXTO
  // ============================================================

  String _normalizar(String texto) {
    return texto
        .replaceAll('\r', '\n')
        .replaceAll(RegExp(r'[ \t]+'), ' ')
        .replaceAll(RegExp(r'\n+'), '\n')
        .trim();
  }

  // ============================================================
  // LIMPIAR LÍNEA
  // ============================================================

  String _limpiarLinea(String linea) {
    return linea.replaceAll(RegExp(r'\s+'), ' ').trim();
  }

  // ============================================================
  // VALIDAR ARCHIVO
  // ============================================================

  void _validarArchivo(File archivo) {
    if (!archivo.existsSync()) {
      throw Exception(
        'No se encontró la imagen seleccionada.',
      );
    }
  }

  // ============================================================
  // CERRAR OCR
  // ============================================================

  Future<void> dispose() async {
    if (_cerrado) return;

    _cerrado = true;

    await _recognizer.close();
  }
}
