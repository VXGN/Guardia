import 'package:dio/dio.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AuthInterceptor extends QueuedInterceptor {

  AuthInterceptor(this._firebaseAuth, this._dio);
  final FirebaseAuth _firebaseAuth;
  final Dio _dio;

  static const _retriedKey = '__auth_retry';

  @override
  Future<void> onRequest(RequestOptions options, RequestInterceptorHandler handler) async {
    final user = _firebaseAuth.currentUser;
    if (user != null) {
      final token = await user.getIdToken();
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  @override
  Future<void> onError(DioException err, ErrorInterceptorHandler handler) async {
    final requestOptions = err.requestOptions;
    final alreadyRetried = requestOptions.extra[_retriedKey] == true;

    if (err.response?.statusCode == 401 && !alreadyRetried) {
      final user = _firebaseAuth.currentUser;

      if (user != null) {
        try {
          final refreshedToken = await user.getIdToken(true);

          if (refreshedToken != null) {
            final retryOptions = requestOptions.copyWith(
              headers: <String, dynamic>{
                ...requestOptions.headers,
                'Authorization': 'Bearer $refreshedToken',
              },
              extra: <String, dynamic>{
                ...requestOptions.extra,
                _retriedKey: true,
              },
            );

            final response = await _dio.fetch<dynamic>(retryOptions);
            handler.resolve(response);
            return;
          }
        } catch (_) {
          // Fall through to the original error.
        }
      }
    }

    handler.next(err);
  }
}
