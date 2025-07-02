import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:yalla_health/core/errors/failures.dart';
import 'package:yalla_health/core/utils/usecase.dart';
import 'package:yalla_health/features/authentication/domain/repositories/auth_repository.dart';

class LoginUseCase implements UseCase<void, LoginParams> {
  final IAuthRepository repository;

  const LoginUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(LoginParams params) async {
    return await repository.sendLoginOtp(params.phone);
  }
}

class LoginParams extends Equatable {
  final String phone;

  const LoginParams({required this.phone});

  @override
  List<Object> get props => [phone];
}