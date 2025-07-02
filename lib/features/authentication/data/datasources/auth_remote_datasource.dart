import 'package:dio/dio.dart';
import 'package:yalla_health/core/errors/exceptions.dart';
import 'package:yalla_health/features/authentication/data/models/auth_response_model.dart';
import 'package:yalla_health/features/authentication/data/models/user_model.dart';
import 'package:yalla_health/services/api_service.dart';

abstract class IAuthRemoteDataSource {
  Future<void> sendLoginOtp(String phone);
  Future<void> sendRegisterOtp({
    required String name,
    required String phone,
    required String gender,
    required int age,
    String? email,
  });
  Future<String> verifyOtp({
    required String phone,
    required String otpCode,
  });
  Future<UserModel> getUserDetails();
  Future<List<UserModel>> getSharedUsers();
}

class AuthRemoteDataSource implements IAuthRemoteDataSource {
  final ApiService apiService;

  const AuthRemoteDataSource({required this.apiService});

  @override
  Future<void> sendLoginOtp(String phone) async {
    try {
      final response = await apiService.login(phone);
      
      if (response.statusCode != 200) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to send OTP',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 404) {
        throw const AuthenticationException(
          'Phone number not found. Please register first.',
        );
      } else if (e.response?.statusCode == 429) {
        throw const ServerException(
          message: 'Too many requests. Please try again later.',
          statusCode: 429,
        );
      } else {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Network error occurred',
          statusCode: e.response?.statusCode,
        );
      }
    } catch (e) {
      throw ServerException(
        message: e.toString(),
      );
    }
  }

  @override
  Future<void> sendRegisterOtp({
    required String name,
    required String phone,
    required String gender,
    required int age,
    String? email,
  }) async {
    try {
      final data = {
        'name': name,
        'phone': phone,
        'gender': gender,
        'age': age,
        if (email != null && email.isNotEmpty) 'email': email,
      };

      final response = await apiService.register(data);
      
      if (response.statusCode != 201) {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to register',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 409) {
        throw const AuthenticationException(
          'Phone number already exists. Please login instead.',
        );
      } else if (e.response?.statusCode == 422) {
        final errors = e.response?.data['errors'] as Map<String, dynamic>?;
        throw ValidationException(
          message: 'Validation failed',
          errors: errors?.map((key, value) => MapEntry(key, List<String>.from(value))),
        );
      } else {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Network error occurred',
          statusCode: e.response?.statusCode,
        );
      }
    } catch (e) {
      throw ServerException(
        message: e.toString(),
      );
    }
  }

  @override
  Future<String> verifyOtp({
    required String phone,
    required String otpCode,
  }) async {
    try {
      final response = await apiService.verifyOtp(phone, otpCode);
      
      if (response.statusCode == 200) {
        final authResponse = AuthResponseModel.fromJson(response.data['data']);
        return authResponse.token;
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'OTP verification failed',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 400) {
        throw const AuthenticationException(
          'Invalid OTP. Please check and try again.',
        );
      } else if (e.response?.statusCode == 410) {
        throw const AuthenticationException(
          'OTP expired. Please request a new one.',
        );
      } else {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Network error occurred',
          statusCode: e.response?.statusCode,
        );
      }
    } catch (e) {
      throw ServerException(
        message: e.toString(),
      );
    }
  }

  @override
  Future<UserModel> getUserDetails() async {
    try {
      final response = await apiService.getUserDetails();
      
      if (response.statusCode == 200) {
        return UserModel.fromJson(response.data['data']);
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to get user details',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const AuthenticationException(
          'Authentication failed. Please login again.',
        );
      } else {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Network error occurred',
          statusCode: e.response?.statusCode,
        );
      }
    } catch (e) {
      throw ServerException(
        message: e.toString(),
      );
    }
  }

  @override
  Future<List<UserModel>> getSharedUsers() async {
    try {
      final response = await apiService.getSharedUsers();
      
      if (response.statusCode == 200) {
        final List<dynamic> usersJson = response.data['data'] ?? [];
        return usersJson.map((json) => UserModel.fromJson(json)).toList();
      } else {
        throw ServerException(
          message: response.data['message'] ?? 'Failed to get shared users',
          statusCode: response.statusCode,
        );
      }
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) {
        throw const AuthenticationException(
          'Authentication failed. Please login again.',
        );
      } else {
        throw ServerException(
          message: e.response?.data['message'] ?? 'Network error occurred',
          statusCode: e.response?.statusCode,
        );
      }
    } catch (e) {
      throw ServerException(
        message: e.toString(),
      );
    }
  }
}