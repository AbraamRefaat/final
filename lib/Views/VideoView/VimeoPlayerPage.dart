// Dart imports:
import 'dart:io';

// Flutter imports:
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Package imports:
import 'package:get/get.dart';
import 'package:untitled2/Controller/lesson_controller.dart';
import 'package:untitled2/Model/Course/Lesson.dart';
import 'package:untitled2/utils/widgets/connectivity_checker_widget.dart';

// Project imports:

class VimeoPlayerPage extends StatefulWidget {
  final String? videoId;
  final String? videoTitle;
  final Lesson? lesson;

  VimeoPlayerPage({this.videoId, this.videoTitle, this.lesson});

  @override
  _VimeoPlayerPageState createState() => new _VimeoPlayerPageState();
}

class _VimeoPlayerPageState extends State<VimeoPlayerPage> {
  final LessonController lessonController = Get.put(LessonController());

  @override
  void initState() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft
    ]);
    super.initState();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ConnectionCheckerWidget(
      child: SafeArea(
        child: Scaffold(
          backgroundColor: Colors.black,
          body: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.video_library, size: 64, color: Colors.white),
                SizedBox(height: 16),
                Text(
                  'Video Player Temporarily Unavailable',
                  style: TextStyle(color: Colors.white, fontSize: 18),
                ),
                SizedBox(height: 8),
                Text(
                  'flutter_inappwebview dependency is disabled',
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => Get.back(),
                  child: Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
} 