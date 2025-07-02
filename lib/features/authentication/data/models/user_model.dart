import 'package:json_annotation/json_annotation.dart';
import 'package:yalla_health/features/authentication/domain/entities/user_entity.dart';

part 'user_model.g.dart';

@JsonSerializable()
class UserModel {
  final String id;
  final String name;
  final String phone;
  final String? email;
  final String gender;
  final int age;
  @JsonKey(name: 'created_at')
  final String createdAt;
  @JsonKey(name: 'updated_at')
  final String updatedAt;

  const UserModel({
    required this.id,
    required this.name,
    required this.phone,
    this.email,
    required this.gender,
    required this.age,
    required this.createdAt,
    required this.updatedAt,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) =>
      _$UserModelFromJson(json);

  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  UserEntity toDomain() {
    return UserEntity(
      id: id,
      name: name,
      phone: phone,
      email: email,
      gender: gender,
      age: age,
      createdAt: DateTime.parse(createdAt),
      updatedAt: DateTime.parse(updatedAt),
    );
  }

  factory UserModel.fromDomain(UserEntity entity) {
    return UserModel(
      id: entity.id,
      name: entity.name,
      phone: entity.phone,
      email: entity.email,
      gender: entity.gender,
      age: entity.age,
      createdAt: entity.createdAt.toIso8601String(),
      updatedAt: entity.updatedAt.toIso8601String(),
    );
  }
}