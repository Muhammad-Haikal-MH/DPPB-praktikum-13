// lib/mvc/auth/auth_event.dart

part of 'auth_bloc.dart';

// import 'package:equatable/equatable.dart'; // Asumsikan Equatable diimpor

abstract class AuthEvent extends Equatable { //
  const AuthEvent();

  @override
  List<Object?> get props => []; //
}

class AuthCheckRequested extends AuthEvent { //
  const AuthCheckRequested();
}

class AuthLoginRequested extends AuthEvent { //
  final String email;
  final String password;

  const AuthLoginRequested({required this.email, required this.password});

  @override
  List<Object?> get props => [email, password];
}

class AuthRegisterRequested extends AuthEvent { //
  final String name;
  final String email;
  final String password;
  final String passwordConfirmation;

  const AuthRegisterRequested({
    required this.name,
    required this.email,
    required this.password,
    required this.passwordConfirmation,
  });

  @override
  List<Object?> get props => [name, email, password, passwordConfirmation];
}

class AuthLogoutRequested extends AuthEvent { //
  const AuthLogoutRequested();
}

class AuthProfileRequested extends AuthEvent { //
  const AuthProfileRequested();
}