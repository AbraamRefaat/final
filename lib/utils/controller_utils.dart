import 'package:get/get.dart';
import 'package:untitled2/Controller/quiz_controller.dart';

/// Utility class for safely managing GetX controllers
class ControllerUtils {
  /// Safely get or create a QuizController instance
  static QuizController getOrCreateQuizController() {
    if (Get.isRegistered<QuizController>()) {
      return Get.find<QuizController>();
    } else {
      return Get.put(QuizController());
    }
  }

  /// Safely get a controller, return null if not found
  static T? getController<T>() {
    if (Get.isRegistered<T>()) {
      return Get.find<T>();
    }
    return null;
  }

  /// Safely get or create any controller
  static T getOrCreateController<T>(T Function() creator) {
    if (Get.isRegistered<T>()) {
      return Get.find<T>();
    } else {
      return Get.put(creator());
    }
  }

  /// Clear all controllers (useful for cleanup)
  static void clearAllControllers() {
    Get.deleteAll();
  }

  /// Clear specific controller
  static void clearController<T>() {
    if (Get.isRegistered<T>()) {
      Get.delete<T>();
    }
  }

  /// Check if controller exists
  static bool hasController<T>() {
    return Get.isRegistered<T>();
  }
}
