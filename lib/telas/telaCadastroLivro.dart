import 'package:flutter/material.dart';
import 'package:testetcc2/LivrosMock.dart';
import 'package:testetcc2/models/classes/livro.dart';

class TelaCadastroLivro extends StatefulWidget {
  @override
  _TelaCadastroLivroState createState() => _TelaCadastroLivroState();
}

class _TelaCadastroLivroState extends State<TelaCadastroLivro> {
  final _tituloController = TextEditingController();
  final _autorController = TextEditingController();
  final _descricaoController = TextEditingController();

  String _generoSelecionado = LivrosMock.generos.first;

  @override
  void dispose() {
    _tituloController.dispose();
    _autorController.dispose();
    _descricaoController.dispose();
    super.dispose();
  }

  Future<void> _salvarLivro() async {
    final titulo = _tituloController.text.trim();
    final autor = _autorController.text.trim();
    final descricao = _descricaoController.text.trim();

    if (titulo.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, insira o título do livro')),
      );
      return;
    }
    if (autor.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Por favor, insira o autor do livro')),
      );
      return;
    }

    final novoLivro = Livro(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      titulo: titulo,
      autor: autor,
      urlCapa: '',
      descricao: descricao.isEmpty ? 'Sem descrição.' : descricao,
      genero: _generoSelecionado,
    );

    await LivrosMock.adicionarLivro(novoLivro);

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('"$titulo" cadastrado com sucesso!')),
    );
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(title: Text("Cadastrar Livro")),
      body: Center(
        child: SingleChildScrollView(
          padding: EdgeInsets.all(30.0),
          child: Column(
            children: [
              Container(
                padding: EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(color: Colors.black26, blurRadius: 10, offset: Offset(0, 5))
                  ],
                ),
                child: Column(
                  children: [
                    Text(
                      "Novo Livro",
                      style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Theme.of(context).colorScheme.primary),
                    ),
                    SizedBox(height: 20),
                    TextField(
                      controller: _tituloController,
                      decoration: InputDecoration(
                        labelText: "Título",
                        prefixIcon: Icon(Icons.menu_book),
                      ),
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: _autorController,
                      decoration: InputDecoration(
                        labelText: "Autor",
                        prefixIcon: Icon(Icons.person),
                      ),
                    ),
                    SizedBox(height: 15),
                    DropdownButtonFormField<String>(
                      value: _generoSelecionado,
                      decoration: InputDecoration(
                        labelText: "Gênero",
                        prefixIcon: Icon(Icons.category),
                      ),
                      items: LivrosMock.generos
                          .map((genero) => DropdownMenuItem(value: genero, child: Text(genero)))
                          .toList(),
                      onChanged: (valor) {
                        setState(() {
                          _generoSelecionado = valor!;
                        });
                      },
                    ),
                    SizedBox(height: 15),
                    TextField(
                      controller: _descricaoController,
                      maxLines: 4,
                      decoration: InputDecoration(
                        labelText: "Descrição",
                        prefixIcon: Icon(Icons.description),
                      ),
                    ),
                    SizedBox(height: 25),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Theme.of(context).colorScheme.primary,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                        ),
                        onPressed: _salvarLivro,
                        child: Text("Salvar Livro", style: TextStyle(color: Colors.white, fontSize: 18)),
                      ),
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