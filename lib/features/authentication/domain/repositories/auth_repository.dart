import 'package:dartz/dartz.dart';
import 'package:yalla_health/core/errors/failures.dart';
import 'package:yalla_health/features/authentication/domain/entities/auth_response_entity.dart';
import 'package:yalla_health/features/authentication/domain/entities/user_entity.dart';

abstract class IAuthRepository {
  Future<Either<Failure, void>> sendLoginOtp(String phone);
  Future<Either<Failure, void>> sendRegisterOtp({
    required String name,
    required String phone,
    required String gender,
    required int age,
    String? email,
  });
  Future<Either<Failure, String>> verifyOtp({
    required String phone,
    required String otpCode,
  });
  Future<Either<Failure, UserEntity>> getUserDetails();
  Future<Either<Failure, List<UserEntity>>> getSharedUsers();
  Future<Either<Failure, void>> logout();
  Future<Either<Failure, bool>> checkAuthStatus();
}