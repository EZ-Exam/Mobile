import 'package:flutter_dotenv/flutter_dotenv.dart';

class ApiConfig {
  // API Configuration
  static String get baseUrl => dotenv.env['BASE_URL'] ?? 'https://tridz123backend.ezexam.online/api';
  static int get timeout => int.tryParse(dotenv.env['API_TIMEOUT'] ?? '120000') ?? 120000;
  
  // Legacy API URLs (for backward compatibility)
  static String get legacyApiUrl => dotenv.env['LEGACY_API_URL'] ?? 'https://tridz123backend.ezexam.online';
  static String get legacyLoginUrl => dotenv.env['LEGACY_LOGIN_URL'] ?? 'https://tridz123backend.ezexam.online/login';
  static String get legacySignupUrl => dotenv.env['LEGACY_SIGNUP_URL'] ?? 'https://tridz123backend.ezexam.online/register';
  static String get legacyGoogleLoginUrl => dotenv.env['LEGACY_GOOGLE_LOGIN_URL'] ?? 'https://tridz123backend.ezexam.online/api/auth/google-login';
  
  // Google Sign-In Configuration (Web)
  static String get googleClientId => dotenv.env['GOOGLE_CLIENT_ID'] ?? '310764216947-6bq7kia8mnhhrr9mdckbkt5jaq0f2i2o.apps.googleusercontent.com';
  
  // App Configuration
  static String get appName => dotenv.env['APP_NAME'] ?? 'EZEXAM';
  static String get appVersion => dotenv.env['APP_VERSION'] ?? '1.0.0';
  static bool get debugMode => dotenv.env['DEBUG_MODE']?.toLowerCase() == 'true';
  
  // API Endpoints
  // Auth endpoints
  static String get loginEndpoint => dotenv.env['LOGIN_ENDPOINT'] ?? '/auth/login';
  static String get googleLoginEndpoint => dotenv.env['GOOGLE_LOGIN_ENDPOINT'] ?? '/auth/google-login';
  static String get registerEndpoint => dotenv.env['REGISTER_ENDPOINT'] ?? '/auth/register';
  static String get logoutEndpoint => dotenv.env['LOGOUT_ENDPOINT'] ?? '/auth/logout';
  static String get refreshTokenEndpoint => dotenv.env['REFRESH_TOKEN_ENDPOINT'] ?? '/auth/refresh-token';
  
  // User endpoints
  static String get profileEndpoint => dotenv.env['PROFILE_ENDPOINT'] ?? '/users/my-profile';
  static String get updateProfileEndpoint => dotenv.env['UPDATE_PROFILE_ENDPOINT'] ?? '/users/update-profile';
  static String get changePasswordEndpoint => dotenv.env['CHANGE_PASSWORD_ENDPOINT'] ?? '/users/change-password';
  static String get forgotPasswordEndpoint => dotenv.env['FORGOT_PASSWORD_ENDPOINT'] ?? '/users/forgot-password';
  static String get resetPasswordEndpoint => dotenv.env['RESET_PASSWORD_ENDPOINT'] ?? '/users/reset-password';
  
  // Content endpoints
  static String get lessonsEndpoint => dotenv.env['LESSONS_ENDPOINT'] ?? '/lessons-enhanced';
  static String get mockTestsEndpoint => dotenv.env['MOCK_TESTS_ENDPOINT'] ?? '/exams';
  static String get questionsEndpoint => dotenv.env['QUESTIONS_ENDPOINT'] ?? '/questions';
  static String get commentsEndpoint => dotenv.env['COMMENTS_ENDPOINT'] ?? '/comments';
  static String get subjectsEndpoint => dotenv.env['SUBJECTS_ENDPOINT'] ?? '/subjects';
  static String get semestersEndpoint => dotenv.env['SEMESTERS_ENDPOINT'] ?? '/semesters';
  static String get chaptersEndpoint => dotenv.env['CHAPTERS_ENDPOINT'] ?? '/chapters';
  static String get difficultyLevelsEndpoint => dotenv.env['DIFFICULTY_LEVELS_ENDPOINT'] ?? '/difficulty-levels';
  
  // Quiz endpoints
  static String get quizStartEndpoint => dotenv.env['QUIZ_START_ENDPOINT'] ?? '/quizzes/start';
  static String get quizSubmitEndpoint => dotenv.env['QUIZ_SUBMIT_ENDPOINT'] ?? '/quizzes/submit';
  static String get quizResultEndpoint => dotenv.env['QUIZ_RESULT_ENDPOINT'] ?? '/quizzes/result';
  static String get quizHistoryEndpoint => dotenv.env['QUIZ_HISTORY_ENDPOINT'] ?? '/quizzes/history';

  // Payment & Subscription endpoints
  static String get subscriptionTypesEndpoint => dotenv.env['SUBSCRIPTION_TYPES_ENDPOINT'] ?? '/subscription-types';
  static String get currentSubscriptionEndpoint => dotenv.env['CURRENT_SUBSCRIPTION_ENDPOINT'] ?? '/subscription/current';
  static String get createPaymentEndpoint => dotenv.env['CREATE_PAYMENT_ENDPOINT'] ?? '/payments/create-payment';
  static String get subscribeEndpoint => dotenv.env['SUBSCRIBE_ENDPOINT'] ?? '/subscription/subscribe';
  static String get cancelSubscriptionEndpoint => dotenv.env['CANCEL_SUBSCRIPTION_ENDPOINT'] ?? '/subscription/cancel';
  
  // Sample URLs
  static String get samplePdfUrl => dotenv.env['SAMPLE_PDF_URL'] ?? 'https://example.com/lesson.pdf';
  static String get sampleImageUrl => dotenv.env['SAMPLE_IMAGE_URL'] ?? 'https://i.imgur.com/0y8Ftya.png';
  
  // Headers
  static Map<String, String> get defaultHeaders => {
    'Accept': 'application/json',
    'ngrok-skip-browser-warning': 'true', // For ngrok
  };
}
