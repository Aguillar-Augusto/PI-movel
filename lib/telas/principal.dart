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

class _PrincipalState extends State<Principal>{
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: _appBar(),
        body:  _screens[_currentIndex],
        bottomNavigationBar: _bottomNavigationBar()
    );
  }


  int _currentIndex = 0;

  //Monta a lista de telas
  List<Widget> _screens = [
    new Tela1(),
    new TelaPesquisa(),
    new TelaPerfil()
  ];



  @override
  void initState() {
    _currentIndex = 0;
  }

  AppBar _appBar(){
    return AppBar(
      title: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.menu_book_sharp, color: Theme.of(context).colorScheme.primary),
          Container(width: 10,),
          Text(
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
          icon: Icon(Icons.exit_to_app),
            onPressed: () async {
            await AutorizacaoController.desgravaAutorizacao();
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

  //barra de menu
  BottomNavigationBar _bottomNavigationBar(){
    return BottomNavigationBar(
      currentIndex: _currentIndex!,
      onTap: (index) {
        setState(() {
          _currentIndex = index;
        });
      },
      items: [
        BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: "Tela Home"
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.search),
          label: "Tela Dois",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.account_box),
          label: "Tela Tres",
        ),
      ],
    );
  }
}