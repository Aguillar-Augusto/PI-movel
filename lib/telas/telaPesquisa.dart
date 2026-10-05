import 'package:flutter/material.dart';
import 'package:testetcc2/telas/telaDetalhesLivro.dart';
import 'package:testetcc2/models/classes/livro.dart';
import 'package:testetcc2/controller/api_client.dart';

class TelaPesquisa extends StatefulWidget {
  @override
  _TelaPesquisaState createState() => _TelaPesquisaState();
}

class _TelaPesquisaState extends State<TelaPesquisa> {
  List<Livro> _todosOsLivros = [];
  List<Livro> _resultados = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarLivros();
  }

  Future<void> _carregarLivros() async {
    try {
      final dio = await ApiClient.getInstance();
      final response = await dio.get('/livros');

      if (response.statusCode == 200) {
        List<dynamic> dados = response.data;

        setState(() {
          _todosOsLivros = dados.map((json) => Livro(
            id: json['id'].toString(),
            titulo: json['name'] ?? 'Sem Título',
            autor: json['autor'] ?? 'Autor Desconhecido',
            urlCapa: json['capa_path'] ?? '',
            urlPdf: json['pdf_path'] ?? '',
            descricao: json['sinopse'] ?? 'Sem descrição.',
            genero: json['genero1'] ?? 'Outros',
          )).toList();

          _resultados = _todosOsLivros;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar livros para pesquisa: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _pesquisar(String termo) {
    setState(() {
      if (termo.trim().isEmpty) {
        _resultados = _todosOsLivros;
      } else {
        final texto = termo.toLowerCase();
        _resultados = _todosOsLivros.where((livro) {
          return livro.titulo.toLowerCase().contains(texto) ||
              livro.autor.toLowerCase().contains(texto);
        }).toList();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pesquisa"),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Column(
        children: [
          Padding(
            padding: EdgeInsets.all(10.0),
            child: TextField(
              onChanged: _pesquisar,
              decoration: InputDecoration(
                hintText: "Digite para pesquisar...",
                filled: true,
                fillColor: Color(0xFFD9EAD3),
                contentPadding: EdgeInsets.symmetric(horizontal: 20.0, vertical: 15.0),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30.0),
                  borderSide: BorderSide.none,
                ),
                prefixIcon: Icon(Icons.search, color: Colors.grey),
              ),
            ),
          ),
          Expanded(
            child: _resultados.isEmpty
                ? Center(child: Text("Nenhum livro encontrado."))
                : ListView.builder(
              itemCount: _resultados.length,
              itemBuilder: (context, index) {
                final livro = _resultados[index];
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
          ),
        ],
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