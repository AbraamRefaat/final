import 'package:get/get.dart';
import 'package:untitled2/Service/language_service.dart';

class TranslationHelper {
  static String tr(String key) {
    try {
      final languageService = Get.find<LanguageService>();
      return languageService.getTranslation(key);
    } catch (e) {
      // Fallback to key if service is not available
      return key;
    }
  }

  static bool get isRTL {
    try {
      final languageService = Get.find<LanguageService>();
      return languageService.isRTL;
    } catch (e) {
      return false;
    }
  }

  static String get currentLanguageCode {
    try {
      final languageService = Get.find<LanguageService>();
      return languageService.currentLanguageCode;
    } catch (e) {
      return 'en';
    }
  }

  static String get currentLanguageName {
    try {
      final languageService = Get.find<LanguageService>();
      return languageService.currentLanguageName;
    } catch (e) {
      return 'English';
    }
  }
}
