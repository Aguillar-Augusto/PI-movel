import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class LeitorPDF extends StatefulWidget {
  final String urlDocumento;
  final String titulo;

  const LeitorPDF({
    super.key,
    required this.urlDocumento,
    required this.titulo,
  });

  @override
  State<LeitorPDF> createState() => _LeitorPDFState();
}

class _LeitorPDFState extends State<LeitorPDF> {
  InAppWebViewController? webViewController;

  double progress = 0;
  bool isLoading = true;
  bool hasError = false;
  bool _encerrandoWebView = false;
  String errorMessage = '';
  late final String urlParaCarregar;

  @override
  void initState() {
    super.initState();
    urlParaCarregar = _montarUrlVisualizacao(widget.urlDocumento);
  }

  String _montarUrlVisualizacao(String urlOriginal) {
    final String urlLimpa = urlOriginal
        .trim()
        .replaceAll(RegExp(r'fl_attachment:[^/]+/'), '');

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(urlLimpa)}';
    }

    return urlLimpa;
  }

  Future<void> _fecharLeitor() async {
    if (_encerrandoWebView) return;

    try {
      await webViewController?.stopLoading();
    } catch (_) {}

    if (!mounted) return;

    setState(() {
      _encerrandoWebView = true;
    });

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && Navigator.of(context).canPop()) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        _fecharLeitor();
      },
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Voltar',
            icon: const Icon(Icons.arrow_back),
            onPressed: _fecharLeitor,
          ),
          title: Text(widget.titulo),
          actions: [
            IconButton(
              tooltip: 'Recarregar PDF',
              icon: const Icon(Icons.refresh),
              onPressed: () {
                if (_encerrandoWebView) return;
                setState(() {
                  hasError = false;
                  isLoading = true;
                });
                webViewController?.loadUrl(
                  urlRequest: URLRequest(url: WebUri(urlParaCarregar)),
                );
              },
            ),
          ],
        ),
        body: SafeArea(
          child: _encerrandoWebView
              ? const Center(child: CircularProgressIndicator())
              : Stack(
            children: [
              InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri(urlParaCarregar)),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  supportZoom: true,
                ),
                onWebViewCreated: (controller) {
                  webViewController = controller;
                },
                onLoadStart: (controller, url) {
                  if (!mounted || _encerrandoWebView) return;
                  setState(() {
                    isLoading = true;
                    hasError = false;
                  });
                },
                onLoadStop: (controller, url) async {
                  if (!mounted || _encerrandoWebView) return;
                  setState(() {
                    isLoading = false;
                  });
                },
                onProgressChanged: (controller, novoProgresso) {
                  if (!mounted || _encerrandoWebView) return;
                  setState(() {
                    progress = novoProgresso / 100;
                  });
                },
                onReceivedError: (controller, request, error) {
                  if (request.isForMainFrame != true ||
                      !mounted ||
                      _encerrandoWebView) {
                    return;
                  }
                  setState(() {
                    isLoading = false;
                    hasError = true;
                    errorMessage = 'Falha na conexão: ${error.description}';
                  });
                },
                onReceivedHttpError: (controller, request, errorResponse) {
                  if (request.isForMainFrame != true ||
                      !mounted ||
                      _encerrandoWebView) {
                    return;
                  }
                  setState(() {
                    isLoading = false;
                    hasError = true;
                    errorMessage =
                    'Erro do servidor (Status: ${errorResponse.statusCode})';
                  });
                },
              ),

              if (isLoading && !hasError)
                Align(
                  alignment: Alignment.topCenter,
                  child: LinearProgressIndicator(
                    value: progress == 1.0 ? null : progress,
                    backgroundColor: Colors.grey[200],
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),

              if (hasError)
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const Icon(
                        Icons.warning_amber_rounded,
                        size: 80,
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        "Não foi possível carregar o PDF",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 32.0),
                        child: Text(
                          errorMessage,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.red),
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () {
                          setState(() {
                            hasError = false;
                            isLoading = true;
                          });
                          webViewController?.loadUrl(
                            urlRequest: URLRequest(url: WebUri(urlParaCarregar)),
                          );
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text("Tentar Novamente"),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}