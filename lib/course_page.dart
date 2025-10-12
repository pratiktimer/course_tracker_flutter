import 'dart:io';
import 'package:flutter/material.dart';
import 'package:playground/theme_provider.dart';
import 'package:playground/videos_page.dart';
import 'package:provider/provider.dart';
import 'models.dart';
import 'course_provider.dart';
import 'utils.dart';

class CourseListScreen extends StatelessWidget {
  const CourseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();

    return Scaffold(
      appBar: AppBar(
        title: const Text("📚 My Courses"),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              context.watch<ThemeProvider>().isDark
                  ? Icons.wb_sunny
                  : Icons.nightlight_round,
            ),
            onPressed: () => context.read<ThemeProvider>().toggleTheme(),
          ),
        ],
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: provider.courses.isEmpty
            ? const Center(
                child: Text(
                  "No courses yet.\nClick 'Add Parent Folder' to begin.",
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                  textAlign: TextAlign.center,
                ),
              )
            : GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3, // 3 cards per row (desktop style)
                  mainAxisSpacing: 16,
                  crossAxisSpacing: 16,
                  childAspectRatio: 1.2,
                ),
                itemCount: provider.courses.length,
                itemBuilder: (context, index) {
                  final course = provider.courses[index];
                  return _CourseCard(course: course);
                },
              ),
      ),
    );
  }
}

class _CourseCard extends StatelessWidget {
  final CourseModel course;
  const _CourseCard({required this.course});

  @override
  Widget build(BuildContext context) {
    final totalVideos = course.videos.length;
    final completedVideos = course.videos.where((v) => v.isComplete).length;
    final percentComplete = totalVideos == 0
        ? 0
        : ((completedVideos / totalVideos) * 100).round();

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      child: InkWell(
        borderRadius: BorderRadius.circular(16),
        onTap: () => Navigator.push(
          context,
          MaterialPageRoute(builder: (_) => VideoListScreen(course: course)),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                offset: const Offset(4, 4),
                blurRadius: 8,
              ),
              BoxShadow(
                color: Colors.white24,
                offset: const Offset(-4, -4),
                blurRadius: 8,
              ),
            ],
          ),
          child: Stack(
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: ValueListenableBuilder<String?>(
                      valueListenable: course.thumbnailState,
                      builder: (_, thumb, __) {
                        if (thumb == null || !File(thumb).existsSync()) {
                          return Container(
                            color: Colors.grey.shade200,
                            child: const Center(
                              child: Icon(
                                Icons.video_library,
                                size: 50,
                                color: Colors.grey,
                              ),
                            ),
                          );
                        }
                        return ClipRRect(
                          borderRadius: const BorderRadius.vertical(
                            top: Radius.circular(16),
                          ),
                          child: Image.file(
                            File(thumb),
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                        );
                      },
                    ),
                  ),

                  Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          course.name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          "$completedVideos/$totalVideos completed",
                          style: TextStyle(color: Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              // Bottom-right percent badge
              Positioned(
                bottom: 12,
                right: 12,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.greenAccent.shade700,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    "$percentComplete% Complete",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
