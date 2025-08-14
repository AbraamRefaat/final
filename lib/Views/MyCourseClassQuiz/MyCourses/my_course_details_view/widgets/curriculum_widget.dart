import 'package:extended_nested_scroll_view/extended_nested_scroll_view.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/Controller/lesson_controller.dart';
import 'package:untitled2/Controller/myCourse_controller.dart';
import 'package:untitled2/Model/Course/Lesson.dart';
import 'package:untitled2/Views/MyCourseClassQuiz/MyCourses/my_course_details_view/utils/vdo_cipher_otp.dart';
import 'package:untitled2/Views/MyCourseClassQuiz/MyCourses/my_course_details_view/widgets/download_alert_dialog.dart';
import 'package:untitled2/Views/MyCourseClassQuiz/MyQuiz/start_quiz_page/start_quiz_page.dart';
import 'package:untitled2/Views/VideoView/PDFViewPage.dart';
import 'package:untitled2/Views/VideoView/VideoChipherPage.dart';
import 'package:untitled2/Views/VideoView/ProfessionalVideoPlayer.dart';
import 'package:untitled2/Views/VideoView/VimeoPlayerPage.dart';
import 'package:untitled2/utils/CustomExpansionTileCard.dart';
import 'package:untitled2/utils/CustomSnackBar.dart';
import 'package:untitled2/utils/CustomText.dart';
import 'package:untitled2/utils/MediaUtils.dart';
import 'package:untitled2/utils/open_files.dart';
import 'package:untitled2/utils/translation_helper.dart';
import 'package:loader_overlay/loader_overlay.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:vdocipher_flutter/vdocipher_flutter.dart';

import 'dart:developer';
import 'dart:io';

import 'package:untitled2/Controller/download_controller.dart';
import 'package:untitled2/utils/controller_utils.dart';

import 'package:untitled2/Views/Downloads/DownloadsFolder.dart';

import 'package:open_document/open_document.dart';
import 'package:path/path.dart' as p;
import 'package:path_provider/path_provider.dart';

/// Extract only the Arabic title from quiz title (remove ": en" part)
String? _getQuizTitle(dynamic title) {
  if (title == null) return null;

  String titleStr = title.toString();

  // Remove ": en" part if it exists
  if (titleStr.contains(': en')) {
    return titleStr.replaceAll(': en', '').trim();
  }

  return titleStr;
}

