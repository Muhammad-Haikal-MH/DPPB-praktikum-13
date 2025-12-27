// lib/mvc/data/user_model.dart

class UserModel {
  final int id;
  final String name;
  final String email;
  final String? emailVerifiedAt;
  final String? createdAt;
  final String? updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    this.emailVerifiedAt,
    this.createdAt,
    this.updatedAt,
  });

  // Factory constructor untuk membuat instance dari JSON Map
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: (json['id'] ?? 0) as int,
      name: (json['name'] ?? '') as String,
      email: (json['email'] ?? '') as String,
      emailVerifiedAt: json['email_verified_at'] as String?,
      createdAt: json['created_at'] as String?,
      updatedAt: json['updated_at'] as String?,
    );
  }

  // Metode untuk mengkonversi instance menjadi JSON Map
  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'email': email,
        'email_verified_at': emailVerifiedAt,
        'created_at': createdAt,
        'updated_at': updatedAt,
      };
}