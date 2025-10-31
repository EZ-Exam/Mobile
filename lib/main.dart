
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'l10n/app_localizations.dart';
import 'routes.dart';
import 'providers/mock_test_provider.dart';
import 'providers/user_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Load environment variables
  await dotenv.load(fileName: "assets/config.env");
  
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
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => MockTestProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
      ],
      child: MaterialApp(
        title: 'EZEXAM - AI Exam Preparation Platform',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
          useMaterial3: true,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ButtonStyle(
              minimumSize: WidgetStateProperty.all(const Size(64, 44)),
              padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
              shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              textStyle: WidgetStateProperty.all(const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: ButtonStyle(
              minimumSize: WidgetStateProperty.all(const Size(64, 44)),
              padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
              shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))),
              side: WidgetStateProperty.resolveWith((states) {
                final Color border = states.contains(WidgetState.disabled)
                    ? Colors.grey.shade300
                    : Colors.grey.shade400;
                return BorderSide(color: border, width: 1.5);
              }),
              textStyle: WidgetStateProperty.all(const TextStyle(fontWeight: FontWeight.bold)),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: ButtonStyle(
              padding: WidgetStateProperty.all(const EdgeInsets.symmetric(horizontal: 12, vertical: 8)),
              textStyle: WidgetStateProperty.all(const TextStyle(fontWeight: FontWeight.w600)),
              shape: WidgetStateProperty.all(RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
            ),
          ),
          iconButtonTheme: IconButtonThemeData(
            style: ButtonStyle(
              padding: WidgetStateProperty.all(const EdgeInsets.all(8)),
              minimumSize: WidgetStateProperty.all(const Size(40, 40)),
              shape: WidgetStateProperty.all(const CircleBorder()),
            ),
          ),
        ),
        builder: (context, child) {
          // Global SafeArea to tránh đè status bar trên mọi màn hình
          return SafeArea(
            top: true,
            bottom: false,
            child: child ?? const SizedBox.shrink(),
          );
        },
        localizationsDelegates: AppLocalizations.localizationsDelegates, // ✅ Đa ngôn ngữ
        supportedLocales: AppLocalizations.supportedLocales,
        initialRoute: AppRoutes.main, // ✅ Sử dụng main navigation
        routes: AppRoutes.routes,
      ),
    );
  }
}

