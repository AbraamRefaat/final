import 'dart:convert';
import 'package:get_storage/get_storage.dart';
import 'package:dio/dio.dart';

class CacheManager {
  static final GetStorage _storage = GetStorage('app_cache');
  static const Duration _defaultCacheDuration = Duration(hours: 1);

  // Cache for API responses
  static final Map<String, dynamic> _memoryCache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};

  /// Cache API response with expiration
  static Future<void> cacheApiResponse(String key, dynamic data,
      {Duration? duration}) async {
    final cacheData = {
      'data': data,
      'timestamp': DateTime.now().millisecondsSinceEpoch,
      'expiresAt': DateTime.now()
          .add(duration ?? _defaultCacheDuration)
          .millisecondsSinceEpoch,
    };

    _memoryCache[key] = cacheData;
    await _storage.write(key, jsonEncode(cacheData));
  }

  /// Get cached API response if not expired
  static dynamic getCachedResponse(String key) {
    // Check memory cache first
    if (_memoryCache.containsKey(key)) {
      final cacheData = _memoryCache[key];
      final expiresAt =
          DateTime.fromMillisecondsSinceEpoch(cacheData['expiresAt']);

      if (DateTime.now().isBefore(expiresAt)) {
        return cacheData['data'];
      } else {
        // Remove expired cache
        _memoryCache.remove(key);
        _storage.remove(key);
      }
    }

    // Check persistent storage
    try {
      final cached = _storage.read(key);
      if (cached != null) {
        final cacheData = jsonDecode(cached);
        final expiresAt =
            DateTime.fromMillisecondsSinceEpoch(cacheData['expiresAt']);

        if (DateTime.now().isBefore(expiresAt)) {
          // Load into memory cache
          _memoryCache[key] = cacheData;
          return cacheData['data'];
        } else {
          // Remove expired cache
          _storage.remove(key);
        }
      }
    } catch (e) {
      // Clear corrupted cache
      _storage.remove(key);
    }

    return null;
  }

  /// Clear specific cache entry
  static Future<void> clearCache(String key) async {
    _memoryCache.remove(key);
    await _storage.remove(key);
  }

  /// Clear all cache
  static Future<void> clearAllCache() async {
    _memoryCache.clear();
    await _storage.erase();
  }

  /// Get cache size info
  static Map<String, dynamic> getCacheInfo() {
    return {
      'memoryCacheSize': _memoryCache.length,
      'persistentCacheKeys': _storage.getKeys(),
    };
  }

  /// Cache image URLs for faster loading
  static Future<void> cacheImageUrl(String url, String localPath) async {
    await _storage.write('img_$url', localPath);
  }

  /// Get cached image path
  static String? getCachedImagePath(String url) {
    return _storage.read('img_$url');
  }

  /// Cache course data for offline access
  static Future<void> cacheCourseData(List<dynamic> courses) async {
    await cacheApiResponse('courses_data', courses,
        duration: Duration(hours: 6));
  }

  /// Get cached course data
  static List<dynamic>? getCachedCourseData() {
    return getCachedResponse('courses_data');
  }

  /// Cache user profile data
  static Future<void> cacheUserProfile(Map<String, dynamic> profile) async {
    await cacheApiResponse('user_profile', profile,
        duration: Duration(days: 1));
  }

  /// Get cached user profile
  static Map<String, dynamic>? getCachedUserProfile() {
    return getCachedResponse('user_profile');
  }

  /// Cache quiz data
  static Future<void> cacheQuizData(List<dynamic> quizzes) async {
    await cacheApiResponse('quiz_data', quizzes, duration: Duration(hours: 2));
  }

  /// Get cached quiz data
  static List<dynamic>? getCachedQuizData() {
    return getCachedResponse('quiz_data');
  }
}

/// Dio interceptor for automatic caching
class CacheInterceptor extends Interceptor {
  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    // Skip caching for POST, PUT, DELETE requests
    if (['POST', 'PUT', 'DELETE', 'PATCH'].contains(options.method)) {
      return handler.next(options);
    }

    // Check cache for GET requests
    final cachedResponse =
        CacheManager.getCachedResponse(options.uri.toString());
    if (cachedResponse != null) {
      // Return cached response
      final response = Response(
        data: cachedResponse,
        statusCode: 200,
        requestOptions: options,
      );
      return handler.resolve(response);
    }

    return handler.next(options);
  }

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    // Cache successful GET responses
    if (response.requestOptions.method == 'GET' && response.statusCode == 200) {
      CacheManager.cacheApiResponse(
        response.requestOptions.uri.toString(),
        response.data,
        duration: Duration(minutes: 30),
      );
    }

    return handler.next(response);
  }

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    // Try to return cached data on network errors
    if (err.type == DioExceptionType.connectionError ||
        err.type == DioExceptionType.connectionTimeout) {
      final cachedResponse =
          CacheManager.getCachedResponse(err.requestOptions.uri.toString());
      if (cachedResponse != null) {
        final response = Response(
          data: cachedResponse,
          statusCode: 200,
          requestOptions: err.requestOptions,
        );
        return handler.resolve(response);
      }
    }

    return handler.next(err);
  }
}
