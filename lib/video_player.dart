import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart'
    show Video, VideoController;
import 'package:media_kit_video/media_kit_video_controls/src/controls/extensions/duration.dart';
import 'package:path/path.dart' as p;
import 'package:playground/course_provider.dart';
import 'package:playground/models.dart';
import 'package:provider/provider.dart';

// Video Logic Provider
class VideoPlayerProvider extends ChangeNotifier {
  final CourseModel course;
  final CourseProvider courseProvider;
  final int initialIndex;

  late final Player player;
  late final VideoController controller;
  late int currentIndex;
  late final ValueNotifier<Duration> positionNotifier;
  late final ValueNotifier<Duration> durationNotifier;

  bool isFullscreen = false;
  bool showControls = true;
  bool showPlayPauseIcon = false;
  bool showForwardIcon = false;
  bool showRewindIcon = false;
  bool completedOnce = false;
  IconData playPauseIcon = Icons.play_arrow;
  double playbackSpeed = 1.0;
  Timer? hideTimer;

  VideoPlayerProvider({
    required this.course,
    required this.initialIndex,
    required this.courseProvider,
  }) {
    player = Player();
    controller = VideoController(player);
    currentIndex = initialIndex;
    positionNotifier = ValueNotifier(Duration.zero);
    durationNotifier = ValueNotifier(Duration.zero);
    _initPlayer();

    player.streams.position.listen((p) => positionNotifier.value = p);
    player.streams.duration.listen((d) => durationNotifier.value = d);
    player.streams.playing.listen((_) => notifyListeners());
    player.streams.completed.listen((c) {
      if (c && !completedOnce) {
        completedOnce = true;
        final v = course.videos[currentIndex];
        courseProvider.updateVideo(course.id, v.id, true);
        if (currentIndex < course.videos.length - 1) playNext();
      }
    });

    _startHideTimer();
  }

  void _initPlayer() => _openVideo(course.videos[currentIndex].path);

  void _openVideo(String path) {
    completedOnce = false;
    player.open(Media(path));
    notifyListeners();
  }

  void playPrevious() {
    if (currentIndex > 0) {
      currentIndex--;
      _openVideo(course.videos[currentIndex].path);
    }
  }

  void playNext() {
    if (currentIndex < course.videos.length - 1) {
      currentIndex++;
      _openVideo(course.videos[currentIndex].path);
    }
  }

  void replay() {
    player.seek(Duration.zero);
    player.play();
  }

  void toggleFullscreen() {
    isFullscreen = !isFullscreen;
    if (isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    notifyListeners();
  }

  Future<void> togglePlayPause() async {
    if (player.state.playing) {
      await player.pause();
    } else {
      await player.play();
    }
    playPauseIcon = player.state.playing ? Icons.pause : Icons.play_arrow;
    showPlayPauseIcon = true;
    notifyListeners();

    Future.delayed(const Duration(milliseconds: 600), () {
      showPlayPauseIcon = false;
      notifyListeners();
    });
  }

  void seek(bool forward) {
    final jump = const Duration(seconds: 10);
    final pos = player.state.position;
    final dur = player.state.duration;
    final newPos = forward ? pos + jump : pos - jump;
    player.seek(newPos.clamp(Duration.zero, dur));
    showForwardIcon = forward;
    showRewindIcon = !forward;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 400), () {
      showForwardIcon = false;
      showRewindIcon = false;
      notifyListeners();
    });
  }

  void _startHideTimer() {
    hideTimer?.cancel();
    hideTimer = Timer(const Duration(seconds: 3), () {
      if (player.state.playing && isFullscreen) {
        showControls = false;
        notifyListeners();
      }
    });
  }

  void toggleControls() {
    showControls = !showControls;
    notifyListeners();
    if (showControls) {
      _startHideTimer();
    } else {
      hideTimer?.cancel();
    }
  }

  Future<void> handleTap() async {
    if (showControls) {
      await togglePlayPause();
      _startHideTimer();
    } else {
      showControls = true;
      notifyListeners();
      _startHideTimer();
    }
  }

  @override
  void dispose() {
    player.dispose();
    positionNotifier.dispose();
    durationNotifier.dispose();
    hideTimer?.cancel();
    super.dispose();
  }
}

// -------------------- UI --------------------

class VideoPlayerScreen extends StatelessWidget {
  final CourseModel course;
  final int initialIndex;
  final CourseProvider provider;

