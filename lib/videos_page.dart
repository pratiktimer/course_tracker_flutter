
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart' show Video, VideoController;
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
              index: index,
              course: course,
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
  final CourseModel course;
  final int index;

  const _VideoCard({
    required this.video,
    required this.fileName,
    required this.courseId,
    required this.provider,
    required this.course, required this.index,
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
                course: widget.course,
                initialIndex: widget.index,
                provider: context.read<CourseProvider>(), // pass provider
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
