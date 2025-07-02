import 'package:dartz/dartz.dart';
import 'package:yalla_health/core/errors/exceptions.dart';
import 'package:yalla_health/core/errors/failures.dart';
import 'package:yalla_health/features/authentication/data/datasources/auth_remote_datasource.dart';
import 'package:yalla_health/features/authentication/data/models/user_model.dart';
import 'package:yalla_health/features/authentication/domain/entities/user_entity.dart';
import 'package:yalla_health/features/authentication/domain/repositories/auth_repository.dart';
import 'package:yalla_health/services/storage_service.dart';
import 'package:yalla_health/services/user_service.dart';

class AuthRepository implements IAuthRepository {
  final IAuthRemoteDataSource remoteDataSource;
  final StorageService storageService;
  final UserService userService;

  const AuthRepository({
    required this.remoteDataSource,
    required this.storageService,
    required this.userService,
  });

  @override
  Future<Either<Failure, void>> sendLoginOtp(String phone) async {
    try {
      await remoteDataSource.sendLoginOtp(phone);
      return const Right(null);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> sendRegisterOtp({
    required String name,
    required String phone,
    required String gender,
    required int age,
    String? email,
  }) async {
    try {
      await remoteDataSource.sendRegisterOtp(
        name: name,
        phone: phone,
        gender: gender,
        age: age,
        email: email,
      );
      return const Right(null);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on ValidationException catch (e) {
      return Left(ValidationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, String>> verifyOtp({
    required String phone,
    required String otpCode,
  }) async {
    try {
      final token = await remoteDataSource.verifyOtp(
        phone: phone,
        otpCode: otpCode,
      );
      
      // Store authentication token
      await storageService.saveToken(token);
      
      return Right(token);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, UserEntity>> getUserDetails() async {
    try {
      final userModel = await remoteDataSource.getUserDetails();
      return Right(userModel.toDomain());
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, List<UserEntity>>> getSharedUsers() async {
    try {
      final userModels = await remoteDataSource.getSharedUsers();
      final userEntities = userModels.map((model) => model.toDomain()).toList();
      return Right(userEntities);
    } on AuthenticationException catch (e) {
      return Left(AuthenticationFailure(e.message));
    } on ServerException catch (e) {
      return Left(ServerFailure(e.message));
    } on NetworkException catch (e) {
      return Left(NetworkFailure(e.message));
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, void>> logout() async {
    try {
      // Clear all stored data
      await storageService.clearAll();
      
      // Clear user service
      userService.logout();
      
      return const Right(null);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  @override
  Future<Either<Failure, bool>> checkAuthStatus() async {
    try {
      final isLoggedIn = await storageService.isLoggedIn();
      
      if (isLoggedIn) {
        // Try to get user details to verify token is still valid
        final userDetailsResult = await getUserDetails();
        return userDetailsResult.fold(
          (failure) => const Right(false), // Token is invalid
          (user) {
            // Update user service with stored data
            _loadStoredUserData();
            return const Right(true);
          },
        );
      }
      
      return const Right(false);
    } catch (e) {
      return Left(UnknownFailure(e.toString()));
    }
  }

  Future<void> _loadStoredUserData() async {
    try {
      final userData = await storageService.getUserData();
      final sharedUsersData = await storageService.getSharedUsers();
      
      if (userData != null) {
        final userEntity = UserModel.fromJson(userData).toDomain();
        final user = _convertUserEntityToUser(userEntity);
        userService.setCurrentUser(user);
        
        if (sharedUsersData != null) {
          final sharedUserEntities = sharedUsersData.map((data) => UserModel.fromJson(data).toDomain()).toList();
          final sharedUsers = sharedUserEntities.map(_convertUserEntityToUser).toList();
          userService.setSharedUsers(sharedUsers);
        }
      }
    } catch (e) {
      // Handle error silently, user will need to re-login
    }
  }

  /// Converts UserEntity to User for the UserService
  User _convertUserEntityToUser(UserEntity userEntity) {
    return User(
      id: userEntity.id,
      name: userEntity.name,
      phone: userEntity.phone,
      email: userEntity.email ?? '', // Convert nullable email to empty string
      gender: userEntity.gender,
      age: userEntity.age,
      createdAt: userEntity.createdAt,
      updatedAt: userEntity.updatedAt,
    );
  }
}