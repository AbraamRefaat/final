import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:http/http.dart' as http;
import 'package:loader_overlay/loader_overlay.dart';
import 'package:octo_image/octo_image.dart';
import 'package:vdocipher_flutter/vdocipher_flutter.dart';

import '../../Config/app_config.dart';
import '../../Model/Course/CourseMain.dart';
import '../../Views/VideoView/VideoChipherPage.dart';
import '../../Views/VideoView/ProfessionalVideoPlayer.dart';
import '../../Views/VideoView/VimeoPlayerPage.dart';
import '../../Views/checkout_page.dart';
import '../../Views/single_course_checkout_page.dart';
import '../../Controller/cart_controller.dart';
import '../../Controller/dashboard_controller.dart';
import '../CustomSnackBar.dart';
import '../CustomText.dart';
import '../translation_helper.dart';
import 'StarCounterWidget.dart';

// ignore: must_be_immutable
class CourseDetailsFlexilbleSpaceBar extends StatelessWidget {
  final CourseMain course;
  CourseDetailsFlexilbleSpaceBar(this.course);

  double width = 0;

  double percentageWidth = 0;

  double height = 0;

  double percentageHeight = 0;

  @override
  Widget build(BuildContext context) {
    width = MediaQuery.of(context).size.width;
    percentageWidth = width / 100;
    height = MediaQuery.of(context).size.height;
    percentageHeight = height / 100;

    return Container(
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Only show image if course.thumbnail exists and is not empty
          if (course.thumbnail != null &&
              course.thumbnail!.isNotEmpty &&
              course.thumbnail != '')
            OctoImage(
              image: NetworkImage('${course.thumbnail}'),
              fit: BoxFit.cover,
              errorBuilder: (BuildContext context, Object exception,
                  StackTrace? stackTrace) {
                // If image fails to load, show transparent container
                return Container(
                  color: Colors.grey.shade200,
                );
              },
            ),
          Container(
            padding: EdgeInsets.only(
              left: 26,
              right: 26,
              top: 40,
              bottom: 20,
            ),
            color: (course.thumbnail != null &&
                    course.thumbnail!.isNotEmpty &&
                    course.thumbnail != '')
                ? Colors.black.withOpacity(0.7)
                : Colors.black.withOpacity(0.3),
            child: SingleChildScrollView(
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  minHeight: height - 140, // Account for padding
                ),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: () => Get.back(),
                        child: Icon(
                          Icons.arrow_back_outlined,
                          color: Colors.white,
                          size: 24,
                        ),
                      ),
                      SizedBox(height: 20),
                      courseDescriptionTitle(course.title ?? ""),
                      courseDescriptionPublisher(course.user?.name ?? ''),
                      // Removed the review/rating line that showed (0) null 0 null
                      Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                StarCounterWidget(
                                  value: double.tryParse(
                                          course.review.toString()) ??
                                      0,
                                  color: Color(0xffFFCF23),
                                  size: 10,
                                ),
                                SizedBox(height: 5),
                                courseDescriptionPublisher('(' +
                                    '${course.review ?? ''}' +
                                    ') ' +
                                    "${stctrl.lang["based on"]}" +
                                    ' ' +
                                    '${course.reviews?.length ?? ''}' +
                                    ' ' +
                                    "${stctrl.lang["review"]}"),
                              ],
                            ),
                          ),
                          course.trailerLink != null &&
                                  course.host != "ImagePreview"
                              ? GestureDetector(
                                  child: CircleAvatar(
                                      radius: 20.0,
                                      backgroundColor: Color(0xFFD7598F),
                                      child: ClipRRect(
                                        child: Icon(
                                          Icons.play_arrow,
                                          size: 22,
                                          color: Colors.white,
                                        ),
                                        borderRadius:
                                            BorderRadius.circular(20.0),
                                      )),
                                  onTap: () async {
                                    if (course.host == "Vimeo") {
                                      var vimeoID = course.trailerLink
                                          ?.replaceAll("/videos/", "");
                                      Get.bottomSheet(
                                        VimeoPlayerPage(
                                          videoTitle: "${course.title}",
                                          videoId:
                                              '$rootUrl/vimeo/video/$vimeoID',
                                        ),
                                        backgroundColor: Colors.black,
                                        isScrollControlled: true,
                                      );
                                    } else if (course.host == "Youtube") {
                                      Get.bottomSheet(
                                        ProfessionalVideoPlayer(
                                          "Youtube",
                                          videoID: course.trailerLink,
                                        ),
                                        backgroundColor: Colors.black,
                                        isScrollControlled: true,
                                      );
                                    } else if (course.host == "VdoCipher") {
                                      await generateVdoCipherOtp(
                                              course.trailerLink)
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
                                          Get.bottomSheet(
                                            VdoCipherPage(
                                              embedInfo: embedInfo,
                                            ),
                                            backgroundColor: Colors.black,
                                            isScrollControlled: true,
                                          );
                                          context.loaderOverlay.hide();
                                        } else {
                                          context.loaderOverlay.hide();
                                          CustomSnackBar().snackBarWarning(
                                              value['message']);
                                        }
                                      });
                                    } else {
                                      var videoUrl;
                                      if (course.host == "Self") {
                                        videoUrl = rootUrl +
                                            "/" +
                                            course.trailerLink.toString();
                                      }
                                      Get.bottomSheet(
                                        ProfessionalVideoPlayer(
                                          "network",
                                          videoID: videoUrl,
                                        ),
                                        backgroundColor: Colors.black,
                                        isScrollControlled: true,
                                      );
                                    }
                                  },
                                )
                              : Container()
                        ],
                      ),
                      SizedBox(height: 15),
                      // Removed: Duration/time info, user count, and their containers
                      // (Row with Icons.access_time and Icons.person_add_alt_1)
                      SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseSection() {
    final DashboardController dashboardController =
        Get.put(DashboardController());
    final CartController cartController = Get.put(CartController());

    return Obx(() {
      // Check if user is logged in
      if (!dashboardController.loggedIn.value) {
        return _buildLoginPrompt();
      }

      // Check if course is already purchased (enrolled)
      bool isEnrolled = course.enrolls?.any((enroll) =>
              enroll.userId == dashboardController.profileData.id) ??
          false;

      if (isEnrolled) {
        return _buildEnrolledMessage();
      }

      // Check if course is free
      if (course.price != null && course.price == 0) {
        return _buildFreeCourseButton();
      }

      // Show purchase options
      return _buildPurchaseButtons(cartController);
    });
  }

  Widget _buildLoginPrompt() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          CustomSnackBar().snackBarWarning(
              TranslationHelper.tr("Please login to purchase"));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Get.theme.primaryColor,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          TranslationHelper.tr("Please Log in"),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildFreeCourseButton() {
    return Container(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () {
          CustomSnackBar().snackBarSuccess(TranslationHelper.tr("Free Course"));
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.green,
          foregroundColor: Colors.white,
          padding: EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8),
          ),
        ),
        child: Text(
          TranslationHelper.tr("Free Course"),
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildEnrolledMessage() {
    return Container(
      width: double.infinity,
      padding: EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.green.shade100,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.green, width: 1),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.check_circle, color: Colors.green, size: 20),
          SizedBox(width: 8),
          Text(
            TranslationHelper.tr("Course already purchased"),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.green.shade700,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPurchaseButtons(CartController cartController) {
    return Column(
      children: [
        // Price display - only show if price is available
        if (course.price != null)
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: 4),
            child: Text(
              '${course.price?.toStringAsFixed(2)} EGP',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
              textAlign: TextAlign.center,
            ),
          ),
        SizedBox(height: 8),
        // Single Buy Now button
        Container(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () async {
              _handleDirectPurchase();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Get.theme.primaryColor,
              foregroundColor: Colors.white,
              padding: EdgeInsets.symmetric(vertical: 12),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: Text(
              TranslationHelper.tr("Buy Now"),
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _handleDirectPurchase() async {
    try {
      // Get the cart controller
      final CartController cartController = Get.put(CartController());

      // Add course to cart using the new API endpoint
      bool success = await cartController.addToCart(course.id ?? 0);

      if (success) {
        // Navigate to cart/checkout page
        Get.to(() => CheckoutPage());
      } else {
        CustomSnackBar().snackBarError('Failed to add course to cart');
      }
    } catch (e) {
      CustomSnackBar().snackBarError('Error: $e');
    }
  }

  Future generateVdoCipherOtp(url) async {
    Uri apiUrl = Uri.parse('https://dev.vdocipher.com/api/videos/$url/otp');

    var response = await http.post(
      apiUrl,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Authorization': 'Apisecret $vdoCipherApiKey'
      },
    );
    var decoded = jsonDecode(response.body);
    return decoded;
  }
}
