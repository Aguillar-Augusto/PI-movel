import 'package:testetcc2/models/classes/autorizacao.dart';
import 'package:testetcc2/models/local_storage_service.dart';

class AutorizacaoController {
  static Future<void> gravaAutorizacao(String usuario, String token) async {
    final auth = Autorizacao(usuario: usuario, senha: '', token_autorizacao: token);
    await LocalStorageService.salvarAutorizacao(auth);
  }

  static Future<void> desgravaAutorizacao() async {
    await LocalStorageService.desgravarAutorizacao();
  }

  static Future<bool> verificaAutorizacaoOnline(Autorizacao auth) async {
    if (auth.usuario == '123456' && auth.senha == '123456') {
      final authApiRetorno = Autorizacao(
        usuario: 'fera',
        senha: '',
        token_autorizacao: 'çalskdfsoiu23j́bdçvocuiyvhkjqerb-iudfhnsbdkljqghoi',
      );
      await gravaAutorizacao(authApiRetorno.usuario, authApiRetorno.token_autorizacao);
      return true;
    }
    return false;
  }

  static Future<bool> verificaAutorizacaoOffline() async {
    final auth = await LocalStorageService.carregarAutorizacao();
    return auth != null;
  }
}