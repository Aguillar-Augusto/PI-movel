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