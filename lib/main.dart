import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:playground/theme_provider.dart';
import 'app_theme.dart';
import 'database.dart';
import 'course_provider.dart';
import 'screens.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  MediaKit.ensureInitialized();
  final db = AppDatabase();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(
            create: (_) => CourseProvider(db: db)..loadCoursesFromDb()),
      ],
      child: const CourseTrackerApp(),
    ),
  );
}

class CourseTrackerApp extends StatelessWidget {
  const CourseTrackerApp({super.key});

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: ThemeData(
        brightness: Brightness.light,
        useMaterial3: true,
        primaryColor: Colors.indigo,
        cardColor: Colors.grey.shade200,
        scaffoldBackgroundColor: Colors.grey.shade100,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        useMaterial3: true,
        primaryColor: Colors.greenAccent.shade700,
        cardColor: Colors.grey.shade900,
        scaffoldBackgroundColor: Colors.black,
      ),
      home: const CourseListScreen(),
    );
  }
}