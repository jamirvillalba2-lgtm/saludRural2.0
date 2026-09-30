import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class MedicoRegistroRethus extends StatefulWidget {
  const MedicoRegistroRethus({super.key});
  @override
  State<MedicoRegistroRethus> createState() => _MedicoRegistroRethusState();
}

class _MedicoRegistroRethusState extends State<MedicoRegistroRethus> {
  File? imagen;
  final nombreCtrl = TextEditingController();
  final rethusCtrl = TextEditingController();
  double confianza = 0;
  bool loading = false;
  String textoLeido = "";

  Future<void> tomarFoto() async {
    final foto = await ImagePicker()
        .pickImage(source: ImageSource.camera, imageQuality: 85);
    if (foto == null) return;
    setState(() {
      loading = true;
      imagen = File(foto.path);
    });

    final input = InputImage.fromFilePath(foto.path);
    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    final res = await recognizer.processImage(input);
    await recognizer.close();

    String raw = res.text.toUpperCase();
    textoLeido = res.text;
    double conf = 0;
    if (raw.contains("MEDICO") || raw.contains("MEDICINA")) conf += 30;
    if (raw.contains("RETHUS") || raw.contains("TARJETA")) conf += 30;
    if (raw.contains("UNIVERSIDAD") || raw.contains("COLEGIO")) conf += 20;
    if (raw.contains(RegExp(r'\d{5,}'))) conf += 20;

    final numMatch = RegExp(r'\b\d{5,10}\b').firstMatch(raw);
    if (numMatch != null) rethusCtrl.text = numMatch.group(0)!;

    setState(() {
      confianza = conf;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: const Text("Registro Médico - RETHUS"),
          backgroundColor: const Color(0xFF0D47A1),
          foregroundColor: Colors.white),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(children: [
          if (imagen != null)
            ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: Image.file(imagen!, height: 220)),
          const SizedBox(height: 12),
          SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                  onPressed: tomarFoto,
                  icon: const Icon(Icons.camera_alt),
                  label: const Text("Tomar foto tarjeta profesional"))),
          const SizedBox(height: 20),
          TextField(
              controller: nombreCtrl,
              decoration: const InputDecoration(
                  labelText: "Nombre completo", border: OutlineInputBorder())),
          const SizedBox(height: 12),
          TextField(
              controller: rethusCtrl,
              decoration: const InputDecoration(
                  labelText: "Número RETHUS / T.P.",
                  border: OutlineInputBorder())),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
                color: const Color(0xFFE3F2FD),
                borderRadius: BorderRadius.circular(12)),
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Row(children: [
                Icon(Icons.verified,
                    color: confianza > 70 ? Colors.green : Colors.orange),
                const SizedBox(width: 8),
                Text("${confianza.toInt()}% confianza RETHUS",
                    style: const TextStyle(fontWeight: FontWeight.bold))
              ]),
              if (textoLeido.isNotEmpty)
                Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child:
                        Text(textoLeido, style: const TextStyle(fontSize: 10))),
            ]),
          ),
          const SizedBox(height: 20),
          loading
              ? const CircularProgressIndicator()
              : SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
                            content:
                                Text("Médico ${nombreCtrl.text} validado")));
                      },
                      child: const Text("Validar con RETHUS"))),
        ]),
      ),
    );
  }
}
