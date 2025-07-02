import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:yalla_health/core/errors/failures.dart';
import 'package:yalla_health/core/utils/usecase.dart';
import 'package:yalla_health/features/authentication/domain/repositories/auth_repository.dart';

class RegisterUseCase implements UseCase<void, RegisterParams> {
  final IAuthRepository repository;

  const RegisterUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RegisterParams params) async {
    return await repository.sendRegisterOtp(
      name: params.name,
      phone: params.phone,
      gender: params.gender,
      age: params.age,
      email: params.email,
    );
  }
}

class RegisterParams extends Equatable {
  final String name;
  final String phone;
  final String gender;
  final int age;
  final String? email;

  const RegisterParams({
    required this.name,
    required this.phone,
    required this.gender,
    required this.age,
    this.email,
  });

  @override
  List<Object?> get props => [name, phone, gender, age, email];
}