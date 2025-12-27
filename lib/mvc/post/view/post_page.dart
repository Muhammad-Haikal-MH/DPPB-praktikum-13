import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:restapi/mvc/auth/bloc/auth_event.dart';
// PERBAIKAN: Cukup impor file Bloc utamanya saja
import '../../auth/bloc/auth_bloc.dart'; 
import '../bloc/post_bloc.dart';

import 'post_form_page.dart';
import 'post_detail_page.dart';
class PostPage extends StatefulWidget {
  static const String routeName = '/posts';
  const PostPage({super.key});

  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  @override
  void initState() {
    super.initState();
    context.read<PostBloc>().add(const PostFetched());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Semua Postingan'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<PostBloc>().add(const PostFetched()),
          ),
          IconButton(
            icon: const Icon(Icons.exit_to_app),
            onPressed: () {
              context.read<AuthBloc>().add(const AuthLogoutRequested());
            },
          ),
        ],
      ),
      body: MultiBlocListener(
        listeners: [
          BlocListener<AuthBloc, AuthState>(
            listener: (context, state) {
              if (state.status == AuthStatus.unauthenticated) {
                Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
              }
            },
          ),
          BlocListener<PostBloc, PostState>(
            listener: (context, state) {
              if (state.message != null && state.status != PostStatus.loading) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text(state.message!)),
                );
                context.read<PostBloc>().add(const PostMessageCleared());
              }
            },
          ),
        ],
        child: BlocBuilder<PostBloc, PostState>(
          builder: (context, state) {
            if (state.status == PostStatus.loading && state.posts.isEmpty) {
              return const Center(child: CircularProgressIndicator());
            }

            if (state.posts.isEmpty) {
              return const Center(child: Text('Belum ada postingan.'));
            }

            return RefreshIndicator(
              onRefresh: () async {
                context.read<PostBloc>().add(const PostFetched());
              },
              child: ListView.builder(
                itemCount: state.posts.length,
                itemBuilder: (context, index) {
                  final post = state.posts[index];
                  return ListTile(
                    leading: post.imageUrl != null
                        ? Image.network(
                            post.imageUrl!,
                            width: 50,
                            height: 50,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                const Icon(Icons.broken_image),
                          )
                        : const Icon(Icons.article),
                    title: Text(post.title),
                    subtitle: Text('Oleh: ${post.author}'),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => PostDetailPage(post: post),
                        ),
                      );
                    },
                  );
                },
              ),
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => Navigator.of(context).pushNamed(PostFormPage.routeName),
        child: const Icon(Icons.add),
      ),
    );
  }
}