import 'package:flutter/material.dart';
import 'package:testetcc2/models/classes/livro.dart';
import 'package:testetcc2/controller/api_client.dart';
import 'package:testetcc2/controller/autorizacao_controller.dart';
import 'package:dio/dio.dart';
import 'package:testetcc2/telas/LeitorPDF.dart';

class TelaDetalhesLivro extends StatefulWidget {
  final Livro livro;

  TelaDetalhesLivro({required this.livro});

  @override
  _TelaDetalhesLivroState createState() => _TelaDetalhesLivroState();
}

class _TelaDetalhesLivroState extends State<TelaDetalhesLivro> {
  bool _isProcessandoFavorito = false;
  bool _isLoadingStatusInicial = false;
  bool _alterouFavorito = false;
  late bool _isFavorito;

  @override
  void initState() {
    super.initState();
    _isFavorito = widget.livro.favorito;
    _verificarFavorito();
  }

  Future<void> _verificarFavorito() async {
    final temSessao = await AutorizacaoController.verificaAutorizacaoOffline();
    if (!temSessao || !mounted) return;

    setState(() {
      _isLoadingStatusInicial = true;
    });

    try {
      final dio = await ApiClient.getInstance();
      final response = await dio.get('/livros/${widget.livro.id}/check-favorito');

      if (!mounted) return;
      if (response.statusCode == 200) {
        setState(() {
          _isFavorito = response.data['favorito'] == true;
        });
      }
    } catch (_) {
    } finally {
      if (mounted) {
        setState(() {
          _isLoadingStatusInicial = false;
        });
      }
    }
  }

  Future<void> _toggleFavorito() async {
    final temSessao = await AutorizacaoController.verificaAutorizacaoOffline();

    if (!temSessao) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Precisa iniciar sessão para favoritar livros.")),
      );
      return;
    }

    setState(() {
      _isProcessandoFavorito = true;
    });

    try {
      final dio = await ApiClient.getInstance();
      final response = await dio.post('/livros/${widget.livro.id}/favoritar');

      if (!mounted) return;

      if (response.statusCode == 200) {
        setState(() {
          _isFavorito = response.data is Map && response.data.containsKey('favorito')
              ? response.data['favorito'] == true
              : !_isFavorito;
          _alterouFavorito = true;
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_isFavorito
                ? "${widget.livro.titulo} adicionado aos favoritos!"
                : "${widget.livro.titulo} removido dos favoritos!"),
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Erro ao atualizar favoritos. Tente novamente.")),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isProcessandoFavorito = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Descrição do Livro")),
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 30),
            Center(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: widget.livro.urlCapa.isNotEmpty
                    ? Image.network(
                  widget.livro.urlCapa,
                  width: 160,
                  height: 240,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => _capaPlaceholder(context),
                )
                    : _capaPlaceholder(context),
              ),
            ),
            SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                widget.livro.titulo,
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text(
                widget.livro.autor,
                style: TextStyle(fontSize: 16, color: Colors.black54, fontStyle: FontStyle.italic),
              ),
            ),

            SizedBox(height: 15),
            Wrap(
              spacing: 8.0,
              runSpacing: 8.0,
              alignment: WrapAlignment.center,
              children: [
                _buildGeneroChip(widget.livro.genero, context),
                _buildGeneroChip(widget.livro.generoSecundario, context),
              ],
            ),

            Padding(
              padding: EdgeInsets.all(25),
              child: Text(
                widget.livro.descricao,
                textAlign: TextAlign.justify,
                style: TextStyle(fontSize: 16, color: Colors.black87),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: () {
                    if (widget.livro.urlPdf.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text("O arquivo PDF deste livro não está disponível.")),
                      );
                      return;
                    }

                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LeitorPDF(
                          urlDocumento: widget.livro.urlPdf,
                          titulo: widget.livro.titulo,
                        ),
                      ),
                    );
                  },
                  icon: Icon(Icons.menu_book),
                  label: Text("Ler Livro"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
                SizedBox(width: 15),
                OutlinedButton.icon(
                  onPressed: (_isProcessandoFavorito || _isLoadingStatusInicial) ? null : _toggleFavorito,
                  icon: (_isProcessandoFavorito || _isLoadingStatusInicial)
                      ? SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2))
                      : Icon(_isFavorito ? Icons.favorite : Icons.favorite_border,
                      color: _isFavorito ? Colors.red : null),
                  label: Text(_isFavorito ? "Favorito" : "Favoritar"),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: _isFavorito ? Colors.red : Colors.grey),
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                ),
              ],
            ),
            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildGeneroChip(String genero, BuildContext context) {
    if (genero.trim().isEmpty) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primary,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        genero,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 14,
        ),
      ),
    );
  }

  Widget _capaPlaceholder(BuildContext context) {
    return Container(
      width: 160,
      height: 240,
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.primaryContainer,
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 8, offset: Offset(0, 4))
        ],
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            widget.livro.titulo,
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
        ),
      ),
    );
  }
}