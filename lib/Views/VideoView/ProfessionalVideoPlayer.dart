import 'dart:async';
import 'dart:io';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:untitled2/Controller/lesson_controller.dart';
import 'package:untitled2/Model/Course/Lesson.dart';
import 'package:untitled2/utils/widgets/connectivity_checker_widget.dart';
import 'package:untitled2/utils/screenshot_protection_helper.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class ProfessionalVideoPlayer extends StatefulWidget {
  final String? videoID;
  final Lesson? lesson;
  final String? source;

  ProfessionalVideoPlayer(this.source, {this.videoID, this.lesson});

  @override
  _ProfessionalVideoPlayerState createState() =>
      _ProfessionalVideoPlayerState();
}

class _ProfessionalVideoPlayerState extends State<ProfessionalVideoPlayer> with ScreenshotProtectionMixin {
  final LessonController lessonController = Get.put(LessonController());
  final GetStorage _storage = GetStorage();

  VideoPlayerController? _videoController;
  ChewieController? _chewieController;

  bool _isLoading = true;
  bool _hasError = false;
  String? _errorMessage;
  bool _showControls = true;
  Timer? _controlsTimer;
  Timer? _bufferingTimer;
  bool _isFullScreen = false;

  // Enhanced control states
  bool _isPlaying = false;
  bool _isBuffering = false;
  Duration _currentPosition = Duration.zero;
  Duration _totalDuration = Duration.zero;
  double _playbackSpeed = 1.0;

  // Buffering management
  bool _forceStopBuffering = false;

  @override
  void initState() {
    super.initState();
    
    // Enable screenshot protection for video content
    ScreenshotProtectionHelper.enableForVideoContent();
    
    _initializePlayer();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);

