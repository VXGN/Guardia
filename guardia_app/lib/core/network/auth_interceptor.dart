import 'package:dio/dio.dart';
import 'package:guardia_app/core/services/secure_storage_service.dart';

class AuthInterceptor extends Interceptor {

  AuthInterceptor(this._storageService);
  final SecureStorageService _storageService;

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final token = await _storageService.getToken();
    if (token != null) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    super.onRequest(options, handler);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    if (err.response?.statusCode == 401) {
      // TODO: Handle token expiration (e.g., logout or refresh token)
    }
    super.onError(err, handler);
  }
}
