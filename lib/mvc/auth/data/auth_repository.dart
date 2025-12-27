// lib/mvc/auth/data/auth_repository.dart

import 'package:dio/dio.dart';
import 'user_model.dart';
import '../../../core/dio_client.dart';

class AuthRepository {
  final DioClient _client;

  AuthRepository(this._client);

  // --- Register ---
  Future<Map<String, dynamic>> register({
    required String name,
    required String email,
    required String password,
    required String passwordConfirmation,
  }) async {
    // Tambahkan try-catch agar error dari DioClient bisa ditangkap dengan baik
    try {
      final response = await _client.post<Map<String, dynamic>>(
        '/register',
        data: {
          'name': name,
          'email': email,
          'password': password,
          'password_confirmation': passwordConfirmation,
        },
      );

      final data = response.data ?? {};

      return {
        'user': UserModel.fromJson(data['user'] as Map<String, dynamic>),
        'token': data['access_token'] as String?,
        'message': data['message'] as String? ?? 'Registration successful',
      };
    } on DioException catch (e) {
      // Gunakan fungsi helper penanganan error yang kita buat di bawah
      throw Exception(_handleError(e));
    }
  }

  // --- Login ---
  Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        '/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data ?? {};

      return {
        'user': UserModel.fromJson(data['user'] as Map<String, dynamic>),
        'token': data['access_token'] as String?,
        'message': data['message'] as String? ?? 'Login berhasil',
      };
    } on DioException catch (e) {
      // PERBAIKAN: Menggunakan DioException (bukan DioError)
      throw Exception(_handleError(e));
    }
  }

  // --- Logout ---
  Future<String> logout() async {
    try {
      final response = await _client.post<Map<String, dynamic>>('/logout');
      final data = response.data ?? {};
      return data['message'] as String? ?? 'Logout successful';
    } catch (_) {
      return 'Logout selesai';
    }
  }

  // --- Get Profile ---
  Future<UserModel> getProfile() async {
    try {
      final response = await _client.get<Map<String, dynamic>>('/me');
      final data = response.data ?? {};
      return UserModel.fromJson(data['user'] as Map<String, dynamic>);
    } on DioException catch (e) {
      throw Exception(_handleError(e));
    }
  }

  // ==========================================================
  // Helper Function untuk menyederhanakan Pesan Error
  // ==========================================================
  String _handleError(DioException e) {
    // Jika pesan error datang dari _mapError di DioClient kita (berupa String di field error)
    if (e.error != null && e.error is String) {
      final errorMsg = e.error as String;
      
      // Kustomisasi pesan spesifik untuk Auth
      if (errorMsg.contains('401')) return 'Email atau password salah';
      if (errorMsg.contains('422')) return 'Data tidak valid atau email sudah terdaftar';
      
      return errorMsg;
    }

    // Fallback jika tidak terdeteksi
    final status = e.response?.statusCode;
    if (status == 401) return 'Email atau password salah';
    if (status == 422) return 'Input tidak valid';
    
    return 'Terjadi kesalahan sistem (${e.type})';
  }
}