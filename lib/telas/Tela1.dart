import 'package:flutter/material.dart';
import 'package:testetcc2/telas/telaListaEstendida.dart';
import 'package:testetcc2/telas/telaDetalhesLivro.dart';
import 'package:testetcc2/models/classes/livro.dart';
import 'package:testetcc2/controller/api_client.dart';

class Tela1 extends StatefulWidget {
  @override
  _Tela1State createState() => _Tela1State();
}

class _Tela1State extends State<Tela1> {
  List<Livro> livrosReais = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarLivrosDaApi();
  }

  Future<void> _carregarLivrosDaApi() async {
    try {
      final dio = await ApiClient.getInstance();
      final response = await dio.get('/livros');

      if (response.statusCode == 200) {
        List<dynamic> dados = response.data;

        setState(() {
          livrosReais = dados.map((json) => Livro(
            id: json['id'].toString(),
            titulo: json['name'] ?? 'Sem Título',
            autor: json['autor'] ?? 'Autor Desconhecido',
            urlCapa: json['capa_path'] ?? '',
            urlPdf: json['pdf_path'] ?? '',
            descricao: json['sinopse'] ?? 'Sem descrição.',
            genero: json['genero1'] ?? 'Outros',
          )).toList();

          isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao buscar livros: $e');
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Livro> _livrosPorGenero(String genero) {
    if (genero.toLowerCase() == 'favoritos') {
      return livrosReais.where((l) => l.favorito).toList();
    }
    return livrosReais.where((l) => l.genero.toLowerCase() == genero.toLowerCase()).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _carregarLivrosDaApi,
        child: ListView(
          children: [
            secaoGenero("Ação e Aventura"),
            secaoGenero("Biografia"),
            secaoGenero("Chick-Lit"),
            secaoGenero("Clássicos"),
            secaoGenero("Conto"),
            secaoGenero("Crônica"),
            secaoGenero("Distopia"),
            secaoGenero("Drama"),
            secaoGenero("Ensaio"),
            secaoGenero("Fantasia"),
            secaoGenero("Ficção Científica"),
            secaoGenero("Ficção Histórica"),
            secaoGenero("Ficção Policial"),
            secaoGenero("Horror/Terror"),
            secaoGenero("Infanto-juvenil"),
            secaoGenero("Mistério"),
            secaoGenero("Não Ficção"),
            secaoGenero("Novela"),
            secaoGenero("Poesia"),
            secaoGenero("Realismo Mágico"),
            secaoGenero("Religião e Espiritualidade"),
            secaoGenero("Romance"),
            secaoGenero("Suspense/Thriller"),
            secaoGenero("Tragédia"),
            secaoGenero("Young Adult (YA)"),
          ],
        ),
      ),
    );
  }

  Widget secaoGenero(String titulo) {
    final livros = _livrosPorGenero(titulo);

    if (livros.isEmpty) return SizedBox.shrink();

    return Card(
      margin: EdgeInsets.all(10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(titulo, style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                TextButton(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TelaListaEstendida(tituloGenero: titulo),
                      ),
                    );
                  },
                  child: Text(
                    "Estender lista",
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ],
            ),
            SizedBox(height: 10),
            SizedBox(
              height: 180,
              child: ListView(
                scrollDirection: Axis.horizontal,
                children: livros.map((livro) => testeLivro(livro)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget testeLivro(Livro livro) {
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TelaDetalhesLivro(livro: livro),
          ),
        );
      },
      child: Container(
        width: 120,
        margin: EdgeInsets.only(right: 10),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(8),
          image: livro.urlCapa.isNotEmpty
              ? DecorationImage(
            image: NetworkImage(livro.urlCapa),
            fit: BoxFit.cover,
          )
              : null,
        ),
        child: livro.urlCapa.isEmpty
            ? Center(
          child: Text(
            livro.titulo,
            textAlign: TextAlign.center,
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
        )
            : null,
      ),
    );
  }
}