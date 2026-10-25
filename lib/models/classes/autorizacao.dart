// lib/models/classes/autorizacao.dart
class Autorizacao {
  final String usuario;
  final String tokenAutorizacao;

  const Autorizacao({
    required this.usuario,
    required this.tokenAutorizacao,
  });

  Map<String, dynamic> toMap() {
    return {
      'usuario': usuario,
      'token_autorizacao': tokenAutorizacao,
    };
  }

  factory Autorizacao.fromMap(Map<String, dynamic> map) {
    return Autorizacao(
      usuario: map['usuario'] ?? '',
      tokenAutorizacao: map['token_autorizacao'] ?? '',
    );
  }
}