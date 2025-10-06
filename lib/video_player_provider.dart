import 'dart:async';
import 'package:flutter/material.dart';
import 'package:media_kit/media_kit.dart';
import 'models.dart';

class VideoPlayerProvider extends ChangeNotifier {
  final Player player = Player();

  int currentIndex;
  bool isFullscreen = false;
  double playbackSpeed = 1.0;
  bool showControls = true;

  bool showRewindIcon = false;
  bool showForwardIcon = false;
  bool showPlayPauseIcon = false;

  IconData playPauseIcon = Icons.play_arrow;

  final ValueNotifier<Duration> positionNotifier = ValueNotifier(Duration.zero);
  final ValueNotifier<Duration> durationNotifier = ValueNotifier(Duration.zero);

  Timer? _hideTimer;

  VideoPlayerProvider({this.currentIndex = 0}) {
    _listenToPlayer();
    _startHideTimer();
  }

  void _listenToPlayer() {
    player.streams.position.listen((pos) => positionNotifier.value = pos);
    player.streams.duration.listen((dur) => durationNotifier.value = dur);
  }

  void openVideo(String path) {
    player.open(Media(path));
    _showControlsTemporarily();
    notifyListeners();
  }

  void playPause() {
    if (player.state.playing) {
      player.pause();
    } else {
      player.play();
    }
    showPlayPauseTemporarily();
  }

  void skipForward(Duration d) {
    final newPos = player.state.position + d;
    player.seek(
      newPos <= player.state.duration ? newPos : player.state.duration,
    );
    showForwardIconTemporarily();
  }

  void skipBackward(Duration d) {
    final newPos = player.state.position - d;
    player.seek(newPos >= Duration.zero ? newPos : Duration.zero);
    showRewindIconTemporarily();
  }

  void setPlaybackSpeed(double speed) {
    playbackSpeed = speed;
    player.setRate(speed);
    notifyListeners();
  }

  void toggleControls() {
    showControls = !showControls;
    if (showControls) _startHideTimer();
    notifyListeners();
  }

  void _showControlsTemporarily() {
    showControls = true;
    _startHideTimer();
  }

  void _startHideTimer() {
    _hideTimer?.cancel();
    _hideTimer = Timer(const Duration(seconds: 3), () {
      if (player.state.playing) {
        showControls = false;
        notifyListeners();
      }
    });
  }

  void showRewindIconTemporarily() {
    showRewindIcon = true;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 500), () {
      showRewindIcon = false;
      notifyListeners();
    });
  }

  void showForwardIconTemporarily() {
    showForwardIcon = true;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 500), () {
      showForwardIcon = false;
      notifyListeners();
    });
  }

  void showPlayPauseTemporarily() {
    showPlayPauseIcon = true;
    playPauseIcon = player.state.playing ? Icons.pause : Icons.play_arrow;
    notifyListeners();
    Future.delayed(const Duration(milliseconds: 500), () {
      showPlayPauseIcon = false;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    player.dispose();
    positionNotifier.dispose();
    durationNotifier.dispose();
    _hideTimer?.cancel();
    super.dispose();
  }
}
