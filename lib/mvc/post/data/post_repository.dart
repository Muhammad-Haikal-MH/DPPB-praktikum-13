// lib/mvc/posts/data/post_repository.dart

import 'package:dio/dio.dart';
import '../../../core/dio_client.dart';
import 'post_model.dart';
// import 'package:http_parser/http_parser.dart';

class PostRepository {
  final DioClient _client;

  PostRepository(this._client);

  // --- Ambil Semua Posts (GET /api/posts) ---
  Future<List<PostModel>> fetchPosts() async {
    try {
      final response = await _client.get<Map<String, dynamic>>('/posts');

      final data = response.data?['data'] as List? ?? [];
      
      return data
          .map((json) => PostModel.fromJson(json as Map<String, dynamic>))
          .toList();
    } on DioError catch (e) {
      throw Exception(_mapDioError(e));
    } catch (e) {
      throw Exception('Gagal memuat postingan: $e');
    }
  }

  // --- Ambil Detail Post (GET /api/posts/{id}) ---
  Future<PostModel> fetchPostDetail(int postId) async {
    try {
      final response = await _client.get<Map<String, dynamic>>('/posts/$postId');

      final data = response.data;

      if (data == null) {
        throw Exception('Postingan tidak ditemukan');
      }

      return PostModel.fromJson(data);
    } on DioError catch (e) {
      throw Exception(_mapDioError(e));
    } catch (e) {
      throw Exception('Gagal memuat detail postingan: $e');
    }
  }

  // --- Buat Post Baru (POST /api/posts) ---
  Future<PostModel> createPost({
    required String title,
    required String body,
    required String author,
    String? imageUrl, 
  }) async {
    try {
      final response = await _client.post<Map<String, dynamic>>(
        '/posts',
        data: {
          'title': title,
          'article': body,
          'author': author,
          if (imageUrl != null) 'image_url': imageUrl,
        },
      );

      final data = response.data;

      if (data == null) {
        throw Exception('Gagal membuat postingan');
      }

      return PostModel.fromJson(data);
    } on DioError catch (e) {
      throw Exception(_mapDioError(e));
    } catch (e) {
      throw Exception('Gagal membuat postingan: $e');
    }
  }

  // --- Update Post (PUT /api/posts/{id}) ---
  Future<PostModel> updatePost(
    int postId, {
    required String title,
    required String body,
    required String author,
    String? imageUrl, 
  }) async {
    try {
      final response = await _client.put<Map<String, dynamic>>(
        '/posts/$postId',
        data: {
          'title': title,
          'article': body,
          'author': author,
          if (imageUrl != null) 'image_url': imageUrl,
        },
      );

      final data = response.data;

      if (data == null) {
        throw Exception('Gagal memperbarui postingan');
      }

      return PostModel.fromJson(data);
    } on DioError catch (e) {
      throw Exception(_mapDioError(e));
    } catch (e) {
      throw Exception('Gagal memperbarui postingan: $e');
    }
  }

  // --- Hapus Post (DELETE /api/posts/{id}) ---
  Future<String> deletePost(int postId) async {
    try {
      final response = await _client.delete<Map<String, dynamic>>(
        '/posts/$postId',
      );

      final message = response.data?['message'] as String?;
      return message ?? 'Postingan berhasil dihapus';
    } on DioError catch (e) {
      throw Exception(_mapDioError(e));
    } catch (e) {
      throw Exception('Gagal menghapus postingan: $e');
    }
  }

  // --- Fungsi Pembantu untuk Error Handling ---
  String _mapDioError(DioError e) {
    if (e.type == DioErrorType.connectionTimeout ||
        e.type == DioErrorType.receiveTimeout ||
        e.type == DioErrorType.sendTimeout ||
        e.type == DioErrorType.connectionError ||
        e.type == DioErrorType.unknown) {
      return 'Cek koneksi internet anda';
    }
    
    final status = e.response?.statusCode;
    final msg = e.response?.data is Map
        ? (e.response?.data['message'] ?? e.response?.data['error'])
        : null;

    if (status == 404) {
      return 'Endpoint/Resource tidak ditemukan';
    }
    if (status == 401) {
      return 'Sesi berakhir, silakan login kembali';
    }
    
    return msg ?? 'Terjadi kesalahan tidak terduga';
  }
}