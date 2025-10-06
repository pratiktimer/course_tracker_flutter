import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:media_kit/media_kit.dart';
import 'package:media_kit_video/media_kit_video.dart'
    show Video, VideoController;

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
  late Player _player;
  late VideoController _controller;
  late int _currentIndex;

  bool _isFullscreen = false;
  double _playbackSpeed = 1.0;
  bool _completedOnce = false;

  // Animated icons
  bool _showRewindIcon = false;
  bool _showForwardIcon = false;
  bool _showPlayPauseIcon = false;
  IconData _playPauseIcon = Icons.play_arrow;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
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
  }

  void _initPlayer() {
    _player = Player();
    _controller = VideoController(_player);

    _openVideo(widget.course.videos[_currentIndex].path);

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
  }

  void _openVideo(String path) {
    _completedOnce = false;
    _player.open(Media(path));
  }

  void _playPrevious() {
    if (_currentIndex > 0) {
      setState(() {
        _currentIndex--;
        _openVideo(widget.course.videos[_currentIndex].path);
      });
    }
  }

  void _playNext() {
    if (_currentIndex < widget.course.videos.length - 1) {
      setState(() {
        _currentIndex++;
        _openVideo(widget.course.videos[_currentIndex].path);
      });
    }
  }

  void _replay() {
    _player.seek(Duration.zero);
    _player.play();
  }

  void _toggleFullscreen() {
    setState(() => _isFullscreen = !_isFullscreen);
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
  }

  void _showIcon(bool isForward) {
    if (isForward) {
      setState(() {
        _showForwardIcon = true;
      });
    } else {
      setState(() {
        _showRewindIcon = true;
      });
    }

    _animController.reset();
    _animController.forward().then((_) {
      setState(() {
        _showForwardIcon = false;
        _showRewindIcon = false;
      });
    });
  }

  void _showPlayPause() {
    setState(() {
      _showPlayPauseIcon = true;
      _playPauseIcon = _player.state.playing ? Icons.pause : Icons.play_arrow;
    });

    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() {
          _showPlayPauseIcon = false;
        });
      }
    });
  }

  @override
  void dispose() {
    _player.dispose();
    _animController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final currentVideo = widget.course.videos[_currentIndex];
    final fileName = currentVideo.path.split(Platform.pathSeparator).last;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: _isFullscreen ? null : AppBar(title: Text(fileName)),
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            GestureDetector(
              behavior: HitTestBehavior.opaque,
              onTap: () {
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
                  final newPos =
                      _player.state.position - const Duration(seconds: 10);
                  _player.seek(
                    newPos >= Duration.zero ? newPos : Duration.zero,
                  );
                  _showIcon(false);
                } else {
                  final newPos =
                      _player.state.position + const Duration(seconds: 10);
                  _player.seek(
                    newPos <= _player.state.duration
                        ? newPos
                        : _player.state.duration,
                  );
                  _showIcon(true);
                }
              },
              child: Video(
                controller: _controller,
                fit: BoxFit.cover,
                controls: null,
              ),
            ),

            // Animated Rewind
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

            // Animated Forward
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

            // Animated Play/Pause
            if (_showPlayPauseIcon)
              AnimatedOpacity(
                opacity: _showPlayPauseIcon ? 1 : 0,
                duration: const Duration(milliseconds: 300),
                child: Icon(_playPauseIcon, size: 80, color: Colors.white70),
              ),

            // Completion Badge
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

            // Custom Controls
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: VideoControls(
                player: _player,
                videoTitle: fileName,
                playbackSpeed: _playbackSpeed,
                onSpeedChange: (speed) {
                  _playbackSpeed = speed;
                  _player.setRate(speed);
                  setState(() {});
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

class VideoControls extends StatefulWidget {
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

    widget.player.streams.position.listen((pos) {
      setState(() => _position = pos);
    });

    widget.player.streams.duration.listen((dur) {
      setState(() => _duration = dur);
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
          Align(
            alignment: Alignment.centerLeft,
            child: Text(
              widget.videoTitle,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Text(
                _formatDuration(_position),
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
                    secondaryActiveTrackColor:
                        Colors.transparent, // 🔥 disables red bar
                  ),
                  child: Slider(
                    value: _position.inMilliseconds
                        .clamp(0, _duration.inMilliseconds)
                        .toDouble(),
                    min: 0,
                    max: _duration.inMilliseconds.toDouble(),
                    onChanged: (value) {
                      widget.player.seek(Duration(milliseconds: value.toInt()));
                    },
                  ),
                ),
              ),
              Text(
                _formatDuration(_duration),
                style: const TextStyle(color: Colors.white70),
              ),
            ],
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: Icon(
                  widget.player.state.playing ? Icons.pause : Icons.play_arrow,
                  color: Colors.white,
                ),
                onPressed: () {
                  if (widget.player.state.playing) {
                    widget.player.pause();
                  } else {
                    widget.player.play();
                  }
                  setState(() {});
                },
              ),
              IconButton(
                icon: const Icon(Icons.replay, color: Colors.white),
                onPressed: widget.onReplay,
              ),
              IconButton(
                icon: const Icon(Icons.skip_previous, color: Colors.white),
                onPressed: widget.hasPrevious ? widget.onPrevious : null,
              ),
              IconButton(
                icon: const Icon(Icons.skip_next, color: Colors.white),
                onPressed: widget.hasNext ? widget.onNext : null,
              ),
              DropdownButton<double>(
                value: widget.playbackSpeed,
                dropdownColor: Colors.black87,
                style: const TextStyle(color: Colors.white),
                items: [0.5, 1.0, 1.5, 2.0]
                    .map(
                      (e) => DropdownMenuItem(value: e, child: Text("${e}x")),
                    )
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
