import 'dart:io';
import 'package:flutter/material.dart';
import 'package:playground/dashboard_page.dart';
import 'package:provider/provider.dart';
import 'theme_provider.dart';
import 'course_provider.dart';
import 'videos_page.dart';
import 'models.dart';
import 'utils.dart';

class CourseListScreen extends StatelessWidget {
  const CourseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final courseProvider = context.watch<CourseProvider>();
    final themeProvider = context.watch<ThemeProvider>();
    final isDark = themeProvider.isDark;

    return Scaffold(
      appBar: AppBar(
        title: const Text("📚 My Courses"),
        centerTitle: true,
        elevation: 0,
        actions: [
          // Dark/Light mode toggle
          IconButton(
            icon: Icon(isDark ? Icons.wb_sunny : Icons.nightlight_round),
            onPressed: () => themeProvider.toggleTheme(),
          ),

          // Navigate to Course List
          IconButton(
            icon: const Icon(Icons.menu_book), // or any icon you like
            tooltip: "My Courses",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      const DashboardScreen(), // make sure to import it
                ),
              );
            },
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final courses = courseProvider.courses;

          if (courses.isEmpty) {
            return const Center(
              child: Text(
                "No courses yet.\nClick 'Add Folder' to begin.",
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 16),
              ),
            );
          }

          // 👇 Responsive layout
          if (width < 400) {
            // Small screens → show ListView
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: courses.length,
              itemBuilder: (_, index) => Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: _CourseCard(course: courses[index], isListView: true),
              ),
            );
          } else {
            // Larger screens → show GridView
            int crossAxisCount;
            if (width >= 1200) {
              crossAxisCount = 5;
            } else if (width >= 900) {
              crossAxisCount = 4;
            } else if (width >= 600) {
              crossAxisCount = 3;
            } else {
              crossAxisCount = 2;
            }

            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: width < 600 ? 0.9 : 1.2,
                ),
                itemCount: courses.length,
                itemBuilder: (_, index) => _CourseCard(course: courses[index]),
              ),
            );
          }
        },
      ),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          //   FloatingActionButton.extended(
          //     heroTag: 'addCoursesFromParent',
          //     icon: const Icon(Icons.folder_open),
          //     label: const Text("Add Parent Folder"),
          //     onPressed: () async {
          //       final parentFolder = await pickFolder();
          //       if (parentFolder == null) return;

          //       final parentDir = Directory(parentFolder);
          //       if (!await parentDir.exists()) return;

          //       final subDirs = parentDir
          //           .listSync()
          //           .whereType<Directory>()
          //           .toList();

          //       for (final subDir in subDirs) {
          //         final videoFiles = await fetchAllVideos(subDir.path);
          //         if (videoFiles.isEmpty) continue;

          //         final videoModels = videoFiles
          //             .map((v) => VideoModel(id: uuid.v4(), path: v.path))
          //             .toList();

          //         // Course thumbnail from first video
          //         final firstThumb = await getVideoThumbnail(
          //           videoModels.first.path,
          //         );

          //         final course = CourseModel(
          //           id: uuid.v4(),
          //           name: subDir.path.split(Platform.pathSeparator).last,
          //           videos: videoModels,
          //           thumbnailPath: firstThumb,
          //         );
          //         course.thumbnailState.value = firstThumb;

          //         await provider.addCourse(course);
          //       }
          //     },
          //   ),
          //   const SizedBox(height: 12),
          // FloatingActionButton.extended(
          //   heroTag: 'addCoursesFromChild',
          //   icon: const Icon(Icons.folder_open),
          //   label: const Text("Add Child Folder"),
          //   onPressed: () async {
          //     final parentFolder = await pickFolder();
          //     if (parentFolder == null) return;

          //     final parentDir = Directory(parentFolder);
          //     if (!await parentDir.exists()) return;

          //     final videoFiles = await fetchAllVideos(parentDir.path);
          //     if (videoFiles.isEmpty) return;

          //     final videoModels = videoFiles
          //         .map((v) => VideoModel(id: uuid.v4(), path: v.path))
          //         .toList();

          //     // Course thumbnail from first video
          //     final firstThumb = await getVideoThumbnail(
          //       videoModels.first.path,
          //     );

          //     final course = CourseModel(
          //       id: uuid.v4(),
          //       name: parentDir.path.split(Platform.pathSeparator).last,
          //       videos: videoModels,
          //       thumbnailPath: firstThumb,
          //     );
          //     course.thumbnailState.value = firstThumb;

          //     await provider.addCourse(course);
          //   },
          // ),

          //   const SizedBox(height: 12),
          //   FloatingActionButton.extended(
          //     heroTag: 'resetApp',
          //     backgroundColor: Colors.red,
          //     icon: const Icon(Icons.refresh),
          //     label: const Text("Reset"),
          //     onPressed: () async {
          //       await provider.clearDatabase();
          //     },
          //   ),
        ],
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final CourseModel course;
  final bool isListView;
  const _CourseCard({required this.course, this.isListView = false});

  @override
  Widget build(BuildContext context) {
    final total = course.videos.length;
    final completed = course.videos.where((v) => v.isComplete).length;
    final percent = total == 0 ? 0 : ((completed / total) * 100).round();

    final card = Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      clipBehavior: Clip.antiAlias,
      child: isListView
          ? Row(
              children: [
                _Thumbnail(course: course, width: 120, height: 80),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: _CourseDetails(
                      course: course,
                      total: total,
                      completed: completed,
                      percent: percent,
                    ),
                  ),
                ),
              ],
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _Thumbnail(course: course)),
                Padding(
                  padding: const EdgeInsets.all(12),
                  child: _CourseDetails(
                    course: course,
                    total: total,
                    completed: completed,
                    percent: percent,
                  ),
                ),
              ],
            ),
    );

    return InkWell(
      borderRadius: BorderRadius.circular(16),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => VideoListScreen(course: course)),
        );
      },
      child: card,
    );
  }
}

class _Thumbnail extends StatelessWidget {
  final CourseModel course;
  final double? width;
  final double? height;

  const _Thumbnail({required this.course, this.width, this.height});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String?>(
      valueListenable: course.thumbnailState,
      builder: (_, thumb, __) {
        if (thumb == null || !File(thumb).existsSync()) {
          return Container(
            width: width,
            height: height,
            color: Colors.grey.shade300,
            child: const Center(
              child: Icon(Icons.video_library, color: Colors.grey, size: 48),
            ),
          );
        }
        return Image.file(
          File(thumb),
          width: width ?? double.infinity,
          height: height,
          fit: BoxFit.cover,
        );
      },
    );
  }
}

class _CourseDetails extends StatelessWidget {
  final CourseModel course;
  final int total;
  final int completed;
  final int percent;

  const _CourseDetails({
    required this.course,
    required this.total,
    required this.completed,
    required this.percent,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          course.name,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 6),
        LinearProgressIndicator(
          value: total == 0 ? 0 : completed / total,
          color: Colors.greenAccent.shade700,
          backgroundColor: Colors.grey.shade300,
          minHeight: 6,
          borderRadius: BorderRadius.circular(4),
        ),
        const SizedBox(height: 6),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              "$completed / $total completed",
              style: TextStyle(color: Colors.grey.shade600),
            ),
            Text(
              "$percent%",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }
}
