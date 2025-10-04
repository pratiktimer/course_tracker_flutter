import 'dart:io';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart' show Video, VideoController;
import 'package:playground/theme_provider.dart';
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
          FloatingActionButton.extended(
            heroTag: 'addCoursesFromParent',
            icon: const Icon(Icons.folder_open),
            label: const Text("Add Parent Folder"),
            onPressed: () async {
              final parentFolder = await pickFolder();
              if (parentFolder == null) return;

              final parentDir = Directory(parentFolder);
              if (!await parentDir.exists()) return;

              final subDirs = parentDir.listSync().whereType<Directory>().toList();

              for (final subDir in subDirs) {
                final videoFiles = await fetchAllVideos(subDir.path);
                if (videoFiles.isEmpty) continue;

                final videoModels = videoFiles
                    .map((v) => VideoModel(id: uuid.v4(), path: v.path))
                    .toList();

                // Course thumbnail from first video
                final firstThumb = await getVideoThumbnail(videoModels.first.path);

                final course = CourseModel(
                  id: uuid.v4(),
                  name: subDir.path.split(Platform.pathSeparator).last,
                  videos: videoModels,
                  thumbnailPath: firstThumb,
                );
                course.thumbnailState.value = firstThumb;

                await provider.addCourse(course);
              }
            },
          ),

          const SizedBox(height: 12),
          FloatingActionButton.extended(
            heroTag: 'resetApp',
            backgroundColor: Colors.red,
            icon: const Icon(Icons.refresh),
            label: const Text("Reset"),
            onPressed: () async {
              await provider.clearDatabase();
            },
          ),
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
          MaterialPageRoute(
            builder: (_) => VideoListScreen(course: course),
          ),
        ),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).cardColor,
            boxShadow: [
              BoxShadow(
                  color: Colors.black26, offset: const Offset(4, 4), blurRadius: 8),
              BoxShadow(
                  color: Colors.white24, offset: const Offset(-4, -4), blurRadius: 8),
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
                              child: Icon(Icons.video_library,
                                  size: 50, color: Colors.grey),
                            ),
                          );
                        }
                        return ClipRRect(
                          borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
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
                              fontWeight: FontWeight.bold, fontSize: 16),
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
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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

class VideoListScreen extends StatelessWidget {
  final CourseModel course;
  const VideoListScreen({required this.course, super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CourseProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(course.name)),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: course.videos.isEmpty
            ? const Center(
          child: Text(
            "No videos found for this course.",
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
        )
            : GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 16,
            mainAxisSpacing: 16,
            childAspectRatio: 16 / 10,
          ),
          itemCount: course.videos.length,
          itemBuilder: (context, index) {
            final video = course.videos[index];

            // Generate thumbnail if not already set
            if (video.thumbnailState.value == null) {
              getVideoThumbnail(video.path).then((thumb) {
                video.thumbnailState.value = thumb;
                video.thumbnailPath = thumb;
                provider.updateVideoThumbnail(course.id, video.id, thumb);
              });
            }

            final fileName = video.path.split(Platform.pathSeparator).last;

            return _VideoCard(
              video: video,
              fileName: fileName,
              courseId: course.id,
              provider: provider,
            );
          },
        ),
      ),
    );
  }
}

class _VideoCard extends StatefulWidget {
  final VideoModel video;
  final String fileName;
  final String courseId;
  final CourseProvider provider;

  const _VideoCard({
    required this.video,
    required this.fileName,
    required this.courseId,
    required this.provider,
  });

