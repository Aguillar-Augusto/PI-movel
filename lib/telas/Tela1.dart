// lib/telas/Tela1.dart
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

      if (!mounted) return;

      if (response.statusCode == 200) {
        final List<dynamic> dados = response.data;

        setState(() {
          livrosReais = dados
              .map((json) => Livro.fromMap(json as Map<String, dynamic>))
              .toList();
          isLoading = false;
        });
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });
    }
  }

  List<Livro> _livrosPorGenero(String genero) {
    if (genero.toLowerCase() == 'favoritos') {
      return livrosReais.where((l) => l.favorito).toList();
    }
    return livrosReais.where((l) => l.pertenceAoGenero(genero)).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _carregarLivrosDaApi,
        child: ListView(
          children: Livro.generos.map((genero) => secaoGenero(genero)).toList(),
        ),
      ),
    );
  }

  Widget secaoGenero(String titulo) {
    final livros = _livrosPorGenero(titulo);

    if (livros.isEmpty) return const SizedBox.shrink();

    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 3,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      child: Padding(
        padding: const EdgeInsets.all(15),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    titulo,
                    style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () async {
                    await Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TelaListaEstendida(tituloGenero: titulo),
                      ),
                    );
                    if (mounted) _carregarLivrosDaApi();
                  },
                  child: Text(
                    "Estender lista",
                    style: TextStyle(color: Theme.of(context).colorScheme.primary),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
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
      onTap: () async {
        final alterouFavorito = await Navigator.push<bool>(
          context,
          MaterialPageRoute(
            builder: (context) => TelaDetalhesLivro(livro: livro),
          ),
        );
        if (alterouFavorito == true && mounted) {
          _carregarLivrosDaApi();
        }
      },
      child: Container(
        width: 120,
        margin: const EdgeInsets.only(right: 10),
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
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              livro.titulo,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        )
            : null,
      ),
    );
  }
}