// lib/controller/api_client.dart
import 'package:dio/dio.dart';
import 'package:testetcc2/models/local_storage_service.dart';

class ApiClient {
  static bool _interceptorsConfigurados = false;

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
    if (!_interceptorsConfigurados) {
      _dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            final auth = await LocalStorageService.carregarAutorizacao();
            if (auth != null && auth.tokenAutorizacao.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer ${auth.tokenAutorizacao}';
            } else {
              options.headers.remove('Authorization');
            }
            return handler.next(options);
          },
          onError: (DioException error, handler) async {
            if (error.response?.statusCode == 401 &&
                !error.requestOptions.path.contains('/login')) {
              await LocalStorageService.desgravarAutorizacao();
            }
            return handler.next(error);
          },
        ),
      );
      _interceptorsConfigurados = true;
    }

    return _dio;
  }
}