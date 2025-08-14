import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:untitled2/Controller/home_controller.dart';
import 'package:untitled2/Controller/myCourse_controller.dart';
import 'package:untitled2/Views/Home/Course/course_details_page/course_details_page.dart';
import 'package:untitled2/Views/MyCourseClassQuiz/MyCourses/my_course_details_view/my_course_details_view.dart';
import 'package:untitled2/utils/widgets/SingleCardItemWidget.dart';
import 'package:untitled2/utils/translation_helper.dart';
import 'package:loader_overlay/loader_overlay.dart';

class AllCourseView extends StatefulWidget {
  @override
  _AllCourseViewState createState() => _AllCourseViewState();
}

class _AllCourseViewState extends State<AllCourseView> {
  final TextEditingController _searchController = TextEditingController();
  final RxString _searchQuery = ''.obs;

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final HomeController _homeController = Get.put(HomeController());

    return Scaffold(
      backgroundColor: Get.theme.colorScheme.background,
      appBar: AppBar(
        elevation: 0.5,
        shadowColor: Get.theme.shadowColor,
        backgroundColor: Get.theme.appBarTheme.backgroundColor,
        leading: IconButton(
          onPressed: () {
            Get.back();
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Get.theme.appBarTheme.iconTheme?.color,
          ),
        ),
        centerTitle: false,
        title: Text(
          TranslationHelper.tr("All Courses"),
          style: Get.textTheme.titleMedium?.copyWith(
            fontSize: 20,
          ),
        ),
      ),
      body: LoaderOverlay(
        useDefaultLoading: false,
        overlayWidgetBuilder: (_) => Center(
          child: CupertinoActivityIndicator(),
        ),
        child: Container(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 20),
          child: Column(
            children: [
              // Search bar (not reactive, just updates the observable)
              TextField(
                controller: _searchController,
                onChanged: (value) => _searchQuery.value = value,
                decoration: InputDecoration(
                  hintText: TranslationHelper.tr('What do you want to learn?'),
                  prefixIcon: Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 0, horizontal: 16),
                ),
              ),
              SizedBox(height: 16),
              // Course grid
              Expanded(
                child: Obx(() {
                  if (_homeController.isLoading.value) {
                    return Center(child: CupertinoActivityIndicator());
                  } else {
                    // Filter courses by search query
                    final query = _searchQuery.value.trim().toLowerCase();
                    final filteredCourses = query.isEmpty
                        ? _homeController.allCourse
                        : _homeController.allCourse.where((course) {
                            final title = course.title?.toLowerCase() ?? '';
                            final instructor =
                                course.assignedInstructor?.toLowerCase() ?? '';
                            return title.contains(query) ||
                                instructor.contains(query);
                          }).toList();
                    if (filteredCourses.isEmpty) {
                      return Center(
                          child: Text(
                              TranslationHelper.tr('No course available')));
                    }
                    return GridView.builder(
                      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                        crossAxisSpacing: 10.0,
                        mainAxisSpacing: 10.0,
                        mainAxisExtent: 200,
                      ),
                      scrollDirection: Axis.vertical,
                      shrinkWrap: false,
                      itemCount: filteredCourses.length,
                      physics: BouncingScrollPhysics(),
                      itemBuilder: (BuildContext context, int index) {
                        final course = filteredCourses[index];
                        return SingleItemCardWidget(
                          showPricing: true,
                          image: course.image,
                          title: course.title,
                          subTitle: course.assignedInstructor,
                          price: course.price,
                          discountPrice: course.discountPrice,
                          onTap: () async {
                            context.loaderOverlay.show();
                            // Get course details first
                            _homeController.courseID.value = course.id;
                            await _homeController.getCourseDetails();
                            // Check if course has quiz lessons
                            bool hasQuizzes = _homeController
                                    .courseDetails.value.lessons
                                    ?.any((lesson) =>
                                        lesson.isQuiz == 1 ||
                                        (lesson.quiz != null &&
                                            lesson.quiz!.isNotEmpty)) ??
                                false;
                            if (_homeController.isCourseBought.value) {
                              final MyCourseController myCoursesController =
                                  Get.put(MyCourseController());
                              myCoursesController.courseID.value = course.id;
                              myCoursesController.selectedLessonID.value = 0;
                              myCoursesController.myCourseDetailsTabController
                                  .controller?.index = 0;
                              await myCoursesController.getCourseDetails();
                              Get.to(() => MyCourseDetailsView());
                              context.loaderOverlay.hide();
                            } else {
                              Get.delete<HomeController>(force: true);
                              Get.to(() => CourseDetailsPage(),
                                  arguments: {'courseId': course.id});
                              context.loaderOverlay.hide();
                            }
                          },
                        );
                      },
                    );
                  }
                }),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
