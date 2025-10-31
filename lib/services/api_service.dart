
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';
import 'cache_service.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  final http.Client _client = http.Client();
  final CacheService _cache = CacheService();

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

  // =========================
  // AUTH METHODS
  // =========================

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
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.lessonsEndpoint}/$lessonId');

      final response = await _client.get(
        uri,
        headers: {
          ...ApiConfig.defaultHeaders,
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(milliseconds: ApiConfig.timeout));

      // The frontend returns the lesson object directly; decode flexibly
      final decoded = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded is Map<String, dynamic>) return decoded;
        // If backend wrapped data in { data: { ... } }
        if (decoded is Map && decoded['data'] is Map) {
          return Map<String, dynamic>.from(decoded['data']);
        }
        throw Exception('Unexpected lesson response format');
      } else {
        try {
          final errorData = decoded is Map ? decoded : {'message': response.reasonPhrase};
          throw Exception(errorData['message'] ?? 'Failed to get lesson details');
        } catch (e) {
          throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
        }
      }
    } catch (e) {
      throw Exception('Get lesson details failed: $e');
    }
  }

  // Get questions for a lesson
  Future<Map<String, dynamic>> getLessonQuestions(String lessonId) async {
    try {
      // The frontend uses /lessons-enhanced/:id which includes a `questions` array
      final lesson = await getLessonDetails(lessonId);
      // If the lesson contains a `questions` field return it wrapped
      if (lesson.containsKey('questions')) {
        return {'questions': lesson['questions']};
      }
      // Fallback: call legacy endpoint for lesson questions
      final token = await _getToken();
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}/lessons/$lessonId/questions'),
        headers: {
          ...ApiConfig.defaultHeaders,
          if (token.isNotEmpty) 'Authorization': 'Bearer $token',
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
    String? search,
    String? lessonId,
    String? difficultyLevelId,
    String? chapterId,
    String? gradeId,
    String? userId,
    String? textbookId,
    String sortBy = 'createdAt',
    String sortOrder = 'desc',
  }) async {
    final cacheKey = 'questions_p${pageNumber}_s${pageSize}_${search}_${lessonId}_${difficultyLevelId}_${chapterId}_${gradeId}_${userId}_${textbookId}_${sortBy}_$sortOrder';
    final cachedData = _cache.get(cacheKey);
    if (cachedData != null) {
      return cachedData;
    }

    try {
      final queryParams = <String, String>{
        'pageNumber': pageNumber.toString(),
        'pageSize': pageSize.toString(),
        'sort': '$sortBy:$sortOrder',
        'isSort': '1',
      };

      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (lessonId != null) queryParams['lessonId'] = lessonId;
      if (difficultyLevelId != null) queryParams['difficultyLevelId'] = difficultyLevelId;
      if (chapterId != null) queryParams['chapterId'] = chapterId;
      if (gradeId != null) queryParams['gradeId'] = gradeId;
      if (userId != null) queryParams['userId'] = userId;
      if (textbookId != null) queryParams['textbookId'] = textbookId;

      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.questionsEndpoint}')
          .replace(queryParameters: queryParams);

      final response = await _client.get(
        uri,
        headers: ApiConfig.defaultHeaders,
      ).timeout(Duration(milliseconds: ApiConfig.timeout));

      final data = _handleResponse(response);
      _cache.set(cacheKey, data);
      return data;
    } catch (e) {
      throw Exception('Failed to get questions: $e');
    }
  }

  // Get question details by ID
  Future<Map<String, dynamic>> getQuestionDetails(String questionId) async {
    try {
      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.questionsEndpoint}/$questionId');
      final response = await _client.get(
        uri,
        headers: ApiConfig.defaultHeaders,
      ).timeout(Duration(milliseconds: ApiConfig.timeout));

      // Questions endpoint usually returns an object directly
      final decoded = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded is Map<String, dynamic>) return decoded;
        if (decoded is Map && decoded['data'] is Map) return Map<String, dynamic>.from(decoded['data']);
        throw Exception('Unexpected question response format');
      } else {
        try {
          final errorData = decoded is Map ? decoded : {'message': response.reasonPhrase};
          throw Exception(errorData['message'] ?? 'API request failed');
        } catch (e) {
          throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
        }
      }
    } catch (e) {
      throw Exception('Failed to get question details: $e');
    }
  }

  // Get enhanced lessons
  Future<Map<String, dynamic>> getLessons({
    int pageNumber = 1,
    int pageSize = 10,
    String? chapterId,
    String? subjectId,
    String? gradeId,
    String? sortBy,
    String? sortOrder,
  }) async {
    final cacheKey = 'lessons_p${pageNumber}_s${pageSize}_${chapterId}_${subjectId}_${gradeId}_${sortBy}_$sortOrder';
    final cachedData = _cache.get(cacheKey);
    if (cachedData != null) {
      return cachedData;
    }

    try {
      final queryParams = <String, String>{
        'page': pageNumber.toString(),
        'pageSize': pageSize.toString(),
      };

      if (chapterId != null) queryParams['chapterId'] = chapterId;
      if (subjectId != null) queryParams['subjectId'] = subjectId;
      if (gradeId != null) queryParams['gradeId'] = gradeId;
      if (sortBy != null) queryParams['sortBy'] = sortBy;
      if (sortOrder != null) queryParams['sortOrder'] = sortOrder;

      final uri = Uri.parse('${ApiConfig.baseUrl}${ApiConfig.lessonsEndpoint}')
          .replace(queryParameters: queryParams);

      final response = await _client.get(
        uri,
        headers: ApiConfig.defaultHeaders,
      ).timeout(Duration(milliseconds: ApiConfig.timeout));

      // Some backends may return an array directly instead of an object
      final decoded = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        Map<String, dynamic> normalized;
        if (decoded is List) {
          normalized = {
            'items': List<Map<String, dynamic>>.from(decoded),
            'totalItems': decoded.length,
            'page': 1,
            'pageSize': decoded.length,
            'totalPages': 1,
          };
        } else if (decoded is Map) {
          // If wrapped under data, unwrap if it contains a list
          if (decoded['data'] is List) {
            final list = List<Map<String, dynamic>>.from(decoded['data']);
            normalized = {
              'items': list,
              'totalItems': decoded['totalItems'] ?? list.length,
              'page': decoded['page'] ?? decoded['pageNumber'] ?? 1,
              'pageSize': decoded['pageSize'] ?? list.length,
              'totalPages': decoded['totalPages'] ?? 1,
            };
          } else {
            normalized = Map<String, dynamic>.from(decoded);
          }
        } else {
          throw Exception('Unexpected lessons response format');
        }
        _cache.set(cacheKey, normalized);
        return normalized;
      } else {
        try {
          final errorData = decoded is Map ? decoded : {'message': response.reasonPhrase};
          throw Exception(errorData['message'] ?? 'Failed to get lessons');
        } catch (e) {
          throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
        }
      }
    } catch (e) {
      throw Exception('Failed to get lessons: $e');
    }
  }

  // Get exams (mock tests)
  Future<Map<String, dynamic>> getMockTests({
    int pageNumber = 1,
    int pageSize = 6,
    String? search,
    String? subjectId,
    String? lessonId,
    String? examTypeId,
    String? createdByUserId,
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

      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (subjectId != null) queryParams['subjectId'] = subjectId;
      if (lessonId != null) queryParams['lessonId'] = lessonId;
      if (examTypeId != null) queryParams['examTypeId'] = examTypeId;
      if (createdByUserId != null) queryParams['createdByUserId'] = createdByUserId;

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

  // Get subjects
  Future<List<Map<String, dynamic>>> getSubjects() async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.subjectsEndpoint}'),
        headers: ApiConfig.defaultHeaders,
      ).timeout(Duration(milliseconds: ApiConfig.timeout));

      final data = _handleResponse(response);
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } catch (e) {
      throw Exception('Failed to get subjects: $e');
    }
  }

  // Get semesters by grade
  Future<List<Map<String, dynamic>>> getSemestersByGrade(String gradeId) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.semestersEndpoint}/by-grade/$gradeId'),
        headers: ApiConfig.defaultHeaders,
      ).timeout(Duration(milliseconds: ApiConfig.timeout));

      final decoded = json.decode(response.body);
      if (decoded is List) return List<Map<String, dynamic>>.from(decoded);
      if (decoded is Map && decoded['data'] is List) return List<Map<String, dynamic>>.from(decoded['data']);
      throw Exception('Unexpected semesters response format');
    } catch (e) {
      throw Exception('Failed to get semesters: $e');
    }
  }

  // Get chapters by semester
  Future<List<Map<String, dynamic>>> getChaptersBySemester(String semesterId) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.chaptersEndpoint}/by-semester/$semesterId'),
        headers: ApiConfig.defaultHeaders,
      ).timeout(Duration(milliseconds: ApiConfig.timeout));

      final decoded = json.decode(response.body);
      if (decoded is List) return List<Map<String, dynamic>>.from(decoded);
      if (decoded is Map && decoded['data'] is List) return List<Map<String, dynamic>>.from(decoded['data']);
      throw Exception('Unexpected chapters response format');
    } catch (e) {
      throw Exception('Failed to get chapters: $e');
    }
  }

  // Get chapters by semester and subject
  Future<List<Map<String, dynamic>>> getChaptersBySemesterAndSubject(String semesterId, String subjectId) async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.chaptersEndpoint}/semester/$semesterId/subject/$subjectId'),
        headers: ApiConfig.defaultHeaders,
      ).timeout(Duration(milliseconds: ApiConfig.timeout));

      final decoded = json.decode(response.body);
      if (decoded is List) return List<Map<String, dynamic>>.from(decoded);
      if (decoded is Map && decoded['data'] is List) return List<Map<String, dynamic>>.from(decoded['data']);
      throw Exception('Unexpected chapters response format');
    } catch (e) {
      throw Exception('Failed to get chapters: $e');
    }
  }

  // Get difficulty levels
  Future<List<Map<String, dynamic>>> getDifficultyLevels() async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.difficultyLevelsEndpoint}'),
        headers: ApiConfig.defaultHeaders,
      ).timeout(Duration(milliseconds: ApiConfig.timeout));

      final data = _handleResponse(response);
      return List<Map<String, dynamic>>.from(data['data'] ?? []);
    } catch (e) {
      throw Exception('Failed to get difficulty levels: $e');
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

  // =========================
  // PAYMENT & SUBSCRIPTION
  // =========================

  // Get all subscription types
  Future<List<Map<String, dynamic>>> getSubscriptionTypes() async {
    try {
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.subscriptionTypesEndpoint}'),
        headers: ApiConfig.defaultHeaders,
      ).timeout(Duration(milliseconds: ApiConfig.timeout));

      // This endpoint may return an array directly
      final decoded = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded is List) return List<Map<String, dynamic>>.from(decoded);
        if (decoded is Map && decoded['data'] is List) {
          return List<Map<String, dynamic>>.from(decoded['data']);
        }
        // Fallback to empty list
        return <Map<String, dynamic>>[];
      } else {
        try {
          final errorData = decoded is Map ? decoded : {'message': response.reasonPhrase};
          throw Exception(errorData['message'] ?? 'API request failed');
        } catch (e) {
          throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
        }
      }
    } catch (e) {
      throw Exception('Failed to get subscription types: $e');
    }
  }

  // Get current user subscription
  Future<Map<String, dynamic>> getCurrentSubscription() async {
    try {
      final token = await _getToken();
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.currentSubscriptionEndpoint}'),
        headers: {
          ...ApiConfig.defaultHeaders,
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(milliseconds: ApiConfig.timeout));

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to get current subscription: $e');
    }
  }

  // Create a payment
  Future<Map<String, dynamic>> createPayment(Map<String, dynamic> payload) async {
    try {
      final token = await _getToken();
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.createPaymentEndpoint}'),
        headers: {
          ...ApiConfig.defaultHeaders,
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(payload),
      ).timeout(Duration(milliseconds: ApiConfig.timeout));

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to create payment: $e');
    }
  }

  // Subscribe to a new plan
  Future<Map<String, dynamic>> subscribe(Map<String, dynamic> payload) async {
    try {
      final token = await _getToken();
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.subscribeEndpoint}'),
        headers: {
          ...ApiConfig.defaultHeaders,
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(payload),
      ).timeout(Duration(milliseconds: ApiConfig.timeout));

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to subscribe: $e');
    }
  }

  // Cancel subscription
  Future<Map<String, dynamic>> cancelSubscription() async {
    try {
      final token = await _getToken();
      final response = await _client.post(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.cancelSubscriptionEndpoint}'),
        headers: {
          ...ApiConfig.defaultHeaders,
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(milliseconds: ApiConfig.timeout));

      return _handleResponse(response);
    } catch (e) {
      throw Exception('Failed to cancel subscription: $e');
    }
  }

  // Get transaction history
  Future<List<Map<String, dynamic>>> getTransactionHistory(String userId) async {
    try {
      final token = await _getToken();
      final response = await _client.get(
        Uri.parse('${ApiConfig.baseUrl}/payments/user-subscriptions/$userId'),
        headers: {
          ...ApiConfig.defaultHeaders,
          'Authorization': 'Bearer $token',
        },
      ).timeout(Duration(milliseconds: ApiConfig.timeout));

      // This endpoint may return an array directly
      final decoded = json.decode(response.body);
      if (response.statusCode >= 200 && response.statusCode < 300) {
        if (decoded is List) return List<Map<String, dynamic>>.from(decoded);
        if (decoded is Map && decoded['data'] is List) {
          return List<Map<String, dynamic>>.from(decoded['data']);
        }
        return <Map<String, dynamic>>[];
      } else {
        try {
          final errorData = decoded is Map ? decoded : {'message': response.reasonPhrase};
          throw Exception(errorData['message'] ?? 'API request failed');
        } catch (e) {
          throw Exception('HTTP ${response.statusCode}: ${response.reasonPhrase}');
        }
      }
    } catch (e) {
      throw Exception('Failed to get transaction history: $e');
    }
  }

  void dispose() {
    _client.close();
  }
}
