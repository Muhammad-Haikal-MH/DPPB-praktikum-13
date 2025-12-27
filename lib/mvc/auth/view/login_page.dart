import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:restapi/mvc/auth/bloc/auth_event.dart';
import 'package:restapi/mvc/post/view/post_page.dart';
// Cukup import auth_bloc.dart karena event dan state sudah menjadi "part" di dalamnya
import '../bloc/auth_bloc.dart'; 

class LoginPage extends StatefulWidget {
  static const String routeName = '/login';
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _emailController = TextEditingController(text: 'user@example.com'); 
  final _passwordController = TextEditingController(text: 'password'); 
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  void _onLogin() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(AuthLoginRequested(
            email: _emailController.text,
            password: _passwordController.text,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login'),
        automaticallyImplyLeading: false, 
      ),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            // Gunakan named route jika sudah didefinisikan di AppRouter
            Navigator.of(context).pushReplacementNamed(PostPage.routeName);
          } else if (state.message != null && state.status == AuthStatus.unauthenticated) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message!), backgroundColor: Colors.red),
            );
          }
        },
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(32.0),
            child: Form(
              key: _formKey,
              child: Column(
                children: [
                  const Text(
                    'Selamat Datang',
                    style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 30),
                  TextFormField(
                    controller: _emailController,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.email),
                    ),
                    keyboardType: TextInputType.emailAddress,
                    validator: (value) => (value == null || value.isEmpty) ? 'Email wajib diisi' : null,
                  ),
                  const SizedBox(height: 20),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: 'Password',
                      border: OutlineInputBorder(),
                      prefixIcon: Icon(Icons.lock),
                    ),
                    validator: (value) => (value == null || value.isEmpty) ? 'Password wajib diisi' : null,
                  ),
                  const SizedBox(height: 30),
                  BlocBuilder<AuthBloc, AuthState>(
                    builder: (context, state) {
                      return SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: state.status == AuthStatus.loading ? null : _onLogin,
                          style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                          child: state.status == AuthStatus.loading
                              ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(strokeWidth: 2))
                              : const Text('Login', style: TextStyle(fontSize: 18)),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),
                  TextButton(
                    onPressed: () => Navigator.of(context).pushNamed('/register'),
                    child: const Text('Belum punya akun? Daftar di sini'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}