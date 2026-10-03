import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:testetcc2/models/classes/autorizacao.dart';

class LocalStorageService {
  static const String AUTORIZACAO = 'autorizacao';

  static Future<void> salvarAutorizacao(Autorizacao auth) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String encodedData = json.encode(auth.toMap());
    await prefs.setString(AUTORIZACAO, encodedData);
  }

  static Future<void> desgravarAutorizacao() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.remove(AUTORIZACAO);
  }

  static Future<Autorizacao?> carregarAutorizacao() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    final String? authJson = prefs.getString(AUTORIZACAO);
    if (authJson == null) return null;
    return Autorizacao.fromMap(json.decode(authJson));
  }
}