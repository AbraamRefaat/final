// Flutter imports:
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:untitled2/Controller/account_page_controller.dart';
import 'package:untitled2/utils/translation_helper.dart';
import 'package:untitled2/utils/widgets/AppBarWidget.dart';
import 'package:untitled2/Views/MainNavigationPage.dart';

class AccountPage extends StatelessWidget {
  final AccountPageController controller = Get.put(AccountPageController());

  AccountPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Get.theme.scaffoldBackgroundColor,
        endDrawer: CustomDrawer(),
        appBar: AppBarWidget(
          showSearch: false,
          goToSearch: false,
          showFilterBtn: false,
          showBack: false,
          showDrawer: true,
        ),
        body: RefreshIndicator(
          onRefresh: controller.refreshCourseReport,
          child: SingleChildScrollView(
            physics: AlwaysScrollableScrollPhysics(),
            padding: EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Page Title
                Container(
                  margin: EdgeInsets.only(bottom: 24),
                  child: Text(
                    TranslationHelper.tr("Account"),
                    style: Get.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                // Loading or Content
                Obx(() {
                  if (controller.isLoading.value) {
                    return Center(
                      child: Padding(
                        padding: EdgeInsets.all(40),
                        child: CupertinoActivityIndicator(),
                      ),
                    );
                  }

                  return Column(
                    children: [
                      // First Container - Enrolled Courses
                      Container(
                        width: double.infinity,
                        margin: EdgeInsets.only(bottom: 16),
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.blue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.blue.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            // Icon
                            Container(
                              width: 60,
                              height: 60,
                              margin: EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.blue,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Icon(
                                Icons.school,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),

                            // Title
                            Text(
                              TranslationHelper.tr("Enrolled Courses"),
                              style: Get.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.blue[700],
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: 8),

                            // Count
                            Text(
                              "${controller.enrolledCoursesCount}",
                              style: Get.textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.blue[800],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // Second Container - Finished Courses
                      Container(
                        width: double.infinity,
                        padding: EdgeInsets.all(20),
                        decoration: BoxDecoration(
                          color: Colors.green.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: Colors.green.withOpacity(0.3),
                            width: 1,
                          ),
                        ),
                        child: Column(
                          children: [
                            // Icon
                            Container(
                              width: 60,
                              height: 60,
                              margin: EdgeInsets.only(bottom: 12),
                              decoration: BoxDecoration(
                                color: Colors.green,
                                borderRadius: BorderRadius.circular(30),
                              ),
                              child: Icon(
                                Icons.check_circle,
                                color: Colors.white,
                                size: 30,
                              ),
                            ),

                            // Title
                            Text(
                              TranslationHelper.tr("Finished Courses"),
                              style: Get.textTheme.titleMedium?.copyWith(
                                fontWeight: FontWeight.w600,
                                color: Colors.green[700],
                              ),
                              textAlign: TextAlign.center,
                            ),

                            SizedBox(height: 8),

                            // Count
                            Text(
                              "${controller.finishedCoursesCount}",
                              style: Get.textTheme.headlineLarge?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.green[800],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                }),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
