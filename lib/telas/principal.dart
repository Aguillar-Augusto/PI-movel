// lib/telas/principal.dart
import 'package:flutter/material.dart';
import 'package:testetcc2/telas/Tela1.dart';
import 'package:testetcc2/telas/telaPesquisa.dart';
import 'package:testetcc2/telas/telaPerfil.dart';
import 'package:testetcc2/telas/Login.dart';
import 'package:testetcc2/controller/autorizacao_controller.dart';

class Principal extends StatefulWidget {
  @override
  _PrincipalState createState() => _PrincipalState();
}

class _PrincipalState extends State<Principal> {
  int _currentIndex = 0;
  bool _isLogado = false;

  final List<Widget> _screens = [
    Tela1(),
    TelaPesquisa(),
    TelaPerfil(),
  ];

  @override
  void initState() {
    super.initState();
    _checarStatusLogin();
  }

  Future<void> _checarStatusLogin() async {
    final logado = await AutorizacaoController.verificaAutorizacaoOffline();
    if (!mounted) return;
    setState(() {
      _isLogado = logado;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _appBar(),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: _bottomNavigationBar(),
    );
  }

  AppBar _appBar() {
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_sharp, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 10),
          const Text(
            "Papiro Digital",
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.black,
              fontSize: 20,
            ),
          ),
        ],
      ),
      backgroundColor: Colors.white,
      actions: [
        IconButton(
          tooltip: _isLogado ? "Sair" : "Entrar",
          icon: Icon(_isLogado ? Icons.exit_to_app : Icons.login),
          onPressed: () async {
            if (_isLogado) {
              await AutorizacaoController.desgravaAutorizacao();
            }
            if (!mounted) return;
            Navigator.pushAndRemoveUntil(
              context,
              MaterialPageRoute(builder: (context) => Login()),
                  (Route<dynamic> route) => false,
            );
          },
        ),
      ],
    );
  }

  BottomNavigationBar _bottomNavigationBar() {
    return BottomNavigationBar(
      currentIndex: _currentIndex,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Início",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: "Pesquisar",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_box),
          label: "Perfil",
        ),
      ],
    );
  }
}