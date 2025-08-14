// Package imports:
import 'package:get/get.dart';

// Project imports:
import 'package:untitled2/Controller/account_controller.dart';
import 'package:untitled2/Controller/account_page_controller.dart';
import 'package:untitled2/Controller/cart_controller.dart';
import 'package:untitled2/Controller/dashboard_controller.dart';
import 'package:untitled2/Controller/home_controller.dart';
import 'package:untitled2/Controller/quiz_controller.dart';
import 'package:untitled2/Service/language_service.dart';

class DashboardBinding extends Bindings {
  @override
  void dependencies() {
    // Initialize language service as a service
    Get.put<LanguageService>(LanguageService(), permanent: true);
    // SiteController is already initialized in main()
    Get.put<DashboardController>(DashboardController(), permanent: true);
    Get.lazyPut<HomeController>(() => HomeController());
    Get.lazyPut<AccountController>(() => AccountController());
    Get.lazyPut<AccountPageController>(() => AccountPageController());
    Get.lazyPut<CartController>(() => CartController());
    Get.lazyPut<QuizController>(() => QuizController()); // Add QuizController
  }
}
