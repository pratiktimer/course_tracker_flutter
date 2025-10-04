import 'package:flutter/material.dart';
import 'database.dart';
import 'models.dart';

class CourseProvider with ChangeNotifier {
  final AppDatabase db;
  List<CourseModel> courses = [];

  CourseProvider({required this.db});

  /// Load courses and their videos from DB
  Future<void> loadCoursesFromDb() async {
    courses = await db.getAllCoursesWithVideos();

    // Initialize ValueNotifiers for thumbnails
    for (var course in courses) {
      course.thumbnailState.value = course.thumbnailPath;

      for (var video in course.videos) {
        video.thumbnailState.value = video.thumbnailPath;
      }
    }

    notifyListeners();
  }

  /// Add a new course and save to DB
  Future<void> addCourse(CourseModel course) async {
    courses.add(course);
    await db.insertCourseAndVideos(course);

    // Initialize ValueNotifiers
    course.thumbnailState.value = course.thumbnailPath;
    for (var video in course.videos) {
      video.thumbnailState.value = video.thumbnailPath;
    }

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
    await db.deleteAllCoursesAndVideos();
    courses.clear();
    notifyListeners();
  }

  /// Update video thumbnail in memory and DB
  Future<void> updateVideoThumbnail(String courseId, String videoId, String? thumb) async {
    // Find the course by ID
    final course = courses.firstWhere(
          (c) => c.id == courseId,
      orElse: () => throw Exception('Course not found'),
    );

    // Find the video within that course
    final video = course.videos.firstWhere(
          (v) => v.id == videoId,
      orElse: () => throw Exception('Video not found in this course'),
    );

    // Update in memory
    video.thumbnailState.value = thumb;
    video.thumbnailPath = thumb;

    // Update in database
    await db.updateVideoThumbnail(courseId, videoId, thumb);

    // Notify listeners for UI update
    notifyListeners();
  }

  /// Update course thumbnail in memory and DB
  Future<void> updateCourseThumbnail(String courseId, String? thumb) async {
    final course = courses.firstWhere((c) => c.id == courseId);
    course.thumbnailState.value = thumb;
    course.thumbnailPath = thumb;

    await db.updateCourseThumbnail(courseId, thumb);
    notifyListeners();
  }
}
