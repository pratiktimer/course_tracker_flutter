import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart'
    show Video, VideoController;
import 'package:path/path.dart' as p;

import 'course_provider.dart';
import 'models.dart';

class VideoPlayerScreen extends StatefulWidget {
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
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen>
    with SingleTickerProviderStateMixin {
  late final Player _player;
  late final VideoController _controller;
  late int _currentIndex;

  bool _isFullscreen = false;
  double _playbackSpeed = 1.0;
  bool _completedOnce = false;

  // Animated icons
  bool _showRewindIcon = false;
  bool _showForwardIcon = false;
  bool _showPlayPauseIcon = false;
  IconData _playPauseIcon = Icons.play_arrow;

  late final AnimationController _animController;
  late final Animation<double> _fadeAnim;
  late final Animation<Offset> _slideAnim;

  late final ValueNotifier<Duration> _positionNotifier;
  late final ValueNotifier<Duration> _durationNotifier;

  // Auto-hide controls
  bool _showControls = true;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;

    _player = Player();
    _controller = VideoController(_player);

    _positionNotifier = ValueNotifier(Duration.zero);
    _durationNotifier = ValueNotifier(Duration.zero);

    _initPlayer();

    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnim = Tween<double>(begin: 1.0, end: 0.0).animate(_animController);
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0),
      end: const Offset(0, -0.5),
    ).animate(_animController);

    // Listen to player streams
    _player.streams.position.listen((pos) => _positionNotifier.value = pos);
    _player.streams.duration.listen((dur) => _durationNotifier.value = dur);
    _player.streams.completed.listen((completed) {
      if (completed && !_completedOnce) {
        _completedOnce = true;
        final currentVideo = widget.course.videos[_currentIndex];
        widget.provider.updateVideo(widget.course.id, currentVideo.id, true);
        if (_currentIndex < widget.course.videos.length - 1) {
          _playNext();
        }
      }
    });

    _startHideTimer(); // start auto-hide timer
  }

  void _initPlayer() {
    _openVideo(widget.course.videos[_currentIndex].path);
  }

  void _openVideo(String path) {
    _completedOnce = false;
    _player.open(Media(path));
  }

  void _playPrevious() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _openVideo(widget.course.videos[_currentIndex].path);
      setState(() {});
    }
  }

  void _playNext() {
    if (_currentIndex < widget.course.videos.length - 1) {
      _currentIndex++;
      _openVideo(widget.course.videos[_currentIndex].path);
      setState(() {});
    }
  }

  void _replay() {
    _player.seek(Duration.zero);
    _player.play();
  }

  void _toggleFullscreen() {
    _isFullscreen = !_isFullscreen;
    if (_isFullscreen) {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
    } else {
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    }
    setState(() {});
  }

  void _showIcon(bool isForward) {
    if (isForward) {
      _showForwardIcon = true;
    } else {
      _showRewindIcon = true;
    }
    _animController.reset();
    _animController.forward().then((_) {
      _showForwardIcon = false;
      _showRewindIcon = false;
    });
    setState(() {});
  }

  void _showPlayPause() {
    _showPlayPauseIcon = true;
    _playPauseIcon = _player.state.playing ? Icons.pause : Icons.play_arrow;
    setState(() {});
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _showPlayPauseIcon = false;
        setState(() {});
      }
    });
  }

  void _toggleControls() {
    setState(() => _showControls = !_showControls);
    if (_showControls) _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (mounted && _player.state.playing && _isFullscreen) {
        setState(() => _showControls = false);
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    _animController.dispose();
    _positionNotifier.dispose();
    _durationNotifier.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentVideo = widget.course.videos[_currentIndex];
    final fileName = p.basename(currentVideo.path);

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _isFullscreen ? null : AppBar(title: Text(fileName)),
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: () {
          _toggleControls();
          if (_player.state.playing) {
            _player.pause();
          } else {
            _player.play();
          }
          _showPlayPause();
        },
        onDoubleTapDown: (details) {
          final width = MediaQuery.of(context).size.width;
          final dx = details.localPosition.dx;
          if (dx < width / 2) {
            final newPos = _player.state.position - const Duration(seconds: 10);
            _player.seek(newPos >= Duration.zero ? newPos : Duration.zero);
            _showIcon(false);
          } else {
            final newPos = _player.state.position + const Duration(seconds: 10);
            _player.seek(
              newPos <= _player.state.duration
                  ? newPos
                  : _player.state.duration,
            );
            _showIcon(true);
          }
        },
        child: Stack(
          alignment: Alignment.center,
          children: [
            Video(controller: _controller, fit: BoxFit.contain, controls: null),

            // Animated icons
            if (_showRewindIcon)
              SlideTransition(
                position: _slideAnim,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: const Icon(
                    Icons.fast_rewind,
                    size: 80,
                    color: Colors.white70,
                  ),
                ),
              ),
            if (_showForwardIcon)
              SlideTransition(
                position: _slideAnim,
                child: FadeTransition(
                  opacity: _fadeAnim,
                  child: const Icon(
                    Icons.fast_forward,
                    size: 80,
                    color: Colors.white70,
                  ),
                ),
              ),
            if (_showPlayPauseIcon)
              AnimatedOpacity(
                opacity: _showPlayPauseIcon ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: Icon(_playPauseIcon, size: 80, color: Colors.white70),
              ),

            // Completion badge
            Positioned(
              top: 10,
              right: 10,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: currentVideo.isComplete ? Colors.green : Colors.orange,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  currentVideo.isComplete ? "Completed" : "In Progress",
                  style: const TextStyle(color: Colors.white, fontSize: 12),
                ),
              ),
            ),

            // Auto-hide controls
            if (_showControls)
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: VideoControls(
                  player: _player,
                  videoTitle: fileName,
                  playbackSpeed: _playbackSpeed,
                  positionNotifier: _positionNotifier,
                  durationNotifier: _durationNotifier,
                  onSpeedChange: (speed) {
                    _playbackSpeed = speed;
                    _player.setRate(speed);
                  },
                  onFullscreenToggle: _toggleFullscreen,
                  onPrevious: _playPrevious,
                  onNext: _playNext,
                  onReplay: _replay,
                  hasPrevious: _currentIndex > 0,
                  hasNext: _currentIndex < widget.course.videos.length - 1,
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class VideoControls extends StatelessWidget {
  final Player player;
  final String videoTitle;
  final double playbackSpeed;
  final Function(double) onSpeedChange;
  final VoidCallback onFullscreenToggle;
  final VoidCallback onPrevious;
  final VoidCallback onNext;
  final VoidCallback onReplay;
  final bool hasPrevious;
  final bool hasNext;

  final ValueNotifier<Duration> positionNotifier;
  final ValueNotifier<Duration> durationNotifier;

  const VideoControls({
    required this.player,
    required this.videoTitle,
    required this.playbackSpeed,
    required this.onSpeedChange,
    required this.onFullscreenToggle,
    required this.onPrevious,
    required this.onNext,
    required this.onReplay,
    required this.hasPrevious,
    required this.hasNext,
    required this.positionNotifier,
    required this.durationNotifier,
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
            valueListenable: positionNotifier,
            builder: (context, position, _) {
              final duration = durationNotifier.value;
              return Row(
                children: [
                  Text(
                    _formatDuration(position),
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
                        value: position.inMilliseconds
                            .clamp(0, duration.inMilliseconds)
                            .toDouble(),
                        min: 0,
                        max: duration.inMilliseconds.toDouble(),
                        onChanged: (val) {
                          player.seek(Duration(milliseconds: val.toInt()));
                        },
                      ),
                    ),
                  ),
                  Text(
                    _formatDuration(duration),
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
                  player.state.playing ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: () {
                  player.state.playing ? player.pause() : player.play();
                },
              ),
              IconButton(
                icon: const Icon(Icons.replay, color: Colors.white),
                onPressed: onReplay,
              ),
              IconButton(
                icon: const Icon(Icons.skip_previous, color: Colors.white),
                onPressed: hasPrevious ? onPrevious : null,
              ),
              IconButton(
                icon: const Icon(Icons.skip_next, color: Colors.white),
                onPressed: hasNext ? onNext : null,
              ),
              DropdownButton<double>(
                value: playbackSpeed,
                dropdownColor: Colors.black87,
                style: const TextStyle(color: Colors.white),
                items: [0.5, 1.0, 1.5, 2.0]
                    .map(
                      (e) => DropdownMenuItem(value: e, child: Text("${e}x")),
                    )
                    .toList(),
                onChanged: (val) {
                  if (val != null) onSpeedChange(val);
                },
              ),
              IconButton(
                icon: const Icon(Icons.fullscreen, color: Colors.white),
                onPressed: onFullscreenToggle,
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
