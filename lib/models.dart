import 'dart:io';
import 'package:flutter/foundation.dart';

/// In-memory / UI models
class VideoModel {
  final String id;
  final String path;
  bool isComplete;
  ValueNotifier<String?> thumbnailState;

  VideoModel({
    required this.id,
    required this.path,
    this.isComplete = false,
    String? thumbnailPath, // optional initial thumbnail path
  }) : thumbnailState = ValueNotifier(thumbnailPath);
}


class CourseModel {
  final String id;
  final String name;
  final List<VideoModel> videos;
  final String? thumbnailPath;

  ValueNotifier<String?> thumbnailState;

  CourseModel({
    required this.id,
    required this.name,
    required this.videos,
    this.thumbnailPath,
  }) : thumbnailState = ValueNotifier(thumbnailPath); // Initialize with saved path
}
