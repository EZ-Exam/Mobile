class ApiConfig {
  // API Configuration
  static const String baseUrl = 'https://2dd165726a49.ngrok-free.app/api';
  static const int timeout = 30000;
  
  // Google Sign-In Configuration (Web)
  static const String googleClientId = '310764216947-6bq7kia8mnhhrr9mdckbkt5jaq0f2i2o.apps.googleusercontent.com';
  
  // App Configuration
  static const String appName = 'EZEXAM';
  static const String appVersion = '1.0.0';
  static const bool debugMode = true;
  
  // API Endpoints
  static const String loginEndpoint = '/login';
  static const String googleLoginEndpoint = '/login/google-login';
  static const String registerEndpoint = '/register';
  static const String profileEndpoint = '/users/my-profile';
  static const String lessonsEndpoint = '/lessons-enhanced/paged';
  static const String mockTestsEndpoint = '/exams';
  static const String questionsEndpoint = '/questions';
  
  // Headers
  static Map<String, String> get defaultHeaders => {
    'Content-Type': 'application/json',
    'Accept': 'application/json',
    'ngrok-skip-browser-warning': 'true', // For ngrok
  };
}
