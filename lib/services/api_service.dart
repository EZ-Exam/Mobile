import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();

  // Get stored token
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token') ?? '';
  }

  // Login with email and password
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}'),
        headers: ApiConfig.defaultHeaders,
        body: json.encode({
          'email': email,
          'password': password,
        }),
      ).timeout(Duration(milliseconds: ApiConfig.timeout));

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Login failed: $e');
    }
  }

  // Google Sign-In
  Future<Map<String, dynamic>> googleLogin(String credential) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.googleLoginEndpoint}'),
        headers: ApiConfig.defaultHeaders,
        body: json.encode({
          'credential': credential,
          'clientId': ApiConfig.googleClientId,
        }),
      ).timeout(Duration(milliseconds: ApiConfig.timeout));

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Google login failed: $e');
    }
  }

  // Register
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.registerEndpoint}'),
        headers: ApiConfig.defaultHeaders,
        body: json.encode(userData),
      ).timeout(Duration(milliseconds: ApiConfig.timeout));

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Registration failed: $e');
    }
  }

  // Get user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final token = await _getToken();
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.profileEndpoint}'),
        headers: {
          ...ApiConfig.defaultHeaders,
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(milliseconds: ApiConfig.timeout));

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  // Get user details by ID
  Future<Map<String, dynamic>> getUserDetails(String userId) async {
    try {
      final token = await _getToken();
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}/users/$userId'),
        headers: {
          ...ApiConfig.defaultHeaders,
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(milliseconds: ApiConfig.timeout));

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Get user details failed: $e');
    }
  }

  // Get lesson details by ID
  Future<Map<String, dynamic>> getLessonDetails(String lessonId) async {
    try {
      final token = await _getToken();
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}/lessons/$lessonId'),
        headers: {
          ...ApiConfig.defaultHeaders,
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(milliseconds: ApiConfig.timeout));

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Get lesson details failed: $e');
    }
  }

  // Get lessons
  Future<Map<String, dynamic>> getLessons({
    int pageNumber = 1,
    int pageSize = 6,
    String? subjectId,
    String sortBy = 'title',
    String sortOrder = 'asc',
  }) async {
    try {
      final queryParams = <String, String>{
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
        'sort': '$sortBy:$sortOrder',
        'isSort': '1',
      };

      if (subjectId != null) {
        queryParams['subjectId'] = subjectId;
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.lessonsEndpoint}')
          .replace(queryParameters: queryParams);

      final response = await _client.get(
        uri,
        headers: ApiConfig.defaultHeaders,
      ).timeout(Duration(milliseconds: ApiConfig.timeout));

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to get lessons: $e');
    }
  }

  // Get mock tests
  Future<Map<String, dynamic>> getMockTests({
    int pageNumber = 1,
    int pageSize = 6,
    String? search,
    String? subjectId,
    String? difficultyLevel,
    String sortBy = 'name',
    String sortOrder = 'asc',
  }) async {
    try {
      final queryParams = <String, String>{
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
        'sort': '$sortBy:$sortOrder',
        'isSort': '1',
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (subjectId != null) {
        queryParams['subjectId'] = subjectId;
      }
      if (difficultyLevel != null) {
        queryParams['difficultyLevel'] = difficultyLevel;
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.mockTestsEndpoint}')
          .replace(queryParameters: queryParams);

      final response = await _client.get(
        uri,
        headers: ApiConfig.defaultHeaders,
      ).timeout(Duration(milliseconds: ApiConfig.timeout));

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to get mock tests: $e');
    }
  }

  // Get questions
  Future<Map<String, dynamic>> getQuestions({
    int pageNumber = 1,
    int pageSize = 6,
    String? search,
    String? difficultyLevelId,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) async {
    try {
      final queryParams = <String, String>{
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
        'sort': '$sortBy:$sortOrder',
        'isSort': '1',
      };

      if (search != null && search.isNotEmpty) {
        queryParams['search'] = search;
      }
      if (difficultyLevelId != null) {
        queryParams['difficultyLevelId'] = difficultyLevelId;
      }

      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.questionsEndpoint}')
          .replace(queryParameters: queryParams);

      final response = await _client.get(
        uri,
        headers: ApiConfig.defaultHeaders,
      ).timeout(Duration(milliseconds: ApiConfig.timeout));

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to get questions: $e');
    }
  }

  // Handle API response
  Map<String, dynamic> _handleResponse(http.Response response) {
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        return json.decode(response.body);
      } catch (e) {
        throw Exception('Invalid JSON response: $e');
      }
    } else {
      try {
        final errorData = json.decode(response.body);
        throw Exception(errorData['message'] ?? 'API request failed');
      } catch (e) {
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    }
  }

  void dispose() {
    _client.close();
  }
}
