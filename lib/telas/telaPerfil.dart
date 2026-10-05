import 'package:flutter/material.dart';
import 'package:testetcc2/telas/telaListaEstendida.dart';
import 'package:testetcc2/telas/telaDetalhesLivro.dart';
import 'package:testetcc2/models/classes/livro.dart';
import 'package:testetcc2/controller/api_client.dart';
import 'package:testetcc2/controller/autorizacao_controller.dart';
import 'package:testetcc2/telas/Login.dart';

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

  List<Livro> meusFavoritos = [];
  List<Livro> meusLivros = [];

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

      final responses = await Future.wait([
        dio.get('/user'),
        dio.get('/user/favoritos'),
        dio.get('/user/meus-livros'),
      ]);

      final resUser = responses[0];
      final resFav = responses[1];
      final resMeus = responses[2];

      if (resUser.statusCode == 200) {
        setState(() {
          isLogado = true;
          nome = resUser.data['name'] ?? 'Usuário';
          bio = resUser.data['bio'] ?? '';
          fotoUrl = resUser.data['foto_perfil_path'] ?? '';

          List<dynamic> favDados = resFav.data;
          meusFavoritos = favDados.map((json) => _converterJsonParaLivro(json, true)).toList();

          List<dynamic> meusDados = resMeus.data;
          meusLivros = meusDados.map((json) => _converterJsonParaLivro(json, false)).toList();

          isLoading = false;
        });
      }
    } catch (e) {
      print('Erro ao carregar perfil completo: $e');
      setState(() {
        isLogado = false;
        isLoading = false;
        nome = 'Visitante';
      });
    }
  }

  Livro _converterJsonParaLivro(Map<String, dynamic> json, bool isFav) {
    return Livro(
      id: json['id'].toString(),
      titulo: json['name'] ?? 'Sem Título',
      autor: json['autor'] ?? 'Autor Desconhecido',
      urlCapa: json['capa_path'] ?? '',
      urlPdf: json['pdf_path'] ?? '',
      descricao: json['sinopse'] ?? 'Sem descrição.',
      genero: json['genero1'] ?? 'Outros',
      favorito: isFav,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Meu Perfil"),
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : RefreshIndicator(
        onRefresh: _carregarPerfil,
        child: SingleChildScrollView(
          physics: AlwaysScrollableScrollPhysics(),
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

              if (isLogado) ...[
                secaoPersonalizada("Favoritos", meusFavoritos, context),
                secaoPersonalizada("Meus Livros", meusLivros, context),
              ]
            ],
          ),
        ),
      ),
    );
  }

  Widget secaoPersonalizada(String titulo, List<Livro> livros, BuildContext context) {
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
      onTap: () async {
        await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => TelaDetalhesLivro(livro: livro),
          ),
        );
        _carregarPerfil();
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
          child: Padding(
            padding: const EdgeInsets.all(4.0),
            child: Text(
              livro.titulo,
              textAlign: TextAlign.center,
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        )
            : null,
      ),
    );
  }
}