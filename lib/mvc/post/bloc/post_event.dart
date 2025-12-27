// lib/mvc/posts/bloc/post_event.dart
part of 'post_bloc.dart';

abstract class PostEvent extends Equatable {
  const PostEvent();
  @override
  List<Object?> get props => [];
}

class PostFetched extends PostEvent {
  const PostFetched();
}

class PostDetailFetched extends PostEvent {
  final int postId;
  const PostDetailFetched(this.postId);
  @override
  List<Object> get props => [postId];
}

class PostCreated extends PostEvent {
  final String title;
  final String content; // Ubah 'author' menjadi 'content' agar sinkron dengan body API
  final String author;
  final String? imageUrl;

  const PostCreated({
    required this.title,
    required this.content,
    required this.author,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [title, content, author, imageUrl];
}

class PostUpdated extends PostEvent {
  final int postId;
  final String title;
  final String content;
  final String author;
  final String? imageUrl;

  const PostUpdated({
    required this.postId,
    required this.title,
    required this.content,
    required this.author,
    this.imageUrl,
  });

  @override
  List<Object?> get props => [postId, title, content,author ,imageUrl];
}

class PostDeleted extends PostEvent {
  final int postId;
  const PostDeleted(this.postId);
  @override
  List<Object> get props => [postId];
}

class PostMessageCleared extends PostEvent {
  const PostMessageCleared();
}