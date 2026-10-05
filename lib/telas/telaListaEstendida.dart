import 'package:flutter/material.dart';
import 'package:testetcc2/telas/telaDetalhesLivro.dart';
import 'package:testetcc2/models/classes/livro.dart';
import 'package:testetcc2/controller/api_client.dart';

class TelaListaEstendida extends StatefulWidget {
  final String tituloGenero;

  TelaListaEstendida({required this.tituloGenero});

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

      final response = await dio.get('/livros');

      if (response.statusCode == 200) {
        List<dynamic> dados = response.data;

        List<Livro> todosOsLivros = dados.map((json) => Livro(
          id: json['id'].toString(),
          titulo: json['name'] ?? 'Sem Título',
          autor: json['autor'] ?? 'Autor Desconhecido',
          urlCapa: json['capa_path'] ?? '',
          descricao: json['sinopse'] ?? 'Sem descrição.',
          genero: json['genero1'] ?? 'Outros',
        )).toList();

        setState(() {
          if (widget.tituloGenero.toLowerCase() == 'favoritos') {
            _livros = todosOsLivros.where((l) => l.favorito).toList();
          } else {
            _livros = todosOsLivros.where((l) =>
            l.genero.toLowerCase() == widget.tituloGenero.toLowerCase()
            ).toList();
          }
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar lista estendida: $e');
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
          ? Center(child: CircularProgressIndicator())
          : _livros.isEmpty
          ? Center(child: Text("Nenhum livro encontrado nesta categoria."))
          : ListView.builder(
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
                errorBuilder: (context, error, stackTrace) => _capaPlaceholder(context),
              )
                  : _capaPlaceholder(context),
            ),
            title: Text(livro.titulo),
            subtitle: Text(livro.autor),
            trailing: Icon(Icons.arrow_forward_ios, size: 16),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TelaDetalhesLivro(livro: livro),
                ),
              );
            },
          );
        },
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