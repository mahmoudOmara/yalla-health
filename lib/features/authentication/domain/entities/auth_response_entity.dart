import 'package:equatable/equatable.dart';

class AuthResponseEntity extends Equatable {
  final String token;
  final String tokenType;
  final String? expiresAt;

  const AuthResponseEntity({
    required this.token,
    required this.tokenType,
    this.expiresAt,
  });

  @override
  List<Object?> get props => [token, tokenType, expiresAt];
}