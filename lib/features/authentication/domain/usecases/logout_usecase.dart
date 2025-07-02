import 'package:dartz/dartz.dart';
import 'package:yalla_health/core/errors/failures.dart';
import 'package:yalla_health/core/utils/usecase.dart';
import 'package:yalla_health/features/authentication/domain/repositories/auth_repository.dart';

class LogoutUseCase implements UseCase<void, NoParams> {
  final IAuthRepository repository;

  const LogoutUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(NoParams params) async {
    return await repository.logout();
  }
}