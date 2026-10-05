import 'package:flutter/material.dart';
import 'package:advance_pdf_viewer2/advance_pdf_viewer.dart';

class LeitorPDF extends StatefulWidget {
  final String urlDocumento;
  final String titulo;

  LeitorPDF({required this.urlDocumento, required this.titulo});

  @override
  _LeitorPDFState createState() => _LeitorPDFState();
}

class _LeitorPDFState extends State<LeitorPDF> {
  bool _isLoading = true;
  late PDFDocument document;

  @override
  void initState() {
    super.initState();
    loadDocument();
  }

  loadDocument() async {
    try {
      document = await PDFDocument.fromURL(widget.urlDocumento);
      setState(() => _isLoading = false);
    } catch (e) {
      print('Erro ao carregar documento: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titulo),
      ),
      body: Center(
        child: _isLoading
            ? CircularProgressIndicator(color: Theme.of(context).colorScheme.primary)
            : PDFViewer(
          document: document,
          zoomSteps: 1,
        ),
      ),
    );
  }
}