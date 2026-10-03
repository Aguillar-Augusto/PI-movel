import 'package:flutter/material.dart';
import 'package:testetcc2/telas/telaDetalhesLivro.dart';
import 'package:testetcc2/LivrosMock.dart';

class TelaListaEstendida extends StatelessWidget {
  final String tituloGenero;

  TelaListaEstendida({required this.tituloGenero});

  @override
  Widget build(BuildContext context) {
    final livros = LivrosMock.porGenero(tituloGenero);
    return Scaffold(
      appBar: AppBar(
        title: Text(tituloGenero),
      ),
      body: ListView.builder(
        itemCount: livros.length,
        itemBuilder: (context, index) {
          final livro = livros[index];
          return ListTile(
            leading: Container(
              width: 50,
              height: 70,
              color: Theme.of(context).colorScheme.secondaryContainer,
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
}