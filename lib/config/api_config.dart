import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // API Configuration
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'https://f43ea5da0e1b.ngrok-free.app/api';
  static int get timeout => int.tryParse(dotenv.env['API_TIMEOUT'] ?? '30000') ?? 30000;
  
  // Legacy API URLs (for backward compatibility)
  static String get legacyApiUrl => dotenv.env['LEGACY_API_URL'] ?? 'http://192.168.1.6:5000';
  static String get legacyLoginUrl => dotenv.env['LEGACY_LOGIN_URL'] ?? 'http://192.168.1.6:5000/Login';
  static String get legacySignupUrl => dotenv.env['LEGACY_SIGNUP_URL'] ?? 'http://192.168.1.6:5000/signup';
  static String get legacyGoogleLoginUrl => dotenv.env['LEGACY_GOOGLE_LOGIN_URL'] ?? 'http://192.168.1.6:5000/api/login/google';
  
  // Google Sign-In Configuration (Web)
  static String get googleClientId => dotenv.env['GOOGLE_CLIENT_ID'] ?? '310764216947-6bq7kia8mnhhrr9mdckbkt5jaq0f2i2o.apps.googleusercontent.com';
  
  // App Configuration
  static String get appName => dotenv.env['APP_NAME'] ?? 'EZEXAM';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';
  static bool get debugMode => dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';
  
  // API Endpoints
  static String get loginEndpoint => dotenv.env['LOGIN_ENDPOINT'] ?? '/login';
  static String get googleLoginEndpoint => dotenv.env['GOOGLE_LOGIN_ENDPOINT'] ?? '/login/google-login';
  static String get registerEndpoint => dotenv.env['REGISTER_ENDPOINT'] ?? '/register';
  static String get profileEndpoint => dotenv.env['PROFILE_ENDPOINT'] ?? '/users/my-profile';
  static String get lessonsEndpoint => dotenv.env['LESSONS_ENDPOINT'] ?? '/lessons-enhanced/paged';
  static String get mockTestsEndpoint => dotenv.env['MOCK_TESTS_ENDPOINT'] ?? '/exams';
  static String get questionsEndpoint => dotenv.env['QUESTIONS_ENDPOINT'] ?? '/questions';
  static String get commentsEndpoint => dotenv.env['COMMENTS_ENDPOINT'] ?? '/comments';
  static String get quizStartEndpoint => dotenv.env['QUIZ_START_ENDPOINT'] ?? '/quizzes/start';
  static String get quizSubmitEndpoint => dotenv.env['QUIZ_SUBMIT_ENDPOINT'] ?? '/quizzes/submit';
  static String get quizResultEndpoint => dotenv.env['QUIZ_RESULT_ENDPOINT'] ?? '/quizzes/result';
  
  // Sample URLs
  static String get samplePdfUrl => dotenv.env['SAMPLE_PDF_URL'] ?? 'https://example.com/lesson.pdf';
  static String get sampleImageUrl => dotenv.env['SAMPLE_IMAGE_URL'] ?? 'https://i.imgur.com/0y8Ftya.png';
  
  // Headers
  static Map<String, String> get defaultHeaders => {
    'Accept': 'application/json',
    'ngrok-skip-browser-warning': 'true', // For ngrok
  };
}
