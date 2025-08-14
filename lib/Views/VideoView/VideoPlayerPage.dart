import 'dart:async';
import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:untitled2/Controller/lesson_controller.dart';
import 'package:untitled2/Model/Course/Lesson.dart';
import 'package:untitled2/utils/widgets/connectivity_checker_widget.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_explode_dart/youtube_explode_dart.dart';

class VideoPlayerPage extends StatefulWidget {
  final String? videoID;
  final Lesson? lesson;
  final String? source;

  VideoPlayerPage(this.source, {this.videoID, this.lesson});

  @override
  _VideoPlayerPageState createState() => _VideoPlayerPageState();
}

class _VideoPlayerPageState extends State<VideoPlayerPage> {
  final LessonController lessonController = Get.put(LessonController());
  final GetStorage _storage = GetStorage();
  late VideoPlayerController _videoPlayerController;
  late ChewieController _chewieController;
  bool _isLoading = true;
  bool _isBuffering = false;
  bool _isVideoEnded = false;
  bool _showControls = true;
  double _playbackSpeed = 1.0;
  bool _isSeeking = false;
  DateTime? _lastSeekTime;
  Timer? _bufferingTimeout;

  @override
  void initState() {
    super.initState();
    _initializePlayer();

    // Show controls initially, then auto-hide after 3 seconds
    Future.delayed(Duration(seconds: 3), () {
      if (mounted) {
        setState(() {
          _showControls = false;
        });
      }
    });
  }

