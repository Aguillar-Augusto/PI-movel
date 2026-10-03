import 'package:flutter/material.dart';
import 'package:testetcc2/telas/telaDetalhesLivro.dart';
import 'package:testetcc2/LivrosMock.dart';
import 'package:testetcc2/models/classes/livro.dart';

class TelaPesquisa extends StatefulWidget {
  @override
  _TelaPesquisaState createState() => _TelaPesquisaState();
}

class _TelaPesquisaState extends State<TelaPesquisa> {
  List<Livro> _resultados = LivrosMock.todos;

  void _pesquisar(String termo) {
    setState(() {
      _resultados = LivrosMock.pesquisar(termo);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Pesquisa"),
      ),
      body: Column(
        children: [
          TextField(
            onChanged: _pesquisar,
            decoration: InputDecoration(
              hintText: "Digite para pesquisar...",
            ),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: _resultados.length,
              itemBuilder: (context, index) {
                final livro = _resultados[index];
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
          ),
        ],
      ),
    );
  }
}