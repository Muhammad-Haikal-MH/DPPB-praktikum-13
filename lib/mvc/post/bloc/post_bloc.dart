import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart'; // Import Equatable di sini agar terbaca oleh file part
import '../data/post_model.dart';
import '../data/post_repository.dart';

// Daftarkan file part
part 'post_event.dart';
part 'post_state.dart';

class PostBloc extends Bloc<PostEvent, PostState> {
  final PostRepository _postRepository;

  PostBloc({required PostRepository postRepository})
      : _postRepository = postRepository,
        super(const PostState.initial()) {
    
    // Registrasi Event Handlers
    on<PostFetched>(_onPostFetched);
    on<PostDetailFetched>(_onPostDetailFetched);
    on<PostCreated>(_onPostCreated);
    on<PostUpdated>(_onPostUpdated);
    on<PostDeleted>(_onPostDeleted);
    on<PostMessageCleared>(_onMessageCleared);
  }

  // --- Event Handlers ---

  Future<void> _onPostFetched(
    PostFetched event,
    Emitter<PostState> emit,
  ) async {
    emit(state.copyWith(status: PostStatus.loading)); 
    try {
      final posts = await _postRepository.fetchPosts();
      emit(state.copyWith(status: PostStatus.success, posts: posts, message: null));
    } catch (e) {
      emit(state.copyWith(
        status: PostStatus.failure,
        message: e.toString(),
      ));
    }
  }
  
  Future<void> _onPostDetailFetched(
    PostDetailFetched event,
    Emitter<PostState> emit,
  ) async {
    emit(state.copyWith(status: PostStatus.loading));
    try {
      final post = await _postRepository.fetchPostDetail(event.postId);
      emit(state.copyWith(status: PostStatus.success, detailPost: post, message: null));
    } catch (e) {
      emit(state.copyWith(
        status: PostStatus.failure,
        message: e.toString(),
      ));
    }
  }

  Future<void> _onPostCreated(
    PostCreated event,
    Emitter<PostState> emit,
  ) async {
    emit(state.copyWith(status: PostStatus.loading));
    try {
      // Perbaikan: event menggunakan 'author' (sesuai kode event Anda sebelumnya)
      // tapi repository biasanya meminta 'body' atau 'content'
      final newPost = await _postRepository.createPost(
        title: event.title,
        body: event.content, // Disesuaikan dengan field di PostCreated event
        author: event.author,
        imageUrl: event.imageUrl,
      );

      final updatedPosts = [newPost, ...state.posts];
      
      emit(state.copyWith(
        status: PostStatus.success,
        posts: updatedPosts,
        message: 'Postingan berhasil dibuat',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PostStatus.failure,
        message: e.toString(),
      ));
    }
  }

  Future<void> _onPostUpdated(
    PostUpdated event,
    Emitter<PostState> emit,
  ) async {
    emit(state.copyWith(status: PostStatus.loading));
    try {
      final updatedPost = await _postRepository.updatePost(
        event.postId,
        title: event.title,
        body: event.content,
        author: event.author,
        imageUrl: event.imageUrl,
      );

      final updatedPosts = state.posts.map((post) {
        return post.id == event.postId ? updatedPost : post;
      }).toList();
      
      emit(state.copyWith(
        status: PostStatus.success,
        posts: updatedPosts,
        message: 'Postingan berhasil diperbarui',
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PostStatus.failure,
        message: e.toString(),
      ));
    }
  }

  Future<void> _onPostDeleted(
    PostDeleted event,
    Emitter<PostState> emit,
  ) async {
    emit(state.copyWith(status: PostStatus.loading));
    try {
      final message = await _postRepository.deletePost(event.postId);

      final updatedPosts = state.posts.where((post) => post.id != event.postId).toList();
      
      emit(state.copyWith(
        status: PostStatus.success,
        posts: updatedPosts,
        message: message,
      ));
    } catch (e) {
      emit(state.copyWith(
        status: PostStatus.failure,
        message: e.toString(),
      ));
    }
  }

  void _onMessageCleared(
    PostMessageCleared event,
    Emitter<PostState> emit,
  ) {
    emit(state.copyWith(message: null));
  }
}