  Future<void> _initializePlayer() async {
    String? videoUrl = widget.videoID;

    if (widget.source == "Youtube") {
      final yt = YoutubeExplode();
      final videoId = VideoId(widget.videoID!);
      final manifest = await yt.videos.streamsClient.getManifest(videoId);
      final streamInfo = manifest.muxed.bestQuality;
      videoUrl = streamInfo.url.toString();
      yt.close();
    }

    if (videoUrl == null) {
      if (mounted) setState(() => _isLoading = false);
      return;
    }

    _videoPlayerController = VideoPlayerController.network(videoUrl);

    final lastPosition = await _getLastPosition();
    await _videoPlayerController.initialize();

    _chewieController = ChewieController(
      videoPlayerController: _videoPlayerController,
      autoPlay: true,
      looping: false,
      startAt: lastPosition,
      progressIndicatorDelay: null, // Disable default loader
    );

    _videoPlayerController.addListener(() {
      if (!mounted) return;

      // Enhanced buffering state management with timeout
      final currentBuffering = _videoPlayerController.value.isBuffering;

      if (_isBuffering != currentBuffering) {
        if (currentBuffering) {
          setState(() {
            _isBuffering = true;
          });

          // Set timeout to force stop buffering if it gets stuck (after 10 seconds)
          _bufferingTimeout?.cancel();
          _bufferingTimeout = Timer(Duration(seconds: 10), () {
            if (mounted && _isBuffering) {
              setState(() {
                _isBuffering = false;
              });
              // Try to refresh the video position to unstuck
              _refreshVideoPosition();
            }
          });
        } else {
          // Cancel timeout and hide buffering with short delay
          _bufferingTimeout?.cancel();

          // If we were seeking, reset seeking state
          if (_isSeeking) {
            _isSeeking = false;
          }

          Future.delayed(Duration(milliseconds: 300), () {
            if (mounted && !_videoPlayerController.value.isBuffering) {
              setState(() {
                _isBuffering = false;
              });
            }
          });
        }
      }

      // Check if seeking operation completed
      if (_isSeeking && _lastSeekTime != null) {
        final timeSinceSeek = DateTime.now().difference(_lastSeekTime!);
        if (timeSinceSeek.inSeconds > 5 && !currentBuffering) {
          // Seeking took too long, reset state
          setState(() {
            _isSeeking = false;
            _isBuffering = false;
          });
        }
      }

      if (_videoPlayerController.value.position >=
              _videoPlayerController.value.duration &&
          !_isVideoEnded) {
        setState(() {
          _isVideoEnded = true;
        });
        if (widget.lesson != null) {
          lessonController
              .updateLessonProgress(
                  widget.lesson?.id, widget.lesson?.courseId, 1)
              .then((value) => Get.back());
        }
      }
    });

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<Duration?> _getLastPosition() async {
    if (widget.lesson?.id == null) return null;
    final key = 'last_position_${widget.lesson!.id}';
    final positionInSeconds = _storage.read<int>(key);
    if (positionInSeconds != null) {
      return Duration(seconds: positionInSeconds);
    }
    return null;
  }

  Future<void> _saveLastPosition(Duration position) async {
    if (widget.lesson?.id == null) return;
    final key = 'last_position_${widget.lesson!.id}';
    await _storage.write(key, position.inSeconds);
  }

  // Enhanced seeking with better state management
  Future<void> _seekToPosition(Duration position) async {
    setState(() {
      _isSeeking = true;
      _isBuffering = true;
    });
    _lastSeekTime = DateTime.now();

    try {
      await _videoPlayerController.seekTo(position);

      // Wait a bit for the seek to complete
      await Future.delayed(Duration(milliseconds: 100));

      // Force refresh if needed
      if (_videoPlayerController.value.isBuffering) {
        await Future.delayed(Duration(milliseconds: 500));
      }
    } catch (e) {}

    // Reset seeking state after max 3 seconds
    Timer(Duration(seconds: 3), () {
      if (mounted && _isSeeking) {
        setState(() {
          _isSeeking = false;
          _isBuffering = false;
        });
      }
    });
  }

  // Skip backward 10 seconds
  void _skipBackward() {
    final currentPosition = _videoPlayerController.value.position;
    final newPosition = currentPosition - Duration(seconds: 10);
    final targetPosition = newPosition.isNegative ? Duration.zero : newPosition;
    _seekToPosition(targetPosition);
  }

  // Skip forward 10 seconds
  void _skipForward() {
    final currentPosition = _videoPlayerController.value.position;
    final duration = _videoPlayerController.value.duration;
    final newPosition = currentPosition + Duration(seconds: 10);
    final targetPosition = newPosition > duration ? duration : newPosition;
    _seekToPosition(targetPosition);
  }

  // Refresh video position to unstuck buffering
  void _refreshVideoPosition() {
    final currentPosition = _videoPlayerController.value.position;
    // Seek to current position + 1ms to refresh
    _videoPlayerController.seekTo(currentPosition + Duration(milliseconds: 1));
  }

  // Change playback speed
  void _changePlaybackSpeed(double speed) {
    setState(() {
      _playbackSpeed = speed;
    });
    _videoPlayerController.setPlaybackSpeed(speed);
  }

  // Toggle controls visibility
  void _toggleControls() {
    setState(() {
      _showControls = !_showControls;
    });

    // Auto-hide controls after 3 seconds
    if (_showControls) {
      Future.delayed(Duration(seconds: 3), () {
        if (mounted && _showControls) {
          setState(() {
            _showControls = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _saveLastPosition(_videoPlayerController.value.position);
    _bufferingTimeout?.cancel();
    _videoPlayerController.dispose();
    _chewieController.dispose();
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
                if (!_isLoading)
                  Center(
                    child: Chewie(
                      controller: _chewieController,
                    ),
                  ),

                // Loading/Buffering indicator
                if (_isLoading || _isBuffering)
                  Container(
                    color: Colors.black54,
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),

                // Custom Controls Overlay
                if (_showControls && !_isLoading)
                  AnimatedOpacity(
                    opacity: _showControls ? 1.0 : 0.0,
                    duration: Duration(milliseconds: 300),
                    child: Container(
                      color: Colors.black45,
                      child: Stack(
                        children: [
                          // Back button
                          Positioned(
                            top: 20,
                            left: 10,
                            child: IconButton(
                              onPressed: () => Get.back(),
                              icon: const Icon(Icons.arrow_back,
                                  color: Colors.white, size: 30),
                            ),
                          ),

                          // Center controls (Skip back, Play/Pause, Skip forward)
                          Center(
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                // Skip backward 10s
                                IconButton(
                                  onPressed: _skipBackward,
                                  icon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.replay_10,
                                          color: Colors.white, size: 40),
                                    ],
                                  ),
                                ),

                                // Play/Pause (handled by Chewie)
                                SizedBox(
                                    width: 80), // Space for default play button

                                // Skip forward 10s
                                IconButton(
                                  onPressed: _skipForward,
                                  icon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.forward_10,
                                          color: Colors.white, size: 40),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // Speed control (top right)
                          Positioned(
                            top: 20,
                            right: 10,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                // Refresh button (if buffering too long)
                                if (_isBuffering)
                                  IconButton(
                                    onPressed: () {
                                      setState(() {
                                        _isBuffering = false;
                                        _isSeeking = false;
                                      });
                                      _refreshVideoPosition();
                                    },
                                    icon: Icon(Icons.refresh,
                                        color: Colors.white, size: 24),
                                  ),
                                SizedBox(width: 5),
                                // Speed control
                                PopupMenuButton<double>(
                                  icon: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      Icon(Icons.speed, color: Colors.white),
                                      SizedBox(width: 5),
                                      Text(
                                        '${_playbackSpeed}x',
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ],
                                  ),
                                  onSelected: _changePlaybackSpeed,
                                  itemBuilder: (context) => [
                                    PopupMenuItem(
                                        value: 0.5, child: Text('0.5x')),
                                    PopupMenuItem(
                                        value: 0.75, child: Text('0.75x')),
                                    PopupMenuItem(
                                        value: 1.0,
                                        child: Text('1.0x (Normal)')),
                                    PopupMenuItem(
                                        value: 1.25, child: Text('1.25x')),
                                    PopupMenuItem(
                                        value: 1.5, child: Text('1.5x')),
                                    PopupMenuItem(
                                        value: 2.0, child: Text('2.0x')),
                                  ],
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
