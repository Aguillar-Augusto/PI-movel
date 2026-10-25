import 'package:dio/dio.dart';
import 'package:testetcc2/models/classes/autorizacao.dart';
import 'package:testetcc2/models/local_storage_service.dart';
import 'api_client.dart';

class AutorizacaoController {
  static Future<void> gravaAutorizacao(String usuario, String token) async {
    final auth = Autorizacao(usuario: usuario, tokenAutorizacao: token);
    await LocalStorageService.salvarAutorizacao(auth);
  }

  static Future<void> desgravaAutorizacao() async {
    try {
      final dio = await ApiClient.getInstance();
      await dio.post('/logout');
    } catch (_) {
    } finally {
      await LocalStorageService.desgravarAutorizacao();
    }
  }

  static Future<bool> realizarLogin(String email, String senha) async {
    try {
      final dio = await ApiClient.getInstance();

      final response = await dio.post('/login', data: {
        'email': email,
        'password': senha,
      });

      if (response.statusCode == 200) {
        final token = (response.data['access_token'] ?? '').toString();
        final nomeUsuario = (response.data['user']?['name'] ?? email).toString();

        if (token.isNotEmpty) {
          await gravaAutorizacao(nomeUsuario, token);
          return true;
        }
      }
      return false;
    } on DioException {
      return false;
    } catch (_) {
      return false;
    }
  }

  static Future<bool> verificaAutorizacaoOffline() async {
    final auth = await LocalStorageService.carregarAutorizacao();
    return auth != null && auth.tokenAutorizacao.isNotEmpty;
  }

  static Future<bool> validarSessaoAtiva() async {
    final temTokenLocal = await verificaAutorizacaoOffline();
    if (!temTokenLocal) return false;

    try {
      final dio = await ApiClient.getInstance();
      final response = await dio.get('/user');
      return response.statusCode == 200;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        await LocalStorageService.desgravarAutorizacao();
        return false;
      }
      return true;
    } catch (_) {
      return false;
    }
  }
}