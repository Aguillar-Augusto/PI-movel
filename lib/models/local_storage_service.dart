/*import 'dart:convert';
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
}*/
// lib/models/local_storage_service.dart
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:testetcc2/models/classes/autorizacao.dart';

class LocalStorageService {
  static const String _keyAutorizacao = 'autorizacao';

  static const FlutterSecureStorage _secureStorage = FlutterSecureStorage(
    aOptions: AndroidOptions(encryptedSharedPreferences: true),
  );

  static Future<void> salvarAutorizacao(Autorizacao auth) async {
    final String encodedData = json.encode(auth.toMap());
    await _secureStorage.write(key: _keyAutorizacao, value: encodedData);
  }

  static Future<void> desgravarAutorizacao() async {
    await _secureStorage.delete(key: _keyAutorizacao);
  }

  static Future<Autorizacao?> carregarAutorizacao() async {
    final String? authJson = await _secureStorage.read(key: _keyAutorizacao);
    if (authJson == null || authJson.isEmpty) return null;
    return Autorizacao.fromMap(json.decode(authJson));
  }
}