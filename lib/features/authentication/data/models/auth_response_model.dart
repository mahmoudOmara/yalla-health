import 'package:json_annotation/json_annotation.dart';
import 'package:yalla_health/features/authentication/data/models/user_model.dart';
import 'package:yalla_health/features/authentication/domain/entities/auth_response_entity.dart';

part 'auth_response_model.g.dart';

@JsonSerializable()
class AuthResponseModel {
  final String token;
  @JsonKey(name: 'token_type')
  final String tokenType;
  @JsonKey(name: 'expires_at')
  final String? expiresAt;

  const AuthResponseModel({
    required this.token,
    required this.tokenType,
    this.expiresAt,
  });

  factory AuthResponseModel.fromJson(Map<String, dynamic> json) =>
      _$AuthResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$AuthResponseModelToJson(this);
}

@JsonSerializable()
class UserDetailsResponseModel {
  final bool success;
  final UserModel data;

  const UserDetailsResponseModel({
    required this.success,
    required this.data,
  });

  factory UserDetailsResponseModel.fromJson(Map<String, dynamic> json) =>
      _$UserDetailsResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserDetailsResponseModelToJson(this);
}

@JsonSerializable()
class SharedUsersResponseModel {
  final bool success;
  final String message;
  final List<UserModel> data;

  const SharedUsersResponseModel({
    required this.success,
    required this.message,
    required this.data,
  });

  factory SharedUsersResponseModel.fromJson(Map<String, dynamic> json) =>
      _$SharedUsersResponseModelFromJson(json);

  Map<String, dynamic> toJson() => _$SharedUsersResponseModelToJson(this);
}