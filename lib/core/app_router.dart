import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restapi/mvc/post/bloc/post_bloc.dart';
import 'package:restapi/mvc/post/data/post_repository.dart';
import 'package:restapi/mvc/post/view/post_page.dart';

import '../mvc/auth/data/auth_repository.dart';
import '../mvc/auth/data/auth_storage.dart';

class AppRouter {
  AppRouter({
    required this.authRepository,
    required this.authStorage,
    required this.postRepository,
  });

  final AuthRepository authRepository;
  final AuthStorage authStorage;
  final PostRepository postRepository;

  Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case PostPage.routeName:
      case '/':
        return MaterialPageRoute(
          builder: (_) => RepositoryProvider.value(
            value: postRepository,
            child: BlocProvider(
              create: (_) => PostBloc(postRepository: postRepository),
              child: const PostPage(),
            ), // BlocProvider
          ), // RepositoryProvider.value
        ); // MaterialPageRoute
      default:
        return null;
    }
  }
}