    // Auto-hide controls initially
    _startControlsTimer();
  }

  Future<void> _initializePlayer() async {
    try {
      setState(() {
        _isLoading = true;
        _hasError = false;
        _errorMessage = null;
      });

      String? videoUrl = await _getVideoUrl();
      if (videoUrl == null) {
        _setError("Could not load video URL");
        return;
      }

      // Initialize video controller with iOS-specific handling
      _videoController = VideoPlayerController.networkUrl(Uri.parse(videoUrl));

      // iOS-specific video player configuration
      if (Platform.isIOS) {
        // Add iOS-specific headers if needed
        // _videoController!.setLooping(true);
      }

      // Set up event listeners
      _videoController!.addListener(_videoListener);

      // Initialize the controller
      await _videoController!.initialize();

      // Get saved position and seek to it
      final lastPosition = await _getLastPosition();
      if (lastPosition != null) {
        await _videoController!.seekTo(lastPosition);
      }

      // Set up Chewie with custom controls disabled
      _chewieController = ChewieController(
        videoPlayerController: _videoController!,
        autoPlay: true,
        looping: false,
        showControls: false, // We use custom controls
        allowFullScreen: false, // We handle fullscreen manually
        allowMuting: true,
        allowPlaybackSpeedChanging: false, // We handle speed manually
        showOptions: false,
        errorBuilder: (context, errorMessage) =>
            _buildErrorWidget(errorMessage),
      );

      setState(() {
        _isLoading = false;
        _totalDuration = _videoController!.value.duration;
      });
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<String?> _getVideoUrl() async {
    String? videoUrl = widget.videoID;

    if (widget.source == "Youtube") {
      try {
        final yt = YoutubeExplode();
        final videoId = VideoId(widget.videoID!);
        final manifest = await yt.videos.streamsClient.getManifest(videoId);

        // Get best quality muxed stream (video + audio)
        final streamInfo = manifest.muxed.withHighestBitrate();
        videoUrl = streamInfo.url.toString();

        yt.close();
      } catch (e) {
        return null;
      }
    }

    return videoUrl;
  }

  void _videoListener() {
    if (!mounted || _videoController == null) return;

    final value = _videoController!.value;

    // Update playing state
    if (_isPlaying != value.isPlaying) {
      setState(() {
        _isPlaying = value.isPlaying;
      });
    }

    // Enhanced buffering management
    _handleBufferingState(value.isBuffering);

    // Update position
    if (_currentPosition != value.position) {
      setState(() {
        _currentPosition = value.position;
      });
    }

    // Handle video completion
    if (value.position >= value.duration && value.duration.inMilliseconds > 0) {
      _onVideoCompleted();
    }
  }

  void _handleBufferingState(bool isCurrentlyBuffering) {
    // Simple and reliable buffering state management
    if (_isBuffering != isCurrentlyBuffering) {
      _bufferingTimer?.cancel();

      if (isCurrentlyBuffering) {
        // Start buffering
        setState(() {
          _isBuffering = true;
          _forceStopBuffering = false;
        });

        // Force stop buffering after 4 seconds if still stuck
        _bufferingTimer = Timer(Duration(seconds: 4), () {
          if (mounted && _isBuffering) {
            setState(() {
              _isBuffering = false;
              _forceStopBuffering = false;
            });
          }
        });
      } else {
        // Stop buffering immediately
        setState(() {
          _isBuffering = false;
          _forceStopBuffering = false;
        });
      }
    }
  }

  void _refreshVideoPosition() {
    // Simple refresh - just force stop buffering
    if (mounted) {
      setState(() {
        _isBuffering = false;
        _forceStopBuffering = false;
      });
    }
  }

  void _setError(String message) {
    setState(() {
      _hasError = true;
      _errorMessage = message;
      _isLoading = false;
    });
  }

  void _onVideoCompleted() {
    setState(() {
      _isPlaying = false;
    });

    if (widget.lesson != null) {
      lessonController
          .updateLessonProgress(widget.lesson?.id, widget.lesson?.courseId, 1)
          .then((value) => Get.back());
    }
  }

  Future<Duration?> _getLastPosition() async {
    if (widget.lesson?.id == null) return null;
    final key = 'last_position_${widget.lesson!.id}';
    final positionInSeconds = _storage.read<int>(key);
    if (positionInSeconds != null && positionInSeconds > 0) {
      return Duration(seconds: positionInSeconds);
    }
    return null;
  }

  Future<void> _saveLastPosition() async {
    if (widget.lesson?.id == null || _videoController == null) return;
    final key = 'last_position_${widget.lesson!.id}';
    final position = _videoController!.value.position;
    if (position.inSeconds > 0) {
      await _storage.write(key, position.inSeconds);
    }
  }

  // Control methods
  void _togglePlayPause() {
    if (_videoController != null) {
      if (_isPlaying) {
        _videoController!.pause();
      } else {
        _videoController!.play();
      }
    }
    _startControlsTimer();
  }

  Future<void> _seekToPosition(Duration position) async {
    if (_videoController == null) return;

    try {
      await _videoController!.seekTo(position);
      // Let the video controller handle buffering state naturally
    } catch (e) {}

    _startControlsTimer();
  }

  void _skipBackward() {
    if (_videoController != null) {
      final current = _videoController!.value.position;
      final newPosition = current - Duration(seconds: 10);
      final targetPosition =
          newPosition.isNegative ? Duration.zero : newPosition;
      _seekToPosition(targetPosition);
    }
  }

  void _skipForward() {
    if (_videoController != null) {
      final current = _videoController!.value.position;
      final duration = _videoController!.value.duration;
      final newPosition = current + Duration(seconds: 10);
      final targetPosition = newPosition > duration ? duration : newPosition;
      _seekToPosition(targetPosition);
    }
  }

  void _changePlaybackSpeed(double speed) {
    setState(() {
      _playbackSpeed = speed;
    });
    _videoController?.setPlaybackSpeed(speed);
    _startControlsTimer();
  }

  void _onProgressChange(double value) {
    if (_totalDuration.inMilliseconds > 0) {
      final position = Duration(
          milliseconds: (value * _totalDuration.inMilliseconds).round());
      _seekToPosition(position);
    }
  }

  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    if (_showControls) {
      _startControlsTimer();
    } else {
      _controlsTimer?.cancel();
    }
  }

  void _startControlsTimer() {
    _controlsTimer?.cancel();
    _controlsTimer = Timer(Duration(seconds: 4), () {
      if (mounted && _showControls && _isPlaying) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  void _toggleFullScreen() {
    setState(() {
      _isFullScreen = !_isFullScreen;
    });

    if (_isFullScreen) {
      SystemChrome.setPreferredOrientations([
        DeviceOrientation.landscapeLeft,
        DeviceOrientation.landscapeRight,
      ]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersiveSticky);
    } else {
      SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
      SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    }
    _startControlsTimer();
  }

  void _retryLoading() {
    _initializePlayer();
  }

  String _formatDuration(Duration duration) {
    final hours = duration.inHours;
    final minutes = duration.inMinutes.remainder(60);
    final seconds = duration.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    }
  }

  Widget _buildErrorWidget(String errorMessage) {
    return Container(
      color: Colors.black,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            const Text(
              'Video Error',
              style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                errorMessage,
                style: const TextStyle(color: Colors.white70, fontSize: 14),
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ElevatedButton.icon(
                  onPressed: _retryLoading,
                  icon: const Icon(Icons.refresh),
                  label: const Text('Retry'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                ),
                const SizedBox(width: 16),
                ElevatedButton.icon(
                  onPressed: () => Get.back(),
                  icon: const Icon(Icons.arrow_back),
                  label: const Text('Back'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.grey[800],
                    foregroundColor: Colors.white,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _saveLastPosition();
    _controlsTimer?.cancel();
    _bufferingTimer?.cancel();
    _videoController?.removeListener(_videoListener);
    _videoController?.dispose();
    _chewieController?.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConnectionCheckerWidget(
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          child: GestureDetector(
            onTap: _toggleControls,
            child: Stack(
              children: [
                // Video Player
                if (_chewieController != null && !_isLoading && !_hasError)
                  Center(
                    child: AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: Chewie(controller: _chewieController!),
                    ),
                  ),

                // Loading State
                if (_isLoading)
                  Container(
                    color: Colors.black,
                    child: const Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          CircularProgressIndicator(
                            valueColor:
                                AlwaysStoppedAnimation<Color>(Colors.red),
                          ),
                          SizedBox(height: 16),
                          Text(
                            'Loading video...',
                            style: TextStyle(color: Colors.white, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Error State
                if (_hasError)
                  _buildErrorWidget(_errorMessage ?? 'Unknown error occurred'),

                // Buffering Overlay (simpler and less intrusive)
                if (_isBuffering && !_isLoading && !_hasError)
                  Positioned(
                    top: 80,
                    right: 16,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.black.withValues(alpha: 0.8),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Loading...',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                          const SizedBox(width: 8),
                          GestureDetector(
                            onTap: () {
                              setState(() {
                                _isBuffering = false;
                                _forceStopBuffering = false;
                              });
                            },
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 16,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Custom Controls Overlay
                if (_showControls && !_isLoading && !_hasError)
                  AnimatedOpacity(
                    opacity: _showControls ? 1.0 : 0.0,
                    duration: const Duration(milliseconds: 300),
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topCenter,
                          end: Alignment.bottomCenter,
                          colors: [
                            Colors.black.withValues(alpha: 0.8),
                            Colors.transparent,
                            Colors.transparent,
                            Colors.black.withValues(alpha: 0.8),
                          ],
                        ),
                      ),
                      child: Stack(
                        children: [
                          // Top Controls
                          Positioned(
                            top: 16,
                            left: 16,
                            right: 16,
                            child: Row(
                              children: [
                                IconButton(
                                  onPressed: () => Get.back(),
                                  icon: const Icon(Icons.arrow_back,
                                      color: Colors.white, size: 28),
                                ),
                                const Spacer(),

                                // Speed Control
                                PopupMenuButton<double>(
                                  icon: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 12, vertical: 6),
                                    decoration: BoxDecoration(
                                      color: Colors.black54,
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                    child: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        const Icon(Icons.speed,
                                            color: Colors.white, size: 18),
                                        const SizedBox(width: 6),
                                        Text(
                                          '${_playbackSpeed}x',
                                          style: const TextStyle(
                                              color: Colors.white,
                                              fontSize: 14),
                                        ),
                                      ],
                                    ),
                                  ),
                                  onSelected: _changePlaybackSpeed,
                                  itemBuilder: (context) => [
                                    const PopupMenuItem(
                                        value: 0.25, child: Text('0.25x')),
                                    const PopupMenuItem(
                                        value: 0.5, child: Text('0.5x')),
                                    const PopupMenuItem(
                                        value: 0.75, child: Text('0.75x')),
                                    const PopupMenuItem(
                                        value: 1.0,
                                        child: Text('1.0x (Normal)')),
                                    const PopupMenuItem(
                                        value: 1.25, child: Text('1.25x')),
                                    const PopupMenuItem(
                                        value: 1.5, child: Text('1.5x')),
                                    const PopupMenuItem(
                                        value: 1.75, child: Text('1.75x')),
                                    const PopupMenuItem(
                                        value: 2.0, child: Text('2.0x')),
                                  ],
                                ),

                                const SizedBox(width: 8),

                                IconButton(
                                  onPressed: _toggleFullScreen,
                                  icon: Icon(
                                    _isFullScreen
                                        ? Icons.fullscreen_exit
                                        : Icons.fullscreen,
                                    color: Colors.white,
                                    size: 28,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Center Controls
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Skip Backward
                                Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    onPressed: _skipBackward,
                                    icon: const Icon(Icons.replay_10,
                                        color: Colors.white, size: 36),
                                    iconSize: 48,
                                  ),
                                ),

                                // Play/Pause
                                Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    onPressed: _togglePlayPause,
                                    icon: Icon(
                                      _isPlaying
                                          ? Icons.pause
                                          : Icons.play_arrow,
                                      color: Colors.white,
                                      size: 48,
                                    ),
                                    iconSize: 64,
                                  ),
                                ),

                                // Skip Forward
                                Container(
                                  decoration: const BoxDecoration(
                                    color: Colors.black54,
                                    shape: BoxShape.circle,
                                  ),
                                  child: IconButton(
                                    onPressed: _skipForward,
                                    icon: const Icon(Icons.forward_10,
                                        color: Colors.white, size: 36),
                                    iconSize: 48,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Bottom Controls
                          Positioned(
                            bottom: 16,
                            left: 16,
                            right: 16,
                            child: Column(
                              children: [
                                // Progress Bar
                                SliderTheme(
                                  data: SliderThemeData(
                                    trackHeight: 4,
                                    thumbShape: const RoundSliderThumbShape(
                                        enabledThumbRadius: 8),
                                    overlayShape: const RoundSliderOverlayShape(
                                        overlayRadius: 16),
                                    activeTrackColor: Colors.red,
                                    inactiveTrackColor: Colors.white30,
                                    thumbColor: Colors.red,
                                    overlayColor:
                                        Colors.red.withValues(alpha: 0.3),
                                  ),
                                  child: Slider(
                                    value: _totalDuration.inMilliseconds > 0
                                        ? _currentPosition.inMilliseconds /
                                            _totalDuration.inMilliseconds
                                        : 0.0,
                                    onChanged: _onProgressChange,
                                  ),
                                ),

                                // Time Display
                                Padding(
                                  padding:
                                      const EdgeInsets.symmetric(horizontal: 8),
                                  child: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        _formatDuration(_currentPosition),
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      ),
                                      Text(
                                        _formatDuration(_totalDuration),
                                        style: const TextStyle(
                                            color: Colors.white, fontSize: 14),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
