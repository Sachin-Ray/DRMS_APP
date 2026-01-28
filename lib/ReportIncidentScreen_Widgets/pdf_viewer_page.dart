import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_pdfviewer/pdfviewer.dart';

class PdfViewerPage extends StatelessWidget {
  final Uint8List bytes;
  final String title;

  const PdfViewerPage.fromBytes({
    super.key,
    required this.bytes,
    required this.title,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(title)),
      body: SfPdfViewer.memory(bytes),
    );
  }
}
