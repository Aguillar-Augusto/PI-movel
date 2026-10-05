import 'package:dio/dio.dart';
import 'package:testetcc2/models/local_storage_service.dart';

class ApiClient {
  static final Dio _dio = Dio(BaseOptions(
    baseUrl: 'https://pi-web.wasmer.app/api',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
    headers: {
      'Accept': 'application/json',
      'Content-Type': 'application/json',
    },
  ));

  static Future<Dio> getInstance() async {
    final auth = await LocalStorageService.carregarAutorizacao();

    if (auth != null && auth.token_autorizacao.isNotEmpty) {
      _dio.options.headers['Authorization'] = 'Bearer ${auth.token_autorizacao}';
    } else {
      _dio.options.headers.remove('Authorization');
    }

    return _dio;
  }
}