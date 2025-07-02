import 'package:dartz/dartz.dart';
import 'package:yalla_health/core/errors/failures.dart';
import 'package:yalla_health/core/utils/usecase.dart';
import 'package:yalla_health/features/authentication/domain/entities/user_entity.dart';
import 'package:yalla_health/features/authentication/domain/repositories/auth_repository.dart';

class GetUserDetailsUseCase implements UseCase<UserEntity, NoParams> {
  final IAuthRepository repository;

  const GetUserDetailsUseCase(this.repository);

  @override
  Future<Either<Failure, UserEntity>> call(NoParams params) async {
    return await repository.getUserDetails();
  }
}