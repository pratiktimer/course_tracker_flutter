import 'dart:io';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart'
    show Video, VideoController;
import 'package:playground/video_player.dart';
import 'package:playground/theme_provider.dart';
import 'package:provider/provider.dart';
import 'models.dart';
import 'course_provider.dart';
import 'utils.dart';

class VideoListScreen extends StatelessWidget {
  final CourseModel course;
  const VideoListScreen({required this.course, super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.read<CourseProvider>();

    return Scaffold(
      appBar: AppBar(title: Text(course.name)),
      body: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          if (course.videos.isEmpty) {
            return const Center(
              child: Text(
                "No videos found for this course.",
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
            );
          }

          // If narrow screen -> ListView (mobile). Otherwise GridView.
          if (width < 600) {
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: course.videos.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final video = course.videos[index];
                _ensureThumbnail(video, provider, course.id);

                return _VideoCard(
                  course: course,
                  video: video,
                  provider: provider,
                  courseId: course.id,
                  index: index,
                  fileName: _getFileName(video.path),
                  isListView: true,
                );
              },
            );
          } else {
            // Grid for tablets / desktop
            int crossAxisCount;
            if (width >= 1400) {
              crossAxisCount = 5;
            } else if (width >= 1100) {
              crossAxisCount = 4;
            } else if (width >= 800) {
              crossAxisCount = 3;
            } else {
              crossAxisCount = 2;
            }

            return Padding(
              padding: const EdgeInsets.all(16),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: crossAxisCount,
                  crossAxisSpacing: 16,
                  mainAxisSpacing: 16,
                  childAspectRatio: 16 / 10,
                ),
                itemCount: course.videos.length,
                itemBuilder: (context, index) {
                  final video = course.videos[index];
                  _ensureThumbnail(video, provider, course.id);

                  return _VideoCard(
                    course: course,
                    video: video,
                    provider: provider,
                    courseId: course.id,
                    index: index,
                    fileName: _getFileName(video.path),
                    isListView: false,
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }

  void _ensureThumbnail(
    VideoModel video,
    CourseProvider provider,
    String courseId,
  ) {
    if (video.thumbnailState.value == null) {
      getVideoThumbnail(video.path).then((thumb) {
        if (thumb != null) {
          video.thumbnailState.value = thumb;
          video.thumbnailPath = thumb;
          provider.updateVideoThumbnail(courseId, video.id, thumb);
        }
      });
    }
  }

  String _getFileName(String path) => path.split(Platform.pathSeparator).last;
}

class _VideoCard extends StatefulWidget {
  final VideoModel video;
  final String fileName;
  final String courseId;
  final CourseProvider provider;
  final CourseModel course;
  final int index;
  final bool isListView;

  const _VideoCard({
    required this.video,
    required this.fileName,
    required this.courseId,
    required this.provider,
    required this.course,
    required this.index,
    this.isListView = false,
  });

  @override
  State<_VideoCard> createState() => _VideoCardState();
}

class _VideoCardState extends State<_VideoCard> {
  bool _hover = false;

  @override
  Widget build(BuildContext context) {
    final borderRadius = BorderRadius.circular(12);

    // Thumbnail builder (reused)
    Widget thumbWidget({
      double? height,
      double? width,
      BoxFit fit = BoxFit.cover,
    }) {
      return ValueListenableBuilder<String?>(
        valueListenable: widget.video.thumbnailState,
        builder: (_, thumb, __) {
          if (thumb == null || !File(thumb).existsSync()) {
            return Container(
              width: width ?? double.infinity,
              height: height ?? double.infinity,
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: borderRadius,
              ),
              child: const Center(
                child: Icon(Icons.video_library, size: 44, color: Colors.grey),
              ),
            );
          }
          return ClipRRect(
            borderRadius: borderRadius,
            child: Image.file(
              File(thumb),
              width: width ?? double.infinity,
              height: height ?? double.infinity,
              fit: fit,
            ),
          );
        },
      );
    }

    final checkbox = ValueListenableBuilder<bool>(
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
            widget.provider.updateVideo(widget.courseId, widget.video.id, val);
          },
          activeColor: Colors.greenAccent,
          checkColor: Colors.white,
        );
      },
    );

    // Play icon button (small)
    final playButton = Material(
      color: Colors.black54,
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VideoPlayerScreen(
                course: widget.course,
                initialIndex: widget.index,
                provider: widget.provider,
              ),
            ),
          );
        },
        child: const Padding(
          padding: EdgeInsets.all(8.0),
          child: Icon(Icons.play_arrow, color: Colors.white),
        ),
      ),
    );

    return MouseRegion(
      onEnter: (_) => setState(() => _hover = true),
      onExit: (_) => setState(() => _hover = false),
      cursor: SystemMouseCursors.click,
      child: InkWell(
        borderRadius: borderRadius,
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => VideoPlayerScreen(
                course: widget.course,
                initialIndex: widget.index,
                provider: widget.provider,
              ),
            ),
          );
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          decoration: BoxDecoration(
            borderRadius: borderRadius,
            color: Theme.of(context).cardColor,
            boxShadow: _hover
                ? [
                    BoxShadow(
                      color: Colors.black26,
                      offset: const Offset(4, 4),
                      blurRadius: 8,
                    ),
                    BoxShadow(
                      color: Colors.white12,
                      offset: const Offset(-4, -4),
                      blurRadius: 8,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: Colors.black12,
                      offset: const Offset(2, 2),
                      blurRadius: 4,
                    ),
                  ],
          ),
          clipBehavior: Clip.antiAlias,
          child: widget.isListView
              ? _buildListTile(thumbWidget, checkbox, playButton)
              : _buildGridTile(thumbWidget, checkbox),
        ),
      ),
    );
  }

  // Mobile / List view card: Tall thumbnail on top, title & meta below, actions to the right
  Widget _buildListTile(
    Widget Function({double? height, double? width, BoxFit fit}) thumbBuilder,
    Widget checkbox,
    Widget playButton,
  ) {
    const double thumbHeight = 180;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Thumbnail with rounded corners
        Container(
          height: thumbHeight,
          decoration: const BoxDecoration(),
          child: Stack(
            children: [
              Positioned.fill(
                child: thumbBuilder(height: thumbHeight, fit: BoxFit.cover),
              ),
              // subtle overlay
              Positioned.fill(
                child: Container(
                  color: _hover ? Colors.black26 : Colors.black12,
                ),
              ),
              // Play button bottom-left
              Positioned(
                left: 12,
                bottom: 12,
                child: Material(
                  color: Colors.black54,
                  shape: const CircleBorder(),
                  child: InkWell(
                    customBorder: const CircleBorder(),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => VideoPlayerScreen(
                            course: widget.course,
                            initialIndex: widget.index,
                            provider: widget.provider,
                          ),
                        ),
                      );
                    },
                    child: const Padding(
                      padding: EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.play_arrow,
                        color: Colors.white,
                        size: 22,
                      ),
                    ),
                  ),
                ),
              ),
              // Checkbox top-right
              Positioned(
                right: 8,
                top: 8,
                child: CircleAvatar(
                  backgroundColor: Colors.black45,
                  radius: 18,
                  child: SizedBox(
                    width: 22,
                    height: 22,
                    child: Center(child: checkbox),
                  ),
                ),
              ),
            ],
          ),
        ),

        // Title + meta area
        Padding(
          padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
          child: Row(
            children: [
              // Title & subtitle
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      widget.fileName,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w600,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Row(
                      children: [
                        // Placeholder: you can replace with actual duration or size
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: Colors.grey.shade400,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          "Duration: --:--", // replace with real duration if available
                          style: TextStyle(
                            color: Colors.grey.shade500,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(width: 8),
              // optional quick play (visible on mobile)
              playButton,
            ],
          ),
        ),
      ],
    );
  }

  // Grid tile for larger screens (keeps original stacked look, improved layout)
  Widget _buildGridTile(
    Widget Function({double? height, double? width, BoxFit fit}) thumbBuilder,
    Widget checkbox,
  ) {
    return Stack(
      children: [
        Positioned.fill(child: thumbBuilder(fit: BoxFit.cover)),
        Positioned.fill(
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 160),
            color: _hover ? Colors.black26 : Colors.black12,
          ),
        ),
        Positioned(
          left: 8,
          right: 8,
          bottom: 8,
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
                  blurRadius: 2,
                ),
              ],
            ),
          ),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: CircleAvatar(
            backgroundColor: Colors.black54,
            child: SizedBox(
              width: 22,
              height: 22,
              child: Center(child: checkbox),
            ),
          ),
        ),
      ],
    );
  }
}
