import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
// import 'package:restapi/mvc/auth/bloc/auth_event.dart';
import '../bloc/auth_bloc.dart'; // Cukup import ini

class RegisterPage extends StatefulWidget {
  static const String routeName = '/register';
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _passwordConfirmationController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _passwordConfirmationController.dispose();
    super.dispose();
  }

  void _onRegister() {
    if (_formKey.currentState!.validate()) {
      context.read<AuthBloc>().add(AuthRegisterRequested(
            name: _nameController.text,
            email: _emailController.text,
            password: _passwordController.text,
            passwordConfirmation: _passwordConfirmationController.text,
          ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Daftar Akun Baru')),
      body: BlocListener<AuthBloc, AuthState>(
        listener: (context, state) {
          if (state.status == AuthStatus.authenticated) {
            // Jika sukses dan otomatis login, bersihkan stack dan ke PostPage
            Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
          } else if (state.message != null && state.status != AuthStatus.loading) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(state.message!), backgroundColor: Colors.red),
            );
          }
        },
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(32.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: [
                const Text('Buat Akun', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
                const SizedBox(height: 30),
                _buildTextField(_nameController, 'Nama Lengkap', Icons.person),
                const SizedBox(height: 20),
                _buildTextField(_emailController, 'Email', Icons.email, inputType: TextInputType.emailAddress),
                const SizedBox(height: 20),
                _buildTextField(_passwordController, 'Password', Icons.lock, obscure: true),
                const SizedBox(height: 20),
                _buildTextField(_passwordConfirmationController, 'Konfirmasi Password', Icons.lock_outline, obscure: true, isConfirm: true),
                const SizedBox(height: 30),
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    return SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: state.status == AuthStatus.loading ? null : _onRegister,
                        style: ElevatedButton.styleFrom(padding: const EdgeInsets.symmetric(vertical: 15)),
                        child: state.status == AuthStatus.loading
                            ? const CircularProgressIndicator()
                            : const Text('Daftar', style: TextStyle(fontSize: 18)),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTextField(TextEditingController controller, String label, IconData icon, {bool obscure = false, bool isConfirm = false, TextInputType? inputType}) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: inputType,
      decoration: InputDecoration(labelText: label, prefixIcon: Icon(icon), border: const OutlineInputBorder()),
      validator: (value) {
        if (value == null || value.isEmpty) return '$label wajib diisi';
        if (isConfirm && value != _passwordController.text) return 'Password tidak cocok';
        return null;
      },
    );
  }
}