import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import 'package:yalla_health/core/errors/failures.dart';
import 'package:yalla_health/core/utils/usecase.dart';
import 'package:yalla_health/features/authentication/domain/entities/auth_response_entity.dart';
import 'package:yalla_health/features/authentication/domain/repositories/auth_repository.dart';

class VerifyOtpUseCase implements UseCase<String, VerifyOtpParams> {
  final IAuthRepository repository;

  const VerifyOtpUseCase(this.repository);

  @override
  Future<Either<Failure, String>> call(VerifyOtpParams params) async {
    return await repository.verifyOtp(
      phone: params.phone,
      otpCode: params.otpCode,
    );
  }
}

class VerifyOtpParams extends Equatable {
  final String phone;
  final String otpCode;

  const VerifyOtpParams({
    required this.phone,
    required this.otpCode,
  });

  @override
  List<Object> get props => [phone, otpCode];
}