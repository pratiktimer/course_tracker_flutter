import 'dart:io';
import 'package:flutter/foundation.dart';

/// In-memory / UI models
class VideoModel {
  final String id;
  final String path;
  String? thumbnailPath;

  // Use ValueNotifier for reactive UI
  ValueNotifier<String?> thumbnailState;
  ValueNotifier<bool> isCompleteNotifier;

  // Optional getter/setter for convenience
  bool get isComplete => isCompleteNotifier.value;
  set isComplete(bool value) => isCompleteNotifier.value = value;

  VideoModel({
    required this.id,
    required this.path,
    bool isComplete = false,
    this.thumbnailPath,
  })  : thumbnailState = ValueNotifier(thumbnailPath),
        isCompleteNotifier = ValueNotifier(isComplete);
}



class CourseModel {
  final String id;
  final String name;
  String? thumbnailPath;
  ValueNotifier<String?> thumbnailState;
  final List<VideoModel> videos;

  CourseModel({
    required this.id,
    required this.name,
    this.thumbnailPath,
    required this.videos,
  }) : thumbnailState = ValueNotifier(thumbnailPath) {
    // Initialize each video's thumbnailState if needed
    for (var video in videos) {
      video.thumbnailState.value = video.thumbnailPath;
    }
  }
}

