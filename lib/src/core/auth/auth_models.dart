import 'package:equatable/equatable.dart';

class AuthUser extends Equatable {
  const AuthUser({this.id, this.nome, this.tipo});

  final int? id;
  final String? nome;
  final String? tipo;

  factory AuthUser.fromJson(Map<String, dynamic> json) {
    return AuthUser(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse(json['id']?.toString() ?? ''),
      nome: json['nome'] as String?,
      tipo: json['tipo'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'nome': nome,
      'tipo': tipo,
    };
  }

  @override
  List<Object?> get props => [id, nome, tipo];
}

class AuthSession extends Equatable {
  const AuthSession({required this.token, this.user});

  final String token;
  final AuthUser? user;

  Map<String, dynamic> toJson() {
    return {
      'token': token,
      if (user != null) 'usuario': user!.toJson(),
    };
  }

  AuthSession copyWith({
    String? token,
    AuthUser? user,
  }) {
    return AuthSession(
      token: token ?? this.token,
      user: user ?? this.user,
    );
  }

  @override
  List<Object?> get props => [token, user];
}
