import 'package:dio/dio.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';
// Note: 'package:flutter/cupertino.dart' diubah menjadi
// 'package:flutter/foundation.dart' jika Anda hanya perlu 'print' atau dihapus jika tidak diperlukan.

class DioClient {
  // Gunakan nama private untuk instance Dio yang diinisialisasi
  final Dio _dio;

  DioClient({required String baseUrl, required String? token})
      : _dio = Dio( // Inisialisasi _dio
          BaseOptions(
            baseUrl: baseUrl,
            connectTimeout: const Duration(seconds: 10),
            receiveTimeout: const Duration(seconds: 10),
            sendTimeout: const Duration(seconds: 10),
            headers: {
              'Accept': 'application/json',
              if (token != null) 'Authorization': 'Bearer $token',
            },
          ),
        ) {
    // Tambahkan Interceptors
    _dio.interceptors.addAll([
      PrettyDioLogger(
        requestHeader: true,
        requestBody: true,
        responseBody: true,
        responseHeader: false,
        compact: true,
      ),
      InterceptorsWrapper(
        onError: (e, handler) {
          // Casting DioError untuk kompatibilitas fungsi _mapError
          if (e is DioError) {
            return handler.next(_mapError(e));
          }
          return handler.next(e);
        },
      ),
    ]);
  }

  // Expose Dio instance (menggantikan 'final Dio dio;' dan 'Dio get dio -> _dio;')
  // Hanya gunakan satu getter yang benar
  Dio get dio => _dio;

  // ==========================================================
  // 1. Error Mapping Function
  // ==========================================================

  // Fungsi penanganan error (DioErrorType digunakan, asumsi Dio versi lama/kompatibel)
  DioError _mapError(DioError error) {
    // Timeouts
    if (error.type == DioErrorType.connectionTimeout ||
        error.type == DioErrorType.receiveTimeout ||
        error.type == DioErrorType.sendTimeout) {
      return DioError(
        requestOptions: error.requestOptions,
        type: error.type,
        error: 'Cek koneksi internet anda',
      );
    }

    // Connection/Unknown errors
    if (error.type == DioErrorType.connectionError ||
        error.type == DioErrorType.unknown) {
      return DioError(
        requestOptions: error.requestOptions,
        type: error.type,
        error: 'Cek koneksi internet anda',
      );
    }

    // Bad Response (HTTP Status Code >= 400)
    if (error.type == DioErrorType.badResponse) {
      final status = error.response?.statusCode;
      // Mencoba mengambil pesan dari body, jika tidak ada, gunakan 'terjadi kesalahan'
      final message = error.response?.data is Map
          ? (error.response?.data['message'] ?? 'terjadi kesalahan')
          : 'terjadi kesalahan';

      // NOTE: DioError constructor memerlukan 'requestOptions' yang valid
      return DioError(
        requestOptions: error.requestOptions,
        response: error.response,
        type: error.type,
        error: '[$status] $message',
      );
    }

    // Default return
    return error;
  }

  // ==========================================================
  // 2. HTTP Methods (GET, POST, PUT, DELETE)
  // ==========================================================

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> post<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> put<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  Future<Response<T>> delete<T>(
    String path, {
    Object? data,
    Map<String, dynamic>? queryParameters,
    Options? options,
    CancelToken? cancelToken,
  }) async {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
      cancelToken: cancelToken,
    );
  }

  // ==========================================================
  // 3. Token Management
  // ==========================================================

  void updateToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearToken() {
    _dio.options.headers.remove('Authorization');
  }

  // ==========================================================
  // 4. Download Image with Aggressive Retry
  // ==========================================================

  Future<List<int>> downloadImage(String imageUrl) async {
    const maxRetries = 5;

    for (int attempt = 0; attempt < maxRetries; attempt++) {
      try {
        // Exponential backoff
        if (attempt > 0) {
          final delaySeconds = attempt * 2;
          await Future.delayed(Duration(seconds: delaySeconds));
          print(
              'Image retry attempt ${attempt + 1} (waiting ${delaySeconds}s)...');
        }

        // Create a separate Dio instance for image download
        final imageDio = Dio(
          BaseOptions(
            connectTimeout: const Duration(seconds: 60),
            receiveTimeout: const Duration(seconds: 300),
            sendTimeout: const Duration(seconds: 30),
            headers: const {
              'Accept': 'image/*,*/*',
              'User-Agent': 'Flutter App',
              'Connection': 'keep-alive',
            },
          ),
        );

        final Response<List<int>> response = await imageDio.get<List<int>>(
          imageUrl,
          options: Options(
            responseType: ResponseType.bytes,
          ),
        );

        if (response.statusCode == 200) {
          print(
              '✔️ Image OK on attempt ${attempt + 1}: $imageUrl (${response.data?.length ?? 0} bytes)',
          );
          return response.data ?? [];
        } else {
          // Melempar Exception jika status code bukan 200, akan ditangkap oleh catch
          throw Exception('HTTP ${response.statusCode}');
        }
      } catch (e) {
        print('❌ Attempt ${attempt + 1} failed: $e');
        if (attempt == maxRetries - 1) {
          print(
              '⚠️ All $maxRetries attempts failed, falling back to Image.network()',
          );
          // Melempar error terakhir agar dapat ditangani di luar fungsi
          rethrow;
        }
        // Lanjutkan ke loop berikutnya untuk mencoba kembali (retry)
      }
    }

    // Exception fallback jika somehow loop selesai
    throw Exception('Image download failed after $maxRetries attempts.');
  }
}