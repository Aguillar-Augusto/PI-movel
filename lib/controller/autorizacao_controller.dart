import 'package:testetcc2/models/classes/autorizacao.dart';
import 'package:testetcc2/models/local_storage_service.dart';
import 'api_client.dart';
import 'package:dio/dio.dart';

class AutorizacaoController {
  static Future<void> gravaAutorizacao(String usuario, String token) async {
    final auth = Autorizacao(usuario: usuario, senha: '', token_autorizacao: token);
    await LocalStorageService.salvarAutorizacao(auth);
  }

  static Future<void> desgravaAutorizacao() async {
    try {
      final dio = await ApiClient.getInstance();
      await dio.post('/logout');
    } catch (e) {
      print('Aviso: Falha ao invalidar token no servidor. Deslogando localmente. Erro: $e');
    }

    await LocalStorageService.desgravarAutorizacao();
  }

  static Future<bool> verificaAutorizacaoOnline(Autorizacao auth) async {
    try {
      final dio = await ApiClient.getInstance();

      final response = await dio.post('/login', data: {
        'email': auth.usuario,
        'password': auth.senha,
      });

      if (response.statusCode == 200) {
        final token = response.data['access_token'];
        final nomeUsuario = response.data['user']['name'] ?? auth.usuario;

        await gravaAutorizacao(nomeUsuario, token);
        return true;
      }
      return false;

    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        print('Erro de autenticação: Credenciais inválidas.');
      } else {
        print('Erro na conexão com a API: ${e.message}');
      }
      return false;
    } catch (e) {
      print('Erro inesperado durante o login: $e');
      return false;
    }
  }

  static Future<bool> verificaAutorizacaoOffline() async {
    final auth = await LocalStorageService.carregarAutorizacao();
    return auth != null && auth.token_autorizacao.isNotEmpty;
  }
}