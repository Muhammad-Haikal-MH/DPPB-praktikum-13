import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:restapi/mvc/post/bloc/post_bloc.dart';
import 'package:restapi/mvc/post/data/post_repository.dart';
import 'package:restapi/mvc/post/view/homepage.dart';
import 'package:restapi/mvc/post/view/post_form_page.dart';
import 'package:restapi/mvc/post/view/post_page.dart';
import 'dart:io';

import 'core/app_router.dart';
import 'core/dio_client.dart';
import 'mvc/auth/bloc/auth_bloc.dart';
import 'mvc/auth/data/auth_repository.dart';
import 'mvc/auth/data/auth_storage.dart';
import 'mvc/auth/view/login_page.dart';
import 'mvc/auth/view/register_page.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  HttpOverrides.global = CustomHttpOverrides();
  
const baseUrl = 'http://192.168.1.52:8000/api';// Ganti dengan URL API Laravel Anda

  final authStorage = AuthStorage();
  final token = await authStorage.getToken();

  final dioClient = DioClient(baseUrl: baseUrl, token: token);
  final authRepository = AuthRepository(dioClient);
  final postRepository = PostRepository(dioClient);

  final appRouter = AppRouter(
    authRepository: authRepository,
    authStorage: authStorage,
    postRepository: postRepository,
  );

  runApp(
    MyApp(
      appRouter: appRouter,
      authRepository: authRepository,
      authStorage: authStorage,
      postRepository: postRepository,
      dioClient: dioClient,
      initialToken: token,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.appRouter,
    required this.authRepository,
    required this.authStorage,
    required this.postRepository,
    required this.dioClient,
    this.initialToken,
  });

  final AppRouter appRouter;
  final AuthRepository authRepository;
  final AuthStorage authStorage;
  final PostRepository postRepository;
  final DioClient dioClient;
  final String? initialToken;

  static final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey =
      GlobalKey<ScaffoldMessengerState>();

  @override
  Widget build(BuildContext context) {
    return MultiRepositoryProvider(
      providers: [
        RepositoryProvider.value(value: authRepository),
        RepositoryProvider.value(value: authStorage),
        RepositoryProvider.value(value: postRepository),
        RepositoryProvider.value(value: dioClient),
      ],
      child: MultiBlocProvider(
        providers: [
          BlocProvider(
            create: (_) => AuthBloc(
              authRepository: authRepository,
              authStorage: authStorage,
            )..add(const AuthCheckRequested()),
          ),
          BlocProvider(create: (_) => PostBloc(postRepository: postRepository)),
        ],
        child: BlocListener<AuthBloc, AuthState>(
          listener: (context, state) {
            if (state.status == AuthStatus.authenticated) {
              authStorage.getToken().then((token) {
                if (token != null) {
                  dioClient.updateToken(token);
                }
              });

              final successMsg = state.message ?? 'Login berhasil';
              _scaffoldMessengerKey.currentState?.removeCurrentSnackBar();
              _scaffoldMessengerKey.currentState?.showSnackBar(
                SnackBar(
                  content: Text(successMsg),
                  behavior: SnackBarBehavior.floating,
                  backgroundColor: Colors.green[600],
                ),
              );

              Future.delayed(const Duration(milliseconds: 200), () {
                if (context.mounted) {
                  try {
                    Navigator.of(context).pushNamedAndRemoveUntil(
                      '/main',
                      (Route<dynamic> route) => false,
                    );
                  } catch (e) {
                    print('Navigator error: $e');
                  }
                }
              });
            } else if (state.status == AuthStatus.unauthenticated) {
              dioClient.clearToken();

              if (state.message != null && state.message!.isNotEmpty) {
                final msg = state.message!;
                final isLogoutMessage = msg.contains('Logout');
                _scaffoldMessengerKey.currentState?.removeCurrentSnackBar();
                _scaffoldMessengerKey.currentState?.showSnackBar(
                  SnackBar(
                    content: Text(msg),
                    behavior: SnackBarBehavior.floating,
                    backgroundColor: isLogoutMessage
                        ? Colors.green[600]
                        : Colors.red[700],
                  ),
                );
              }

              Future.microtask(() {
                Navigator.of(context).pushNamedAndRemoveUntil(
                  '/',
                  (Route<dynamic> route) => false,
                );
              });
            }
          },
          child: MaterialApp(
            title: 'Flutter Laravel API',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(seedColor: Colors.indigo),
              useMaterial3: true,
            ),
            scaffoldMessengerKey: _scaffoldMessengerKey,
            initialRoute: '/',
            routes: {
              '/': (context) => BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      if (state.status == AuthStatus.loading ||
                          state.status == AuthStatus.initial) {
                        return const Scaffold(
                          body: Center(child: CircularProgressIndicator()),
                        );
                      } else if (state.status ==
                          AuthStatus.authenticated) {
                        return BlocProvider.value(
                          value: context.read<PostBloc>()
                            ..add(const PostFetched()),
                          child: const MainScreen(),
                        );
                      } else {
                        return const LoginPage();
                      }
                    },
                  ),
              '/login': (context) => const LoginPage(),
              '/register': (context) => const RegisterPage(),
              '/main': (context) => const MainScreen(),
              '/posts': (context) => const PostPage(),
              '/posts/form': (context) => const PostFormPage(),
            },
          ),
        ),
      ),
    );
  }
}

class CustomHttpOverrides extends HttpOverrides {
  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..connectionTimeout = const Duration(seconds: 30)
      ..findProxy = HttpClient.findProxyFromEnvironment;
  }
}