Widget curriculumWidget(
    MyCourseController controller, double percentageHeight) {
  // Test for lessons with quizzes when widget is created
  WidgetsBinding.instance.addPostFrameCallback((_) {
    try {
      // Safely get or create QuizController
      final quizController = ControllerUtils.getOrCreateQuizController();

      var allLessons = controller.myCourseDetails.value.lessons ?? [];
      var lessonIds = allLessons
          .map((lesson) => lesson.id ?? 0)
          .where((id) => id > 0)
          .cast<int>()
          .toList();

      if (lessonIds.isNotEmpty) {
        quizController.findLessonsWithQuizzes(lessonIds);
      }
    } catch (e) {
      // Handle any errors gracefully
      print('Error initializing QuizController: $e');
    }
  });

  void _scrollToSelectedContent(GlobalKey myKey) {
    final keyContext = myKey.currentContext;

    if (keyContext != null) {
      Future.delayed(Duration(milliseconds: 200)).then((value) {
        Scrollable.ensureVisible(keyContext,
            duration: Duration(milliseconds: 200));
      });
    }
  }

  return ExtendedVisibilityDetector(
    uniqueKey: const Key('curriculumWidget'),
    child: ListView.separated(
      itemCount: controller.myCourseDetails.value.chapters?.length ?? 0,
      physics: BouncingScrollPhysics(),
      padding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      separatorBuilder: (context, index) {
        return SizedBox(
          height: 4,
        );
      },
      itemBuilder: (BuildContext context, int index) {
        var lessons = controller.myCourseDetails.value.lessons
            ?.where((element) =>
                int.parse(element.chapterId.toString()) ==
                int.parse(controller.myCourseDetails.value.chapters?[index].id
                        .toString() ??
                    ''))
            .toList();
        var total = 0;
        lessons?.forEach((element) {
          if (element.duration != null && element.duration != "") {
            if (!element.duration!.contains("H")) {
              total += double.parse(element.duration ?? '').toInt();
            }
          }
        });
        final GlobalKey expansionTileKey = GlobalKey();

        return CustomExpansionTileCard(
          key: expansionTileKey,
          contentPadding: EdgeInsets.symmetric(horizontal: 10),
          onExpansionChanged: (isExpanded) {
            if (isExpanded) _scrollToSelectedContent(expansionTileKey);
          },
          title: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 5,
              ),
              Text(
                (index + 1).toString() + ". ",
              ),
              SizedBox(
                width: 0,
              ),
              Expanded(
                child: Text(
                  controller.myCourseDetails.value.chapters?[index].name ?? '',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              total > 0
                  ? Text(
                      getTimeString(total).toString() +
                          " ${TranslationHelper.tr("Hour(s)")}",
                    )
                  : SizedBox.shrink()
            ],
          ),
          children: <Widget>[
            ListView.builder(
                itemCount: lessons?.length ?? 0,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                itemBuilder: (BuildContext context, int index) {
                  return Obx(() {
                    return Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: controller.selectedLessonID.value ==
                                  lessons?[index].id
                              ? Get.theme.primaryColor
                              : Colors.transparent,
                        ),
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: lessons?[index].isQuiz == 1
                          ? InkWell(
                              onTap: () async {
                                controller.selectedLessonID.value =
                                    lessons?[index].id;
                                context.loaderOverlay.show();
                                // Safely get or create QuizController
                                final quizController =
                                    ControllerUtils.getOrCreateQuizController();

                                // Set course ID for context
                                quizController
                                    .setCourseID(controller.courseID.value);
                                quizController.selectedLessonID.value =
                                    lessons?[index].id;

                                await quizController
                                    .getLessonQuizDetails(
                                        lessons?[index].id ?? 0)
                                    .then((value) {
                                  context.loaderOverlay.hide();

                                  // Check if lesson has a quiz
                                  bool hasQuiz = value != null;
                                  if (!hasQuiz) {
                                    Get.snackbar(
                                      TranslationHelper.tr("No Quiz Available"),
                                      "This lesson does not have a quiz.",
                                      snackPosition: SnackPosition.BOTTOM,
                                      backgroundColor: Colors.orange,
                                      colorText: Colors.white,
                                      borderRadius: 5,
                                      duration: Duration(seconds: 3),
                                    );
                                    return;
                                  }

                                  // Set the actual quiz ID from the lesson quiz details
                                  quizController.lessonQuizId.value =
                                      value.id ?? 0;

                                  showDialog<String>(
                                    context: context,
                                    builder: (BuildContext context) =>
                                        AlertDialog(
                                      content: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "Start Quiz",
                                            style: GoogleFonts.roboto(
                                              textStyle: TextStyle(
                                                  color: Colors.black,
                                                  fontSize: 16
                                                  // Add other text styles like fontSize, fontWeight, etc. here
                                                  ),
                                            ),
                                          ),
                                          SizedBox(
                                            height: 20,
                                          ),
                                          courseStructure(
                                            TranslationHelper.tr(
                                                "Do you want to start the quiz?"),
                                          ),
                                          Builder(builder: (context) {
                                            final quizTime = quizController
                                                    .myQuizDetails
                                                    .value
                                                    .quiz
                                                    ?.questionTime ??
                                                0;
                                            final timeType = quizController
                                                    .myQuizDetails
                                                    .value
                                                    .quiz
                                                    ?.questionTimeType ??
                                                0;

                                            return courseStructure(
                                              timeType == 0
                                                  ? "${TranslationHelper.tr("Quiz Time")}: ${quizTime > 0 ? quizTime : 'No time limit'} ${TranslationHelper.tr("minute(s) per question")}"
                                                  : "${TranslationHelper.tr("Quiz Time")}: ${quizTime > 0 ? quizTime : 'No time limit'} ${TranslationHelper.tr("minute(s)")}",
                                            );
                                          }),
                                          SizedBox(
                                            height: 15,
                                          ),
                                          Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceEvenly,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              GestureDetector(
                                                onTap: () {
                                                  Navigator.pop(
                                                      context, 'Cancel');
                                                },
                                                child: Container(
                                                  width: 100,
                                                  height: percentageHeight * 5,
                                                  alignment: Alignment.center,
                                                  decoration: BoxDecoration(
                                                    color: Colors.transparent,
                                                    shape: BoxShape.rectangle,
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            5),
                                                  ),
                                                  child: Text(
                                                    TranslationHelper.tr(
                                                        "Cancel"),
                                                    style: Get
                                                        .textTheme.titleMedium,
                                                    textAlign: TextAlign.center,
                                                  ),
                                                ),
                                              ),
                                              Obx(() {
                                                return quizController
                                                        .isQuizStarting.value
                                                    ? Container(
                                                        width: 100,
                                                        height:
                                                            percentageHeight *
                                                                5,
                                                        alignment:
                                                            Alignment.center,
                                                        child:
                                                            CupertinoActivityIndicator())
                                                    : ElevatedButton(
                                                        onPressed: () async {
                                                          await quizController
                                                              .startQuizFromLesson()
                                                              .then((value) {
                                                            if (value) {
                                                              Navigator.pop(
                                                                  context);

                                                              if (quizController
                                                                      .myQuizDetails
                                                                      .value
                                                                      .quiz
                                                                      ?.assign
                                                                      ?.isEmpty ??
                                                                  true) {
                                                                Get.snackbar(
                                                                  TranslationHelper
                                                                      .tr("Error"),
                                                                  "No questions found for Quiz ID: ${quizController.lessonQuizId.value}. Check if this quiz has questions on the website.",
                                                                  snackPosition:
                                                                      SnackPosition
                                                                          .BOTTOM,
                                                                  backgroundColor:
                                                                      Colors
                                                                          .orange,
                                                                  colorText:
                                                                      Colors
                                                                          .white,
                                                                  borderRadius:
                                                                      5,
                                                                  duration:
                                                                      Duration(
                                                                          seconds:
                                                                              5),
                                                                );
                                                                return;
                                                              }

                                                              Get.to(() => StartQuizPage(
                                                                  getQuizDetails:
                                                                      quizController
                                                                          .myQuizDetails
                                                                          .value));
                                                            } else {
                                                              Get.snackbar(
                                                                TranslationHelper
                                                                    .tr("Error"),
                                                                TranslationHelper.tr(
                                                                    "Error Starting Quiz"),
                                                                snackPosition:
                                                                    SnackPosition
                                                                        .BOTTOM,
                                                                backgroundColor:
                                                                    Colors.red,
                                                                colorText:
                                                                    Colors
                                                                        .black,
                                                                borderRadius: 5,
                                                                duration:
                                                                    Duration(
                                                                        seconds:
                                                                            3),
                                                              );
                                                            }
                                                          });
                                                        },
                                                        child: Text(
                                                          TranslationHelper.tr(
                                                              "Start"),
                                                          style: TextStyle(
                                                              fontSize: 15,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w500,
                                                              color: Color(
                                                                  0xffffffff),
                                                              height: 1.3,
                                                              fontFamily:
                                                                  'AvenirNext'),
                                                          textAlign:
                                                              TextAlign.center,
                                                        ),
                                                      );
                                              })
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                });
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Icon(
                                      FontAwesomeIcons.questionCircle,
                                      color: Get.theme.primaryColor,
                                      size: 16,
                                    ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 2.0),
                                        child: Text(
                                            _getQuizTitle(lessons?[index]
                                                    .quiz?[0]
                                                    .title) ??
                                                "Quiz",
                                            style: Get.textTheme.titleSmall),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : InkWell(
                              onTap: () async {
                                context.loaderOverlay.show();

                                controller.selectedLessonID.value =
                                    lessons?[index].id;

                                if (lessons?[index].host == "Vimeo") {
                                  var vimeoID = lessons?[index]
                                      .videoUrl
                                      ?.replaceAll("/videos/", "");

                                  context.loaderOverlay.hide();
                                  Get.bottomSheet(
                                    VimeoPlayerPage(
                                      lesson: lessons?[index] ?? Lesson(),
                                      videoTitle: "${lessons?[index].name}",
                                      videoId: '$rootUrl/vimeo/video/$vimeoID',
                                    ),
                                    backgroundColor: Colors.black,
                                    isScrollControlled: true,
                                  );
                                } else if (lessons?[index].host == "Youtube") {
                                  context.loaderOverlay.hide();
                                  Get.to(ProfessionalVideoPlayer(
                                    "Youtube",
                                    lesson: lessons?[index] ?? Lesson(),
                                    videoID: lessons?[index].videoUrl ?? '',
                                  ));
                                } else if (lessons?[index].host == "SCORM") {
                                  var videoUrl =
                                      "$rootUrl/scorm/video/${lessons?[index].id}";

                                  final LessonController lessonController =
                                      Get.put(LessonController());

                                  await lessonController
                                      .updateLessonProgress(lessons?[index].id,
                                          lessons?[index].courseId, 1)
                                      .then((value) async {
                                    log("$rootUrl/scorm/video/${lessons?[index].id}");
                                    context.loaderOverlay.hide();
                                    Get.bottomSheet(
                                      VimeoPlayerPage(
                                        lesson: lessons?[index] ?? Lesson(),
                                        videoTitle: lessons?[index].name ?? '',
                                        videoId: videoUrl,
                                      ),
                                      backgroundColor: Colors.black,
                                      isScrollControlled: true,
                                    );
                                  });
                                } else if (lessons?[index].host ==
                                    "VdoCipher") {
                                  await generateVdoCipherOtp(
                                          lessons?[index].videoUrl)
                                      .then((value) {
                                    if (value['otp'] != null) {
                                      final EmbedInfo embedInfo =
                                          EmbedInfo.streaming(
                                        otp: value['otp'],
                                        playbackInfo: value['playbackInfo'],
                                        embedInfoOptions: EmbedInfoOptions(
                                          autoplay: true,
                                        ),
                                      );

                                      context.loaderOverlay.hide();
                                      Get.bottomSheet(
                                        VdoCipherPage(
                                          embedInfo: embedInfo,
                                          lesson: lessons?[index] ?? Lesson(),
                                        ),
                                        backgroundColor: Colors.black,
                                        isScrollControlled: true,
                                      );
                                    } else {
                                      context.loaderOverlay.hide();
                                      CustomSnackBar()
                                          .snackBarWarning(value['message']);
                                    }
                                  });
                                } else {
                                  var videoUrl;
                                  if (lessons?[index].host == "Self") {
                                    videoUrl = rootUrl +
                                        "/" +
                                        '${lessons?[index].videoUrl}';
                                    context.loaderOverlay.hide();
                                    Get.bottomSheet(
                                      VimeoPlayerPage(
                                        lesson: lessons?[index] ?? Lesson(),
                                        videoTitle: "${lessons?[index].name}",
                                        videoId: videoUrl,
                                      ),
                                      backgroundColor: Colors.black,
                                      isScrollControlled: true,
                                    );
                                  } else if (lessons?[index].host == "URL" ||
                                      lessons?[index].host == "Iframe") {
                                    videoUrl = lessons?[index].videoUrl;

                                    context.loaderOverlay.hide();
                                    Get.bottomSheet(
                                      VimeoPlayerPage(
                                        lesson: lessons?[index] ?? Lesson(),
                                        videoTitle: "${lessons?[index].name}",
                                        videoId: videoUrl,
                                      ),
                                      backgroundColor: Colors.black,
                                      isScrollControlled: true,
                                    );
                                  } else if (lessons?[index].host == "PDF") {
                                    videoUrl =
                                        '$rootUrl/${lessons?[index].videoUrl}';
                                    context.loaderOverlay.hide();
                                    Get.to(() => PDFViewPage(
                                          pdfLink: videoUrl,
                                        ));
                                  } else {
                                    videoUrl = lessons?[index].videoUrl;

                                    String filePath;

                                    final extension = p.extension(videoUrl);

                                    Directory applicationSupportDir =
                                        await getApplicationSupportDirectory();
                                    String folderPath =
                                        applicationSupportDir.path;

                                    filePath =
                                        "$folderPath/${companyName}_${lessons?[index].name}$extension";

                                    final isCheck =
                                        await OpenDocument.checkDocument(
                                            filePath: filePath);

                                    if (isCheck) {
                                      context.loaderOverlay.hide();
                                      if (extension.contains('.zip')) {
                                        Get.to(() => DownloadsFolder(
                                              filePath: folderPath,
                                              title: "My Downloads",
                                            ));
                                      } else {
                                        await openAppFile(filePath);
                                      }
                                    } else {
                                      final LessonController lessonController =
                                          Get.put(LessonController());

                                      // ignore: deprecated_member_use
                                      if (await canLaunch(
                                          rootUrl + '/' + videoUrl)) {
                                        await lessonController
                                            .updateLessonProgress(
                                                lessons?[index].id,
                                                lessons?[index].courseId,
                                                1)
                                            .then((value) async {
                                          context.loaderOverlay.hide();
                                          final DownloadController
                                              downloadController =
                                              Get.put(DownloadController());
                                          showDialog(
                                              context: context,
                                              builder: (context) {
                                                return showDownloadAlertDialog(
                                                  context,
                                                  lessons?[index].name ?? "",
                                                  videoUrl,
                                                  downloadController,
                                                );
                                              });
                                        });
                                      } else {
                                        context.loaderOverlay.hide();
                                        CustomSnackBar().snackBarError(
                                            "${TranslationHelper.tr("Unable to open")}" +
                                                " ${lessons?[index].name}");
                                        // throw 'Unable to open url : ${rootUrl + '/' + videoUrl}';
                                      }
                                    }
                                  }
                                }
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 10),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    !MediaUtils.isFile(
                                            lessons?[index].host ?? '')
                                        ? Icon(
                                            FontAwesomeIcons.solidPlayCircle,
                                            color: Get.theme.primaryColor,
                                            size: 16,
                                          )
                                        : Icon(
                                            FontAwesomeIcons.file,
                                            color: Get.theme.primaryColor,
                                            size: 16,
                                          ),
                                    SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(top: 2.0),
                                        child: Text(lessons?[index].name ?? "",
                                            style: Get.textTheme.titleSmall),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                    );
                  });
                }),
          ],
        );
      },
    ),
  );
}