  const VideoPlayerScreen({
    required this.course,
    required this.initialIndex,
    required this.provider,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => VideoPlayerProvider(
        course: course,
        initialIndex: initialIndex,
        courseProvider: provider,
      ),
      builder: (context, _) {
        final vm = context.watch<VideoPlayerProvider>();
        final currentVideo = vm.course.videos[vm.currentIndex];
        final fileName = p.basename(currentVideo.path);

        return Scaffold(
          backgroundColor: Colors.black,
          appBar: vm.isFullscreen ? null : AppBar(title: Text(fileName)),
          body: GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: vm.handleTap,
            onDoubleTapDown: (details) {
              final width = MediaQuery.of(context).size.width;
              final dx = details.localPosition.dx;
              vm.seek(dx >= width / 2);
            },
            child: Stack(
              alignment: Alignment.center,
              children: [
                Video(
                  controller: vm.controller,
                  fit: BoxFit.contain,
                  controls: null,
                ),

                if (vm.showRewindIcon)
                  const Icon(
                    Icons.fast_rewind,
                    size: 80,
                    color: Colors.white70,
                  ),
                if (vm.showForwardIcon)
                  const Icon(
                    Icons.fast_forward,
                    size: 80,
                    color: Colors.white70,
                  ),

                if (vm.showPlayPauseIcon)
                  AnimatedOpacity(
                    opacity: vm.showPlayPauseIcon ? 1 : 0,
                    duration: const Duration(milliseconds: 300),
                    child: Icon(
                      vm.playPauseIcon,
                      size: 80,
                      color: Colors.white70,
                    ),
                  ),

                Positioned(
                  top: 10,
                  right: 10,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: currentVideo.isComplete
                          ? Colors.green
                          : Colors.orange,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      currentVideo.isComplete ? "Completed" : "In Progress",
                      style: const TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                ),

                if (vm.showControls)
                  Positioned(
                    bottom: 0,
                    left: 0,
                    right: 0,
                    child: VideoControls(
                      vm: vm,
                      videoTitle: fileName,
                      hasPrevious: vm.currentIndex > 0,
                      hasNext: vm.currentIndex < vm.course.videos.length - 1,
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class VideoControls extends StatelessWidget {
  final VideoPlayerProvider vm;
  final String videoTitle;
  final bool hasPrevious;
  final bool hasNext;

  const VideoControls({
    required this.vm,
    required this.videoTitle,
    required this.hasPrevious,
    required this.hasNext,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black45,
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              videoTitle,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          ValueListenableBuilder<Duration>(
            valueListenable: vm.positionNotifier,
            builder: (context, position, _) {
              final duration = vm.durationNotifier.value;
              final maxMs = duration.inMilliseconds > 0
                  ? duration.inMilliseconds.toDouble()
                  : 1.0;
              final currentMs = position.inMilliseconds
                  .clamp(0, duration.inMilliseconds)
                  .toDouble();

              return Row(
                children: [
                  Text(
                    _fmt(position),
                    style: const TextStyle(color: Colors.white70),
                  ),
                  Expanded(
                    child: SliderTheme(
                      data: SliderTheme.of(context).copyWith(
                        trackHeight: 3,
                        thumbShape: const RoundSliderThumbShape(
                          enabledThumbRadius: 6,
                        ),
                        overlayShape: const RoundSliderOverlayShape(
                          overlayRadius: 12,
                        ),
                        activeTrackColor: Colors.green,
                        inactiveTrackColor: Colors.white30,
                      ),
                      child: Slider(
                        value: currentMs,
                        min: 0,
                        max: maxMs,
                        onChanged: (val) {
                          vm.player.seek(Duration(milliseconds: val.toInt()));
                        },
                      ),
                    ),
                  ),
                  Text(
                    _fmt(duration),
                    style: const TextStyle(color: Colors.white70),
                  ),
                ],
              );
            },
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  vm.player.state.playing ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: vm.togglePlayPause,
              ),
              IconButton(
                icon: const Icon(Icons.replay, color: Colors.white),
                onPressed: vm.replay,
              ),
              IconButton(
                icon: const Icon(Icons.skip_previous, color: Colors.white),
                onPressed: hasPrevious ? vm.playPrevious : null,
              ),
              IconButton(
                icon: const Icon(Icons.skip_next, color: Colors.white),
                onPressed: hasNext ? vm.playNext : null,
              ),
              DropdownButton<double>(
                value: vm.playbackSpeed,
                dropdownColor: Colors.black87,
                style: const TextStyle(color: Colors.white),
                items: [0.5, 1.0, 1.5, 2.0]
                    .map(
                      (e) => DropdownMenuItem(value: e, child: Text('${e}x')),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) {
                    vm.playbackSpeed = val;
                    vm.player.setRate(val);
                    vm.notifyListeners();
                  }
                },
              ),
              IconButton(
                icon: const Icon(Icons.fullscreen, color: Colors.white),
                onPressed: vm.toggleFullscreen,
              ),
            ],
          ),
        ],
      ),
    );
  }

  String _fmt(Duration d) {
    String two(int n) => n.toString().padLeft(2, '0');
    return "${two(d.inMinutes.remainder(60))}:${two(d.inSeconds.remainder(60))}";
  }
}