  @override
  State<_VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<_VideoCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VideoPlayerScreen(
                videoPath: widget.video.path,
                videoTitle: widget.fileName,
              ),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(16),
            color: Theme.of(context).cardColor,
            boxShadow: _hover
                ? [
              BoxShadow(
                  color: Colors.black45,
                  offset: const Offset(4, 4),
                  blurRadius: 8),
              BoxShadow(
                  color: Colors.white24,
                  offset: const Offset(-4, -4),
                  blurRadius: 8),
            ]
                : [
              BoxShadow(
                  color: Colors.black26,
                  offset: const Offset(4, 4),
                  blurRadius: 6),
              BoxShadow(
                  color: Colors.white12,
                  offset: const Offset(-4, -4),
                  blurRadius: 6),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: Stack(
            children: [
              // Thumbnail
              ValueListenableBuilder<String?>(
                valueListenable: widget.video.thumbnailState,
                builder: (_, thumb, __) {
                  if (thumb == null || !File(thumb).existsSync()) {
                    return Container(
                      color: Colors.grey.shade200,
                      child: const Center(
                        child: Icon(Icons.video_library,
                            size: 50, color: Colors.grey),
                      ),
                    );
                  }
                  return Image.file(
                    File(thumb),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  );
                },
              ),

              // Dark overlay
              Positioned.fill(
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  color: _hover ? Colors.black26 : Colors.black12,
                ),
              ),

              // Video title
              Positioned(
                bottom: 8,
                left: 8,
                right: 8,
                child: Text(
                  widget.fileName,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    shadows: [
                      Shadow(
                          color: Colors.black54,
                          offset: Offset(1, 1),
                          blurRadius: 2)
                    ],
                  ),
                ),
              ),

              // Completion checkbox
              Positioned(
                top: 8,
                right: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.black54,
                  child: ValueListenableBuilder<bool>(
                    valueListenable: widget.video.isCompleteNotifier,
                    builder: (_, isComplete, __) {
                      return Checkbox(
                        value: isComplete,
                        onChanged: (val) {
                          if (val == null) return;
                          setState(() {
                            widget.video.isComplete = val;
                            widget.video.isCompleteNotifier.value = val;
                          });
                          widget.provider
                              .updateVideo(widget.courseId, widget.video.id, val);
                        },
                        activeColor: Colors.greenAccent,
                        checkColor: Colors.white,
                      );
                    },
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

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;
  final String videoTitle;

  const VideoPlayerScreen({
    required this.videoPath,
    required this.videoTitle,
    super.key,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  late Player _player;
  late VideoController _controller;

  bool _isFullscreen = false;
  double _playbackSpeed = 1.0;

  @override
  void initState() {
    super.initState();

    // Initialize Player
    _player = Player();
    _player.open(Media(widget.videoPath));

    // Wrap player in VideoController for the Video widget
    _controller = VideoController(_player);
  }

  @override
  void dispose() {
    //_controller.();
    _player.dispose();
    super.dispose();
  }

  void toggleFullscreen() {
    setState(() {
      _isFullscreen = !_isFullscreen;
    });
  }

  void changeSpeed(double speed) {
    _playbackSpeed = speed;
    _player.setRate(speed);
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _isFullscreen ? null : AppBar(title: Text(widget.videoTitle)),
      body: Center(
        child: Stack(
          children: [
            // Video Player
            Center(
              child: Video(
                controller: _controller,
                width: _isFullscreen ? screenWidth : screenWidth * 1,
                height: _isFullscreen ? screenHeight : screenHeight * 1,
                fit: BoxFit.cover,
              ),
            ),

            // Controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoControls(
                player: _player,
                videoTitle: widget.videoTitle,
                playbackSpeed: _playbackSpeed,
                onSpeedChange: changeSpeed,
                onFullscreenToggle: toggleFullscreen,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class VideoControls extends StatefulWidget {
  final Player player;
  final String videoTitle;
  final double playbackSpeed;
  final Function(double) onSpeedChange;
  final VoidCallback onFullscreenToggle;

  const VideoControls({
    required this.player,
    required this.videoTitle,
    required this.playbackSpeed,
    required this.onSpeedChange,
    required this.onFullscreenToggle,
    super.key,
  });

  @override
  State<VideoControls> createState() => _VideoControlsState();
}

class _VideoControlsState extends State<VideoControls> {
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;

  @override
  void initState() {
    super.initState();

    // Listen to position and duration
    widget.player.streams.position.listen((pos) {
      setState(() {
        _position = pos;
      });
    });

    widget.player.streams.duration.listen((dur) {
      setState(() {
        _duration = dur;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black45,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Video title
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.videoTitle,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ),
          const SizedBox(height: 8),

          // Seek bar
          Row(
            children: [
              Text(
                _formatDuration(_position),
                style: const TextStyle(color: Colors.white70),
              ),
              Expanded(
                child: Slider(
                  value: _position.inMilliseconds.toDouble().clamp(0, _duration.inMilliseconds.toDouble()),
                  min: 0,
                  max: _duration.inMilliseconds.toDouble(),
                  onChanged: (value) {
                    widget.player.seek(Duration(milliseconds: value.toInt()));
                  },
                  activeColor: Colors.green,
                  inactiveColor: Colors.white30,
                ),
              ),
              Text(
                _formatDuration(_duration),
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),

          // Control row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(widget.player.state.playing ? Icons.pause : Icons.play_arrow, color: Colors.white),
                onPressed: () {
                  if (widget.player.state.playing) {
                    widget.player.pause();
                  } else {
                    widget.player.play();
                  }
                  setState(() {});
                },
              ),
              DropdownButton<double>(
                value: widget.playbackSpeed,
                dropdownColor: Colors.black87,
                style: const TextStyle(color: Colors.white),
                items: [0.5, 1.0, 1.5, 2.0]
                    .map((e) => DropdownMenuItem(value: e, child: Text("${e}x")))
                    .toList(),
                onChanged: (val) {
                  if (val != null) widget.onSpeedChange(val);
                },
              ),
              IconButton(
                icon: const Icon(Icons.fullscreen, color: Colors.white),
                onPressed: widget.onFullscreenToggle,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _formatDuration(Duration d) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    return "${twoDigits(d.inMinutes)}:${twoDigits(d.inSeconds % 60)}";
  }
}