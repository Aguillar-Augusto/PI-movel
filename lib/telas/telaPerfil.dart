import 'package:flutter/material.dart';
import 'package:testetcc2/telas/telaListaEstendida.dart';
import 'package:testetcc2/telas/telaDetalhesLivro.dart';
import 'package:testetcc2/LivrosMock.dart';
import 'package:testetcc2/models/classes/livro.dart';
import 'package:testetcc2/controller/api_client.dart';

class TelaPerfil extends StatefulWidget {
  @override
  _TelaPerfilState createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  String nome = '';
  String bio = '';
  String fotoUrl = '';
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  Future<void> _carregarPerfil() async {
    try {
      final dio = await ApiClient.getInstance();

      final response = await dio.get('/user');

      if (response.statusCode == 200) {
        setState(() {
          nome = response.data['name'] ?? 'Usuário';
          bio = response.data['bio'] ?? '';
          fotoUrl = response.data['foto_perfil_path'] ?? '';
          isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar perfil: $e');
      setState(() {
        isLoading = false;
        bio = 'Erro ao carregar dados do servidor.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Meu Perfil"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(height: 20),
            Center(
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Theme.of(context).colorScheme.primary,
                backgroundImage: fotoUrl.isNotEmpty ? NetworkImage(fotoUrl) : null,
                child: fotoUrl.isEmpty
                    ? Icon(Icons.person, size: 50, color: Colors.white)
                    : null,
              ),
            ),
            SizedBox(height: 15),
            Text(
              nome,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 15),
            Divider(color: Colors.grey, thickness: 1, indent: 0, endIndent: 0),
            Padding(
              padding: EdgeInsets.all(20),
              child: Text(
                bio.isNotEmpty ? bio : "Nenhuma bio cadastrada.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
            ),
            SizedBox(height: 20),

            secaoGenero("Favoritos", context),
          ],
        ),
      ),
    );
  }

  Widget secaoGenero(String titulo, BuildContext context) {
    final livros = LivrosMock.porGenero(titulo);
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
                children: livros.map((livro) => testeLivro(livro, context)).toList(),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget testeLivro(Livro livro, BuildContext context) {
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
        color: Theme.of(context).colorScheme.secondaryContainer,
        child: Center(child: Text(livro.titulo)),
      ),
    );
  }
}