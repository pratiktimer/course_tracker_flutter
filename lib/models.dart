import 'dart:io';
import 'package:flutter/foundation.dart';

/// In-memory / UI models
class VideoModel {
  final String id;
  final String path;
  bool isComplete;
  String? thumbnailPath;
  ValueNotifier<String?> thumbnailState;

  VideoModel({
    required this.id,
    required this.path,
    this.isComplete = false,
    this.thumbnailPath,
  }) : thumbnailState = ValueNotifier(thumbnailPath);
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

