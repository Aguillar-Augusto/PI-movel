import 'package:flutter/material.dart';
import 'package:testetcc2/telas/telaListaEstendida.dart';
import 'package:testetcc2/telas/telaDetalhesLivro.dart';
import 'package:testetcc2/LivrosMock.dart';
import 'package:testetcc2/models/classes/livro.dart';
import 'package:testetcc2/controller/api_client.dart';
import 'package:testetcc2/controller/autorizacao_controller.dart';

import 'Login.dart';

class TelaPerfil extends StatefulWidget {
  @override
  _TelaPerfilState createState() => _TelaPerfilState();
}

class _TelaPerfilState extends State<TelaPerfil> {
  String nome = 'Visitante';
  String bio = '';
  String fotoUrl = '';
  bool isLoading = true;
  bool isLogado = false;

  @override
  void initState() {
    super.initState();
    _carregarPerfil();
  }

  Future<void> _carregarPerfil() async {
    final temSessao = await AutorizacaoController.verificaAutorizacaoOffline();

    if (!temSessao) {
      setState(() {
        isLogado = false;
        isLoading = false;
        nome = 'Visitante';
      });
      return;
    }

    try {
      final dio = await ApiClient.getInstance();
      final response = await dio.get('/user');

      if (response.statusCode == 200) {
        setState(() {
          isLogado = true;
          nome = response.data['name'] ?? 'Usuário';
          bio = response.data['bio'] ?? '';
          fotoUrl = response.data['foto_perfil_path'] ?? '';
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        isLogado = false;
        isLoading = false;
        nome = 'Visitante';
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
              child: isLogado
                  ? Text(
                bio.isNotEmpty ? bio : "Nenhuma bio cadastrada.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              )
                  : SizedBox(
                width: 250,
                height: 50,
                child: ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Theme.of(context).colorScheme.primary,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (context) => Login()),
                    );
                  },
                  icon: Icon(Icons.login, color: Colors.white),
                  label: Text(
                      "Fazer Login",
                      style: TextStyle(color: Colors.white, fontSize: 18)
                  ),
                ),
              ),
            ),
            SizedBox(height: 20),

            // Mantendo as seções mockadas conforme você pediu
            secaoGenero("Favoritos", context),
          ],
        ),
      ),
    );
  }

  // --- MANTENHA SUAS FUNÇÕES secaoGenero E testeLivro AQUI EMBAIXO INTACTAS ---

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