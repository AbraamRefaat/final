// Flutter imports:
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

// Project imports:
import 'package:untitled2/Service/RemoteService.dart';
import 'package:untitled2/Model/CourseReport.dart';

class AccountPageController extends GetxController {
  var isLoading = false.obs;
  var courseReport = Rx<CourseReport?>(null);

  GetStorage userToken = GetStorage();
  String tokenKey = "token";

  @override
  void onInit() {
    super.onInit();
    fetchCourseReport();
  }

  // Fetch course report data
  Future<void> fetchCourseReport() async {
    try {
      isLoading(true);

      String? token = userToken.read(tokenKey);
      if (token == null || token.isEmpty) {
        print('❌ No token found for course report');
        isLoading(false);
        return;
      }

      print('🔄 Fetching course report...');
      var report = await RemoteServices.getCourseReport(token);

      if (report != null) {
        courseReport.value = report;
        print('✅ Course report loaded successfully');
        print('📊 Enrolled courses: ${report.data?.enrolledCoursesCount ?? 0}');
        print('📊 Finished courses: ${report.data?.finishedCoursesCount ?? 0}');
      } else {
        print('❌ Failed to load course report');
        courseReport.value = null;
      }
    } catch (e) {
      print('💥 Error fetching course report: $e');
      courseReport.value = null;
    } finally {
      isLoading(false);
    }
  }

  // Refresh course report data
  Future<void> refreshCourseReport() async {
    await fetchCourseReport();
  }

  // Get enrolled courses count (total number of courses in the array)
  int get enrolledCoursesCount {
    return courseReport.value?.data?.enrolledCoursesCount ?? 0;
  }

  // Get finished courses count (courses with status "Completed" or percentage 100)
  int get finishedCoursesCount {
    return courseReport.value?.data?.finishedCoursesCount ?? 0;
  }

  // Get in progress courses count (courses started but not completed)
  int get inProgressCoursesCount {
    return courseReport.value?.data?.inProgressCoursesCount ?? 0;
  }

  // Get not started courses count
  int get notStartedCoursesCount {
    return courseReport.value?.data?.notStartedCoursesCount ?? 0;
  }
}
