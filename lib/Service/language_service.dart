import 'dart:convert';
import 'dart:ui';

import 'package:flutter/services.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:untitled2/Config/app_config.dart';
import 'package:untitled2/Controller/dashboard_controller.dart';
import 'package:http/http.dart' as http;
import 'package:untitled2/Model/Settings/Languages.dart';
import '../Model/Settings/LanguageData.dart';

class LanguageService extends GetxService {
  GetStorage userToken = GetStorage();
  String tokenKey = "token";

  var appLocale = 'en'.obs;

  // Language state variables
  RxString code = "".obs;
  RxBool isLanguageLoading = false.obs;
  final lang = RxMap();
  final rtl = RxBool(false);
  Rx<Language> selectedLanguage = Language().obs;
  RxList<Language> languages = <Language>[].obs;

  // Local language data
  Map<String, dynamic> _localTranslations = {};
  bool _useLocalTranslations = false;

  // Supported local languages
  static const Map<String, String> supportedLanguages = {
    'en': 'English',
    'ar': 'العربية',
  };

  @override
  void onInit() {
    super.onInit();
    // _initializeLanguages();
  }

  Future<LanguageService> init() async {
    // Set default values immediately to prevent UI issues
    code.value = 'en';
    rtl.value = false;
    appLocale.value = 'en';

    // Create default language options
    languages.value = [
      Language(
        id: 1,
        code: 'en',
        name: 'English',
        native: 'English',
        rtl: 0,
      ),
      Language(
        id: 2,
        code: 'ar',
        name: 'Arabic',
        native: 'العربية',
        rtl: 1,
      ),
    ];

    // Load saved language preference
    await loadSavedLanguage();
    return this;
  }

  String get fallbackLocale => 'en';

  Locale get getLocale {
    if (userToken.read('language_code') != null) {
      return Locale(userToken.read('language_code'));
    } else {
      return Locale('en');
    }
  }

  Future<void> loadSavedLanguage() async {
    try {
      // Always ensure we have a default state first
      if (code.value.isEmpty) {
        code.value = 'en';
        rtl.value = false;
        appLocale.value = 'en';
      }

      final savedLanguage = userToken.read('selected_language_code');
      if (savedLanguage != null && savedLanguage.isNotEmpty) {
        print('Loading saved language: $savedLanguage');
        await setLanguage(langCode: savedLanguage);
      } else {
        print('No saved language found, defaulting to English');
        // Default to English with explicit settings
        await _loadLocalLanguage('en');
        await userToken.write('selected_language_code', 'en');
        await userToken.write('language_code', 'en');
        appLocale.value = 'en';
      }
    } catch (e) {
      print('Error loading saved language: $e');
      // Robust fallback to English
      code.value = 'en';
      rtl.value = false;
      appLocale.value = 'en';
      await _loadLocalLanguage('en');
      await userToken.write('selected_language_code', 'en');
      await userToken.write('language_code', 'en');
    }
  }

  Future<void> setLanguage({String? langCode}) async {
    if (langCode == null) return;

    try {
      isLanguageLoading(true);

      // Update selected language
      final language =
          languages.firstWhereOrNull((lang) => lang.code == langCode);
      if (language != null) {
        selectedLanguage.value = language;
      }

      // Check if it's a supported local language
      if (supportedLanguages.containsKey(langCode)) {
        await _loadLocalLanguage(langCode);
      } else {
        // Try to load from API
        await _loadFromAPI(langCode);
      }

      // Save language preference
      await userToken.write('selected_language_code', langCode);

      // Update locale
      Get.updateLocale(Locale(langCode));

      appLocale.value = langCode;
      userToken.write('language_code', langCode);

      isLanguageLoading(false);
    } catch (e) {
      print('Error setting language: $e');
      isLanguageLoading(false);
      // Fallback to English
      await _loadLocalLanguage('en');
    }
  }

  Future<void> _loadLocalLanguage(String langCode) async {
    try {
      print('Loading local language: $langCode');
      _useLocalTranslations = true;

      // Load local JSON file
      final jsonString =
          await rootBundle.loadString('lib/language/$langCode.json');
      _localTranslations = json.decode(jsonString);

      // Update language data
      code.value = langCode;
      lang.value = _localTranslations;

      // Set RTL for Arabic, LTR for others
      rtl.value = langCode == 'ar';
      appLocale.value = langCode;

      print('Language loaded successfully: $langCode, RTL: ${rtl.value}');
    } catch (e) {
      print('Error loading local language $langCode: $e');

      // Only fallback to English if we're not already trying to load English
      if (langCode != 'en') {
        print('Falling back to English');
        await _loadLocalLanguage('en');
      } else {
        // If English fails, set minimal defaults
        print('English loading failed, setting minimal defaults');
        code.value = 'en';
        rtl.value = false;
        appLocale.value = 'en';
        lang.value = {
          'Home': 'Home',
          'Account': 'Account',
          'Settings': 'Settings',
          'Language': 'Language',
        };
      }
    }
  }

  Future<void> _loadFromAPI(String langCode) async {
    try {
      _useLocalTranslations = false;

      final dashboardController = Get.find<DashboardController>();
      dashboardController.isLoading(true);

      var token = userToken.read(tokenKey);
      String url = "$baseUrl/get-lang?code=$langCode";

      var response = await http.get(
        Uri.parse(url),
        headers: header(token: token),
      );

      if (response.statusCode == 200) {
        var jsonString = jsonDecode(response.body);
        var courseData = jsonEncode(jsonString['data']);
        final data = LanguageData.fromJson(json.decode(courseData));

        code.value = data.code ?? '';
        lang.value = data.lang ?? Map();

        rtl.value = data.rtl == "1";

        dashboardController.isLoading(false);
      } else {
        dashboardController.isLoading(false);
        // Fallback to local English
        await _loadLocalLanguage('en');
      }
    } catch (e) {
      print('Error loading from API: $e');
      // Fallback to local English
      await _loadLocalLanguage('en');
    }
  }

  Future<LanguageList?> getAllLanguages() async {
    try {
      // Return local languages for now
      return LanguageList(languages: languages);
    } catch (e) {
      print('Error getting languages: $e');
      return null;
    }
  }

  // Get translation with fallback
  String getTranslation(String key) {
    if (_useLocalTranslations && _localTranslations.containsKey(key)) {
      return _localTranslations[key] ?? key;
    } else if (lang.containsKey(key)) {
      return lang[key] ?? key;
    }
    return key;
  }

  // Check if current language is RTL
  bool get isRTL => rtl.value;

  // Get current language code
  String get currentLanguageCode => code.value;

  // Get current language name
  String get currentLanguageName {
    final language =
        languages.firstWhereOrNull((lang) => lang.code == code.value);
    return language?.native ?? 'English';
  }

  Map<String, String> get en =>
      lang.value.map((key, value) => MapEntry(key, value.toString()));
  Map<String, String> get ar =>
      lang.value.map((key, value) => MapEntry(key, value.toString()));
}
