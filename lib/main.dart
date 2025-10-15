import 'package:flutter/material.dart';
import 'l10n/app_localizations.dart';
import 'routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Tạm thời comment Firebase để test
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'EZEXAM - AI Exam Preparation Platform',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      localizationsDelegates: AppLocalizations.localizationsDelegates, // ✅ Đa ngôn ngữ
      supportedLocales: AppLocalizations.supportedLocales,
      initialRoute: AppRoutes.main, // ✅ Sử dụng main navigation
      routes: AppRoutes.routes,
    );
  }
}
