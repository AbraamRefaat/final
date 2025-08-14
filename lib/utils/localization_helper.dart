class LocalizationHelper {
  /// Extracts localized text from API response objects
  /// Handles both string and Map<String, dynamic> types
  /// Prefers current language, falls back to 'en', then 'ar', then any available value
  static String? extractLocalizedText(dynamic value,
      [String currentLang = 'en']) {
    if (value == null) return null;

    // If it's already a string, return it
    if (value is String) return value;

    // If it's a Map (localized object), extract the appropriate language
    if (value is Map<String, dynamic>) {
      // Try current language first
      if (value[currentLang] != null &&
          value[currentLang].toString().isNotEmpty) {
        return value[currentLang].toString();
      }

      // Fall back to English
      if (value['en'] != null && value['en'].toString().isNotEmpty) {
        return value['en'].toString();
      }

      // Fall back to Arabic
      if (value['ar'] != null && value['ar'].toString().isNotEmpty) {
        return value['ar'].toString();
      }

      // Fall back to any available value
      for (String key in value.keys) {
        if (value[key] != null && value[key].toString().isNotEmpty) {
          return value[key].toString();
        }
      }
    }

    return null;
  }
}
