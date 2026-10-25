import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

/// Tela de leitura de PDF via WebView (baseada no modelo CustomWebView / InAppWebView).
/// Mantém a assinatura exata esperada por TelaDetalhesLivro (urlDocumento e titulo).
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
  String errorMessage = '';
  late final String urlParaCarregar;

  @override
  void initState() {
    super.initState();
    urlParaCarregar = _montarUrlVisualizacao(widget.urlDocumento);
  }

  /// Remove a flag 'fl_attachment' do Cloudinary (que forçaria download)
  /// e, no Android, encapsula a URL no visualizador embutido do Google Docs
  /// pois o WebView nativo do Android não renderiza arquivos .pdf diretamente.
  String _montarUrlVisualizacao(String urlOriginal) {
    final String urlLimpa = urlOriginal
        .trim()
        .replaceAll(RegExp(r'fl_attachment:[^/]+/'), '');

    if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
      return 'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(urlLimpa)}';
    }

    return urlLimpa;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.titulo),
        actions: [
          IconButton(
            tooltip: 'Recarregar PDF',
            icon: const Icon(Icons.refresh),
            onPressed: () {
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
        child: Stack(
          children: [
            // 1. WebView para exibição do PDF
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(urlParaCarregar)),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                transparentBackground: true,
                supportZoom: true,
                builtInZoomControls: true,
                displayZoomControls: false,
                useWideViewPort: true,
                loadWithOverviewMode: true,
              ),
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              onLoadStart: (controller, url) {
                if (!mounted) return;
                setState(() {
                  isLoading = true;
                  hasError = false;
                });
              },
              onLoadStop: (controller, url) async {
                if (!mounted) return;
                setState(() {
                  isLoading = false;
                });
              },
              onProgressChanged: (controller, novoProgresso) {
                if (!mounted) return;
                setState(() {
                  progress = novoProgresso / 100;
                });
              },
              onReceivedError: (controller, request, error) {
                if (request.isForMainFrame != true || !mounted) return;
                setState(() {
                  isLoading = false;
                  hasError = true;
                  errorMessage = 'Falha na conexão: ${error.description}';
                });
              },
              onReceivedHttpError: (controller, request, errorResponse) {
                if (request.isForMainFrame != true || !mounted) return;
                setState(() {
                  isLoading = false;
                  hasError = true;
                  errorMessage =
                  'Erro do servidor (Status: ${errorResponse.statusCode})';
                });
              },
            ),

            // 2. Barra de progresso superior durante o carregamento
            if (isLoading && !hasError)
              Align(
                alignment: Alignment.topCenter,
                child: LinearProgressIndicator(
                  value: progress == 1.0 ? null : progress,
                  backgroundColor: Colors.grey[200],
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),

            // 3. Tela de Feedback de Erro com botão de nova tentativa
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
    );
  }
}

/* ============================================================================
 * ALTERNATIVA SIMPLIFICADA (Baseada no exemplo_webview.zip / SimpleWebView.dart)
 * Caso prefira usar o pacote oficial `webview_flutter: ^4.14.1` no pubspec.yaml:
 * ============================================================================
 *
 * import 'package:flutter/foundation.dart';
 * import 'package:flutter/material.dart';
 * import 'package:webview_flutter/webview_flutter.dart';
 *
 * class LeitorPDF extends StatefulWidget {
 *   final String urlDocumento;
 *   final String titulo;
 *
 *   const LeitorPDF({
 *     super.key,
 *     required this.urlDocumento,
 *     required this.titulo,
 *   });
 *
 *   @override
 *   State<LeitorPDF> createState() => _LeitorPDFState();
 * }
 *
 * class _LeitorPDFState extends State<LeitorPDF> {
 *   late final WebViewController _controller;
 *   bool _isLoading = true;
 *
 *   String _montarUrlVisualizacao(String urlOriginal) {
 *     final String urlLimpa = urlOriginal
 *         .trim()
 *         .replaceAll(RegExp(r'fl_attachment:[^/]+/'), '');
 *     if (!kIsWeb && defaultTargetPlatform == TargetPlatform.android) {
 *       return 'https://docs.google.com/gview?embedded=true&url=${Uri.encodeComponent(urlLimpa)}';
 *     }
 *     return urlLimpa;
 *   }
 *
 *   @override
 *   void initState() {
 *     super.initState();
 *     final urlFinal = _montarUrlVisualizacao(widget.urlDocumento);
 *
 *     _controller = WebViewController()
 *       ..setJavaScriptMode(JavaScriptMode.unrestricted)
 *       ..setNavigationDelegate(
 *         NavigationDelegate(
 *           onPageStarted: (String url) {
 *             if (!mounted) return;
 *             setState(() => _isLoading = true);
 *           },
 *           onPageFinished: (String url) {
 *             if (!mounted) return;
 *             setState(() => _isLoading = false);
 *           },
 *           onWebResourceError: (WebResourceError error) {
 *             if (!mounted) return;
 *             ScaffoldMessenger.of(context).showSnackBar(
 *               SnackBar(content: Text('Erro ao carregar PDF: ${error.description}')),
 *             );
 *           },
 *         ),
 *       )
 *       ..loadRequest(Uri.parse(urlFinal));
 *   }
 *
 *   @override
 *   Widget build(BuildContext context) {
 *     return Scaffold(
 *       appBar: AppBar(
 *         title: Text(widget.titulo),
 *         actions: [
 *           IconButton(
 *             icon: const Icon(Icons.refresh),
 *             onPressed: () => _controller.reload(),
 *           ),
 *         ],
 *       ),
 *       body: Stack(
 *         children: [
 *           WebViewWidget(controller: _controller),
 *           if (_isLoading)
 *             const Center(child: CircularProgressIndicator()),
 *         ],
 *       ),
 *     );
 *   }
 * }
 */