import 'package:flutter/material.dart';
import 'database.dart';
import 'models.dart';

class CourseProvider with ChangeNotifier {
  final AppDatabase db;
  List<CourseModel> courses = [];

  CourseProvider({required this.db});

  /// Load courses from DB
  Future<void> loadCoursesFromDb() async {
    courses = await db.getAllCoursesWithVideos();
    notifyListeners();
  }

  /// Add a new course
  Future<void> addCourse(CourseModel course) async {
    courses.add(course);
    await db.insertCourseAndVideos(course);
    notifyListeners();
  }

  /// Update video completion
  void updateVideo(String courseId, String videoId, bool isComplete) {
    final course = courses.firstWhere((c) => c.id == courseId);
    final index = course.videos.indexWhere((v) => v.id == videoId);
    if (index != -1) {
      course.videos[index].isComplete = isComplete;
      db.updateVideoStatus(videoId, isComplete);
      notifyListeners();
    }
  }
  /// Clear all courses and videos from memory and DB
  Future<void> clearDatabase() async {
    await db.deleteAllCoursesAndVideos(); // <-- implement this in your DB class
    courses.clear();
    notifyListeners();
  }
}
