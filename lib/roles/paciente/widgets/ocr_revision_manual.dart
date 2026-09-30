import 'package:flutter/material.dart';

class OcrRevisionManual extends StatelessWidget {
  final double confianza;
  final String texto;
  const OcrRevisionManual({
    super.key,
    required this.confianza,
    required this.texto,
  });
  @override
  Widget build(BuildContext context) {
    Color c = confianza > 0.85
        ? Colors.green
        : confianza > 0.6
        ? Colors.orange
        : Colors.red;
    return Card(
      child: ListTile(
        leading: Icon(Icons.badge, color: c),
        title: Text('${(confianza * 100).toStringAsFixed(0)}% confianza'),
        subtitle: Text(texto),
      ),
    );
  }
}
