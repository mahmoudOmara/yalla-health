import 'package:dio/dio.dart';
import 'package:device_info_plus/device_info_plus.dart';
import 'dart:io';
import 'package:get_it/get_it.dart';
import 'package:yalla_health/services/storage_service.dart';

class ApiService {
  static const String _baseUrl = 'http://yallahealth-staging.eba-jfimxmfs.eu-central-1.elasticbeanstalk.com/api/';
  late final Dio _dio;
  final DeviceInfoPlugin _deviceInfo = DeviceInfoPlugin();
  final StorageService _storageService = GetIt.instance<StorageService>();
  
  ApiService() {
    _dio = Dio(BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 30),
      receiveTimeout: const Duration(seconds: 30),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    ));
    
    _setupInterceptors();
  }

  void _setupInterceptors() {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add device information headers
          final deviceHeaders = await _getDeviceHeaders();
          options.headers.addAll(deviceHeaders);
          
          // Add authentication token if available
          final token = await _storageService.getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          // Add selected account UUID if available
          final selectedAccountId = await _storageService.getSelectedAccountId();
          if (selectedAccountId != null) {
            options.headers['X-User-UUID'] = selectedAccountId;
          }
          
          handler.next(options);
        },
        onError: (error, handler) {
          // Handle common errors
          if (error.response?.statusCode == 401) {
            // Token expired, clear storage and redirect to login
            _handleUnauthorized();
          }
          handler.next(error);
        },
      ),
    );
  }

  Future<Map<String, String>> _getDeviceHeaders() async {
    final headers = <String, String>{};
    
    try {
      if (Platform.isAndroid) {
        final androidInfo = await _deviceInfo.androidInfo;
        headers['X-Device-Name'] = '${androidInfo.brand} ${androidInfo.model}';
        headers['X-Platform'] = 'Android ${androidInfo.version.release}';
      } else if (Platform.isIOS) {
        final iosInfo = await _deviceInfo.iosInfo;
        headers['X-Device-Name'] = '${iosInfo.name} ${iosInfo.model}';
        headers['X-Platform'] = 'iOS ${iosInfo.systemVersion}';
      }
      
      // App version - TODO: Get from package_info_plus
      headers['X-App-Version'] = '1.0.0 (1)';
    } catch (e) {
      // Fallback headers
      headers['X-Device-Name'] = 'Unknown Device';
      headers['X-Platform'] = Platform.operatingSystem;
      headers['X-App-Version'] = '1.0.0 (1)';
    }
    
    return headers;
  }

  void _handleUnauthorized() async {
    await _storageService.clearAll();
    // TODO: Navigate to login screen
  }

  // Authentication endpoints
  Future<Response> login(String phone, {String? deviceName}) async {
    return await _dio.post('/login', data: {
      'phone': phone,
      'device_name': deviceName,
    });
  }

  Future<Response> register(Map<String, dynamic> data) async {
    return await _dio.post('/register', data: data);
  }

  Future<Response> verifyOtp(String phone, String otp) async {
    return await _dio.post('/verify-otp', data: {
      'phone': phone,
      'otp': otp,
    });
  }

  Future<Response> getUserDetails() async {
    return await _dio.get('/user/details');
  }

  Future<Response> getSharedUsers() async {
    return await _dio.get('/user/shared-users');
  }

  Future<Response> logout() async {
    return await _dio.post('/auth/logout');
  }

  // Health Issue endpoints
  Future<Response> getHealthIssues() async {
    return await _dio.get('/api/health-issues');
  }

  Future<Response> createHealthIssue(Map<String, dynamic> data) async {
    return await _dio.post('/api/health-issues', data: data);
  }

  Future<Response> updateHealthIssue(String id, Map<String, dynamic> data) async {
    return await _dio.put('/api/health-issues/$id', data: data);
  }

  Future<Response> getHealthIssueDetail(String id) async {
    return await _dio.get('/api/health-issues/$id');
  }

  Future<Response> deleteHealthIssue(String id) async {
    return await _dio.delete('/api/health-issues/$id');
  }

  // File upload
  Future<Response> uploadFile(String healthIssueId, String filePath, {String? description}) async {
    final formData = FormData.fromMap({
      'file': await MultipartFile.fromFile(filePath),
      'health_issue_id': healthIssueId,
      if (description != null) 'description': description,
    });
    
    return await _dio.post('/api/files/upload', data: formData);
  }

  // Generic methods
  Future<Response> get(String path, {Map<String, dynamic>? queryParameters}) async {
    return await _dio.get(path, queryParameters: queryParameters);
  }

  Future<Response> post(String path, {dynamic data}) async {
    return await _dio.post(path, data: data);
  }

  Future<Response> put(String path, {dynamic data}) async {
    return await _dio.put(path, data: data);
  }

  Future<Response> delete(String path) async {
    return await _dio.delete(path);
  }
}