import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();

  // =========================
  // QUIZ MODULE (clone gốc)
  // =========================

  // Start quiz session for a question or exam
  Future<Map<String, dynamic>> startQuiz({
    required String sourceId, // questionId or examId
    String sourceType = 'question', // 'question' | 'exam'
  }) async {
    try {
      final token = await _getToken();
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.quizStartEndpoint}')
          .replace(queryParameters: {
        'sourceId': sourceId,
        'sourceType': sourceType,
      });

      final response = await _client.post(
        uri,
        headers: {
          ...ApiConfig.defaultHeaders,
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      ).timeout(Duration(milliseconds: ApiConfig.timeout));

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to start quiz: $e');
    }
  }

  // Submit answers
  Future<Map<String, dynamic>> submitQuiz({
    required String sessionId,
    required List<Map<String, dynamic>> answers,
  }) async {
    try {
      final token = await _getToken();
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.quizSubmitEndpoint}')
            .replace(queryParameters: {'sessionId': sessionId}),
        headers: {
          ...ApiConfig.defaultHeaders,
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode({'answers': answers}),
      ).timeout(Duration(milliseconds: ApiConfig.timeout));

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to submit quiz: $e');
    }
  }

  // Get quiz result
  Future<Map<String, dynamic>> getQuizResult(String sessionId) async {
    try {
      final token = await _getToken();
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.quizResultEndpoint}')
            .replace(queryParameters: {'sessionId': sessionId}),
        headers: {
          ...ApiConfig.defaultHeaders,
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(milliseconds: ApiConfig.timeout));

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to get quiz result: $e');
    }
  }

  // Check if user is authenticated
  Future<bool> isAuthenticated() async {
    final token = await _getToken();
    return token.isNotEmpty;
  }

  // Get stored token
  Future<String> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token') ?? '';
    print('🔍 Token from SharedPreferences: ${token.isEmpty ? "EMPTY" : "${token.substring(0, 10)}..."}');
    return token;
  }

  // Login with email and password
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.loginEndpoint}'),
        headers: {
          ...ApiConfig.defaultHeaders,
          'Content-Type': 'application/json',
        },
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
        headers: {
          ...ApiConfig.defaultHeaders,
          'Content-Type': 'application/json',
        },
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

  // Test API endpoint
  Future<bool> testApiEndpoint() async {
    try {
      final url = '${ApiConfig.baseUrl}/signup';
      print('🔍 Testing API endpoint: $url');
      
      final response = await _client.get(
        Uri.parse(url),
        headers: ApiConfig.defaultHeaders,
      ).timeout(Duration(milliseconds: 5000));

      print('🔍 Test Response Status: ${response.statusCode}');
      print('🔍 Test Response Body: ${response.body}');
      
      // Accept both 200 (success) and 405 (method not allowed) as valid responses
      return response.statusCode == 200 || response.statusCode == 405;
    } catch (e) {
      print('❌ Test API Error: $e');
      return false;
    }
  }

  // Register
  Future<Map<String, dynamic>> register(Map<String, dynamic> userData) async {
    try {
      final url = '${ApiConfig.baseUrl}${ApiConfig.registerEndpoint}';
      print('🔍 Register URL: $url');
      print('🔍 Register Data: $userData');
      print('🔍 Register Headers: ${ApiConfig.defaultHeaders}');
      
      final response = await _client.post(
        Uri.parse(url),
        headers: ApiConfig.defaultHeaders,
        body: json.encode(userData),
      ).timeout(Duration(milliseconds: ApiConfig.timeout));

      print('🔍 Register Response Status: ${response.statusCode}');
      print('🔍 Register Response Body: ${response.body}');
      
      return _handleResponse(response);
    } catch (e) {
      print('❌ Register Error: $e');
      throw Exception('Registration failed: $e');
    }
  }

  // Update user profile
  Future<Map<String, dynamic>> updateProfile(Map<String, dynamic> profileData) async {
    try {
      final token = await _getToken();
      final response = await _client.put(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.profileEndpoint}'),
        headers: {
          ...ApiConfig.defaultHeaders,
          'Authorization': 'Bearer $token',
        },
        body: json.encode(profileData),
      ).timeout(Duration(milliseconds: ApiConfig.timeout));

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to update profile: $e');
    }
  }

  // Get user profile
  Future<Map<String, dynamic>> getUserProfile() async {
    try {
      final token = await _getToken();
      print('🔍 Getting user profile with token: ${token.isEmpty ? "EMPTY" : "${token.substring(0, 10)}..."}');
      
      if (token.isEmpty) {
        throw Exception('No authentication token found. Please login first.');
      }
      
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

  // Get questions for a lesson
  Future<Map<String, dynamic>> getLessonQuestions(String lessonId) async {
    try {
      final token = await _getToken();
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}/lessons/$lessonId/questions'),
        headers: {
          ...ApiConfig.defaultHeaders,
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(milliseconds: ApiConfig.timeout));

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to get lesson questions: $e');
    }
  }

  // Get all questions with pagination and filtering
  Future<Map<String, dynamic>> getQuestions({
    int pageNumber = 1,
    int pageSize = 10,
    String? subjectId,
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

      if (subjectId != null) {
        queryParams['subjectId'] = subjectId;
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
      print('❌ Failed to get questions: $e');
      throw Exception('Failed to get questions: $e');
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

  // Get comments for a question
  Future<Map<String, dynamic>> getQuestionComments(String questionId) async {
    try {
      final token = await _getToken();
      
      // Try multiple possible endpoints
      final possibleEndpoints = [
        '${ApiConfig.baseUrl}${ApiConfig.commentsEndpoint}?questionId=$questionId',
        '${ApiConfig.baseUrl}/questions/$questionId/comments',
        '${ApiConfig.baseUrl}${ApiConfig.commentsEndpoint}/question/$questionId',
        '${ApiConfig.baseUrl}/api/comments?questionId=$questionId',
        '${ApiConfig.baseUrl}/api/questions/$questionId/comments',
      ];
      
      for (int i = 0; i < possibleEndpoints.length; i++) {
        try {
          print('🔍 Trying endpoint ${i + 1}: ${possibleEndpoints[i]}');
          final response = await _client.get(
            Uri.parse(possibleEndpoints[i]),
            headers: {
              ...ApiConfig.defaultHeaders,
              'Authorization': 'Bearer $token',
            },
          ).timeout(Duration(milliseconds: ApiConfig.timeout));

          print('🔍 Response status: ${response.statusCode}');
          print('🔍 Response body: ${response.body}');
          
          if (response.statusCode == 200) {
            print('✅ Success with endpoint ${i + 1}');
            return _handleResponse(response);
          }
        } catch (e) {
          print('❌ Endpoint ${i + 1} failed: $e');
          if (i == possibleEndpoints.length - 1) {
            rethrow;
          }
        }
      }
      
      throw Exception('All comment endpoints failed');
    } catch (e) {
      throw Exception('Failed to get question comments: $e');
    }
  }

  // Add comment to a question
  Future<Map<String, dynamic>> addQuestionComment(String questionId, String content) async {
    try {
      final token = await _getToken();
      
      // Try multiple possible endpoints
      final possibleEndpoints = [
        '${ApiConfig.baseUrl}${ApiConfig.commentsEndpoint}',
        '${ApiConfig.baseUrl}/questions/$questionId/comments',
        '${ApiConfig.baseUrl}${ApiConfig.commentsEndpoint}/question/$questionId',
        '${ApiConfig.baseUrl}/api/comments',
        '${ApiConfig.baseUrl}/api/questions/$questionId/comments',
      ];
      
      for (int i = 0; i < possibleEndpoints.length; i++) {
        try {
          print('🔍 Trying add comment endpoint ${i + 1}: ${possibleEndpoints[i]}');
          final response = await _client.post(
            Uri.parse(possibleEndpoints[i]),
            headers: {
              ...ApiConfig.defaultHeaders,
              'Authorization': 'Bearer $token',
              'Content-Type': 'application/json',
            },
            body: json.encode({
              'questionId': questionId,
              'content': content,
            }),
          ).timeout(Duration(milliseconds: ApiConfig.timeout));

          print('🔍 Add comment response status: ${response.statusCode}');
          print('🔍 Add comment response body: ${response.body}');
          
          if (response.statusCode >= 200 && response.statusCode < 300) {
            print('✅ Add comment success with endpoint ${i + 1}');
            return _handleResponse(response);
          }
        } catch (e) {
          print('❌ Add comment endpoint ${i + 1} failed: $e');
          if (i == possibleEndpoints.length - 1) {
            rethrow;
          }
        }
      }
      
      throw Exception('All add comment endpoints failed');
    } catch (e) {
      throw Exception('Failed to add comment: $e');
    }
  }

  // Like/unlike a comment
  Future<Map<String, dynamic>> toggleCommentLike(String commentId) async {
    try {
      final token = await _getToken();
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.commentsEndpoint}/$commentId/like'),
        headers: {
          ...ApiConfig.defaultHeaders,
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(milliseconds: ApiConfig.timeout));

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to toggle comment like: $e');
    }
  }

  // Delete a comment
  Future<Map<String, dynamic>> deleteComment(String commentId) async {
    try {
      final token = await _getToken();
      final response = await _client.delete(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.commentsEndpoint}/$commentId'),
        headers: {
          ...ApiConfig.defaultHeaders,
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(milliseconds: ApiConfig.timeout));

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to delete comment: $e');
    }
  }


  // Handle API response
  Map<String, dynamic> _handleResponse(http.Response response) {
    print('🔍 Response Status: ${response.statusCode}');
    print('🔍 Response Body: ${response.body}');
    
    if (response.statusCode >= 200 && response.statusCode < 300) {
      try {
        final data = json.decode(response.body);
        print('🔍 Parsed Response: $data');
        return data;
      } catch (e) {
        print('❌ JSON Parse Error: $e');
        throw Exception('Invalid JSON response: $e');
      }
    } else {
      try {
        final errorData = json.decode(response.body);
        print('❌ Error Response: $errorData');
        throw Exception(errorData['message'] ?? 'API request failed');
      } catch (e) {
        print('❌ Error Parse Error: $e');
        throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
      }
    }
  }

  void dispose() {
    _client.close();
  }
}
