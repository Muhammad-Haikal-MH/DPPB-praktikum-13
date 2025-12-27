// lib/mvc/posts/bloc/post_state.dart
part of 'post_bloc.dart'; // PERBAIKAN: Gunakan 'part of', bukan 'part'

enum PostStatus { initial, loading, success, failure }

class PostState extends Equatable {
  final PostStatus status;
  final List<PostModel> posts;
  final PostModel? detailPost;
  final String? message;

  const PostState({
    required this.status,
    this.posts = const [],
    this.detailPost,
    this.message,
  });

  const PostState.initial()
      : status = PostStatus.initial,
        posts = const [],
        detailPost = null,
        message = null;

  PostState copyWith({
    PostStatus? status,
    List<PostModel>? posts,
    PostModel? detailPost,
    String? message,
  }) {
    return PostState(
      status: status ?? this.status,
      posts: posts ?? this.posts,
      detailPost: detailPost ?? this.detailPost,
      message: message, // Message biasanya direset jika tidak dikirim
    );
  }

  @override
  List<Object?> get props => [status, posts, detailPost, message];
}