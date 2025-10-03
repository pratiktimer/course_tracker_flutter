import 'dart:io';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:video_player/video_player.dart';
import 'models.dart';
import 'course_provider.dart';
import 'utils.dart';

class CourseListScreen extends StatelessWidget {
  const CourseListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<CourseProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text('Courses')),
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'addCourse',
            onPressed: () async {
              final folder = await pickFolder();
              if (folder != null) {
                final videoFiles = await fetchAllVideos(folder);
                if (videoFiles.isNotEmpty) {
                  final videoModels = videoFiles
                      .map((v) => VideoModel(id: uuid.v4(), path: v.path))
                      .toList();

                  // Generate thumbnail for first video to show in course list
                  final firstThumb = await getVideoThumbnail(videoModels.first.path);

                  final course = CourseModel(
                    id: uuid.v4(),
                    name: folder.split(Platform.pathSeparator).last,
                    videos: videoModels,
                    thumbnailPath: firstThumb,
                  );
                  course.thumbnailState.value = firstThumb;

                  // Generate thumbnails for all videos asynchronously
                  for (var video in videoModels) {
                    getVideoThumbnail(video.path).then((thumb) async {
                      video.thumbnailState.value = thumb;
                      video.thumbnailPath = thumb;
                      await provider.updateVideoThumbnail(video.id, thumb);
                    });
                  }

                  await provider.addCourse(course);
                }
              }
            },
            child: const Icon(Icons.add),
          ),
          const SizedBox(height: 16),
          FloatingActionButton(
            heroTag: 'resetApp',
            backgroundColor: Colors.red,
            onPressed: () async {
              await provider.clearDatabase();
            },
            child: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: provider.courses.length,
        itemBuilder: (context, index) {
          final course = provider.courses[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Card(
              child: InkWell(
                onTap: () => Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => VideoListScreen(course: course)),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      SizedBox(
                        width: 80,
                        height: 80,
                        child: ValueListenableBuilder<String?>(
                          valueListenable: course.thumbnailState,
                          builder: (_, thumb, __) {
                            if (thumb == null || !File(thumb).existsSync()) {
                              return const Icon(Icons.video_library,
                                  size: 50, color: Colors.grey);
                            }
                            return Image.file(File(thumb), fit: BoxFit.cover);
                          },
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(course.name,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 4),
                            Text(
                              "${course.videos.where((v) => v.isComplete).length}/${course.videos.length} completed",
                              style: const TextStyle(color: Colors.grey),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

class VideoListScreen extends StatelessWidget {
  final CourseModel course;
  const VideoListScreen({required this.course, super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CourseProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(course.name)),
      body: ListView.builder(
        itemCount: course.videos.length,
        itemBuilder: (context, index) {
          final video = course.videos[index];
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            child: Card(
              child: ListTile(
                leading: SizedBox(
                  width: 80,
                  height: 80,
                  child: ValueListenableBuilder<String?>(
                    valueListenable: video.thumbnailState,
                    builder: (_, thumb, __) =>
                    thumb != null && File(thumb).existsSync()
                        ? Image.file(File(thumb), width: 80, height: 80, fit: BoxFit.cover)
                        : const Icon(Icons.video_library, size: 50, color: Colors.grey),
                  ),
                ),
                title: Text(video.path.split(Platform.pathSeparator).last),
                trailing: Checkbox(
                  value: video.isComplete,
                  onChanged: (val) => provider.updateVideo(course.id, video.id, val!),
                ),
                onTap: () {
                  // Open video file
                  if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) {
                    Process.run('explorer', [video.path]); // Windows example
                  }
                },
                // onTap: () {
                //   Navigator.push(
                //     context,
                //     MaterialPageRoute(
                //       builder: (_) => VideoPlayerScreen(videoPath: video.path),
                //     ),
                //   );
                // },
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Full-screen video player page
class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;
  const VideoPlayerScreen({required this.videoPath, super.key});

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {}); // Rebuild when ready
        _controller.play(); // Auto-play
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(title: const Text("Video Player")),
      body: Center(
        child: _controller.value.isInitialized
            ? AspectRatio(
          aspectRatio: _controller.value.aspectRatio,
          child: VideoPlayer(_controller),
        )
            : const CircularProgressIndicator(),
      ),
      floatingActionButton: _controller.value.isInitialized
          ? FloatingActionButton(
        onPressed: () {
          setState(() {
            _controller.value.isPlaying
                ? _controller.pause()
                : _controller.play();
          });
        },
        child: Icon(
          _controller.value.isPlaying
              ? Icons.pause
              : Icons.play_arrow,
        ),
      )
          : null,
    );
  }
}
