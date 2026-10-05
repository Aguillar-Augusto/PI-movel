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
  bool _hasError = false;
  late PDFDocument document;

  @override
  void initState() {
    super.initState();
    loadDocument();
  }

  loadDocument() async {
    try {
      String urlLimpa = widget.urlDocumento.replaceAll(RegExp(r'fl_attachment:[^/]+/'), '');

      document = await PDFDocument.fromURL(urlLimpa);

      setState(() {
        _isLoading = false;
        _hasError = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _hasError = true;
      });
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
            : _hasError
            ? Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.warning_amber_rounded, size: 80, color: Colors.orange),
            SizedBox(height: 16),
            Text("Erro no leitor de PDF", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            Text("O documento não pôde ser carregado.", style: TextStyle(color: Colors.grey)),
          ],
        )
            : PDFViewer(
          document: document,
          zoomSteps: 1,
        ),
      ),
    );
  }
}