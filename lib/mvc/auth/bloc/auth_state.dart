part of 'auth_bloc.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated }

class AuthState extends Equatable {
  final AuthStatus status;
  final UserModel? user;
  final String? message;

  const AuthState({
    required this.status,
    this.user,
    this.message,
  });

  const AuthState.initial()
      : status = AuthStatus.initial,
        user = null,
        message = null;

  AuthState copyWith({
    AuthStatus? status,
    UserModel? user,
    String? message,
    bool clearMessage = false, // Tambahan untuk membersihkan pesan error/sukses
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user, // Perbaikan: Ambil user lama jika tidak diupdate
      message: clearMessage ? null : (message ?? this.message),
    );
  }

  @override
  List<Object?> get props => [status, user, message];
}