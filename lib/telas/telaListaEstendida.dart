import 'package:flutter/material.dart';
import 'package:testetcc2/telas/telaDetalhesLivro.dart';
import 'package:testetcc2/models/classes/livro.dart';
import 'package:testetcc2/controller/api_client.dart';

class TelaListaEstendida extends StatefulWidget {
  final String tituloGenero;

  const TelaListaEstendida({super.key, required this.tituloGenero});

  @override
  _TelaListaEstendidaState createState() => _TelaListaEstendidaState();
}

class _TelaListaEstendidaState extends State<TelaListaEstendida> {
  List<Livro> _livros = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarLivrosDoGenero();
  }

  Future<void> _carregarLivrosDoGenero() async {
    try {
      final dio = await ApiClient.getInstance();
      final categoria = widget.tituloGenero.trim().toLowerCase();

      if (categoria == 'favoritos') {
        final response = await dio.get('/user/favoritos');
        if (!mounted) return;
        if (response.statusCode == 200) {
          final List<dynamic> dados = response.data;
          setState(() {
            _livros = dados
                .map((json) => Livro.fromMap(json as Map<String, dynamic>, favoritoForcado: true))
                .toList();
            _isLoading = false;
          });
        }
      } else if (categoria == 'meus livros') {
        final response = await dio.get('/user/meus-livros');
        if (!mounted) return;
        if (response.statusCode == 200) {
          final List<dynamic> dados = response.data;
          setState(() {
            _livros = dados
                .map((json) => Livro.fromMap(json as Map<String, dynamic>))
                .toList();
            _isLoading = false;
          });
        }
      } else {
        final response = await dio.get(
          '/livros',
          queryParameters: {'genero': widget.tituloGenero},
        );
        if (!mounted) return;
        if (response.statusCode == 200) {
          final List<dynamic> dados = response.data;
          final todosOsLivros = dados
              .map((json) => Livro.fromMap(json as Map<String, dynamic>))
              .toList();

          setState(() {
            _livros = todosOsLivros
                .where((l) => l.pertenceAoGenero(widget.tituloGenero))
                .toList();
            _isLoading = false;
          });
        }
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.tituloGenero),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _livros.isEmpty
          ? const Center(child: Text("Nenhum livro encontrado nesta categoria."))
          : RefreshIndicator(
        onRefresh: _carregarLivrosDoGenero,
        child: ListView.builder(
          itemCount: _livros.length,
          itemBuilder: (context, index) {
            final livro = _livros[index];
            return ListTile(
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: livro.urlCapa.isNotEmpty
                    ? Image.network(
                  livro.urlCapa,
                  width: 50,
                  height: 70,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _capaPlaceholder(context),
                )
                    : _capaPlaceholder(context),
              ),
              title: Text(livro.titulo),
              subtitle: Text(livro.autor),
              trailing: const Icon(Icons.arrow_forward_ios, size: 16),
              onTap: () async {
                final alterouFavorito = await Navigator.push<bool>(
                  context,
                  MaterialPageRoute(
                    builder: (context) => TelaDetalhesLivro(livro: livro),
                  ),
                );
                if (alterouFavorito == true && mounted) {
                  _carregarLivrosDoGenero();
                }
              },
            );
          },
        ),
      ),
    );
  }

  Widget _capaPlaceholder(BuildContext context) {
    return Container(
      width: 50,
      height: 70,
      color: Theme.of(context).colorScheme.secondaryContainer,
      child: Center(
        child: Icon(Icons.book, color: Theme.of(context).colorScheme.primary),
      ),
    );
  }
}