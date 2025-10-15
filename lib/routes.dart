// routes.dart
import 'package:flutter/material.dart';
import 'signin.dart';
import 'mainscreen.dart';
import 'ezexam_home.dart';
import 'main_navigation.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/user_details_page.dart';
import 'pages/lesson_details_page.dart';

class AppRoutes {
  static const String signIn = '/signin';
  static const String signUp = '/signup';
  static const String home = '/home';
  static const String main = '/main';
  static const String login = '/login';
  static const String register = '/register';
  static const String userDetails = '/user-details';
  static const String lessonDetails = '/lesson-details';

  static Map<String, WidgetBuilder> get routes {
    return {
      signIn: (context) => const EZEXAMHomePage(), // ✅ Sử dụng EZEXAM Home
      signUp: (context) => const SignUpPage(),
      home: (context) => const MainScreen(), // ✅ Dùng MainScreen ở đây
      main: (context) => const MainNavigation(), // ✅ Main navigation
      login: (context) => const LoginPage(), // ✅ Login page mới
      register: (context) => const SignUpPage(), // ✅ Signup page mới
      userDetails: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        return UserDetailsPage(userId: args?['userId'] ?? '1');
      },
      lessonDetails: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        return LessonDetailsPage(lessonId: args?['lessonId'] ?? '1');
      },
    };
  }
}
