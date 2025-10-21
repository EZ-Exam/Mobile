// routes.dart
import 'package:flutter/material.dart';
import 'mainscreen.dart';
import 'main_navigation.dart';
import 'pages/login_page.dart';
import 'pages/signup_page.dart';
import 'pages/user_details_page.dart';
import 'pages/lesson_details_page.dart';
import 'pages/lesson_questions_page.dart';
import 'pages/question_detail_page.dart';
import 'pages/question_practice_page.dart';
import 'pages/question_practice_demo.dart';
import 'pages/exam_page.dart';

class AppRoutes {
  static const String signIn = '/signin';
  static const String signUp = '/signup';
  static const String home = '/home';
  static const String main = '/main';
  static const String login = '/login';
  static const String register = '/register';
  static const String userDetails = '/user-details';
  static const String lessonDetails = '/lesson-details';
  static const String questions = '/questions';
  static const String questionDetail = '/question-detail';
  static const String questionPractice = '/question-practice';
  static const String questionPracticeDemo = '/question-practice-demo';

  static Map<String, WidgetBuilder> get routes {
    return {
      signIn: (context) => const LoginPage(), // ✅ Sử dụng LoginPage mới thay vì SignInPage cũ
      signUp: (context) => const SignUpPage(), // ✅ Sử dụng SignUpPage từ pages/signup_page.dart
      home: (context) => const MainScreen(), // ✅ Dùng MainScreen ở đây
      main: (context) => const MainNavigation(), // ✅ Main navigation
      login: (context) => const LoginPage(), // ✅ Login page mới
      register: (context) => const SignUpPage(), // ✅ Signup page mới (từ pages/)
      userDetails: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        return UserDetailsPage(userId: args?['userId'] ?? '1');
      },
      lessonDetails: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        return LessonDetailsPage(lessonId: args?['lessonId'] ?? '1');
      },
      questions: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        return LessonQuestionsPage(
          lessonId: args?['lessonId'] ?? '1',
          lessonName: args?['lessonName'] ?? 'Bài học',
        );
      },
      questionDetail: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        return QuestionDetailPage(
          questionId: args?['questionId'] ?? '1',
          questionData: args?['questionData'],
        );
      },
      questionPractice: (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        return QuestionPracticePage(
          questionId: args?['questionId'] ?? '1',
          questionData: args?['questionData'],
        );
      },
      questionPracticeDemo: (context) => const QuestionPracticeDemo(),
      '/exam': (context) {
        final args = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>?;
        return ExamPage(
          examId: args?['examId']?.toString() ?? '1',
          durationSeconds: args?['durationSeconds'] as int?,
        );
      },
    };
  }
}
