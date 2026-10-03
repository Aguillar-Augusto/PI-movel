import 'dart:convert';

class Autorizacao {
  final String usuario;
  final String senha;
  final String token_autorizacao;

  Autorizacao({
    required this.usuario,
    required this.senha,
    required this.token_autorizacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'usuario': usuario,
      'senha': senha,
      'token_autorizacao': token_autorizacao,
    };
  }

  factory Autorizacao.fromMap(Map<String, dynamic> map) {
    return Autorizacao(
      usuario: map['usuario'] ?? '',
      senha: map['senha'] ?? '',
      token_autorizacao: map['token_autorizacao'] ?? '',
    );
  }
}