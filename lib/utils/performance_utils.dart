import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Performance utilities for optimizing Flutter app performance
class PerformanceUtils {
  static final Map<String, Stopwatch> _timers = {};
  static final Map<String, List<double>> _performanceData = {};

  /// Monitor widget build performance
  static T monitorWidget<T>(String widgetName, T Function() builder) {
    final stopwatch = Stopwatch()..start();
    final result = builder();
    stopwatch.stop();

    _logPerformance(widgetName, stopwatch.elapsedMilliseconds);
    return result;
  }

  /// Monitor async operation performance
  static Future<T> monitorAsync<T>(
      String operationName, Future<T> Function() operation) async {
    final stopwatch = Stopwatch()..start();
    final result = await operation();
    stopwatch.stop();

    _logPerformance(operationName, stopwatch.elapsedMilliseconds);
    return result;
  }

  /// Optimize list rendering with pagination
  static int getOptimizedItemCount(int totalItems, {int maxItems = 20}) {
    return min(totalItems, maxItems);
  }

  /// Check if widget should rebuild
  static bool shouldRebuild(
      String widgetId, dynamic oldValue, dynamic newValue) {
    return oldValue != newValue;
  }

  /// Optimize image cache settings
  static Map<String, int> getOptimizedImageCacheSettings({
    int memCacheWidth = 300,
    int memCacheHeight = 300,
    int maxWidthDiskCache = 300,
    int maxHeightDiskCache = 300,
  }) {
    return {
      'memCacheWidth': memCacheWidth,
      'memCacheHeight': memCacheHeight,
      'maxWidthDiskCache': maxWidthDiskCache,
      'maxHeightDiskCache': maxHeightDiskCache,
    };
  }

  /// Batch multiple futures for parallel execution
  static Future<List<T>> batchFutures<T>(List<Future<T>> futures) {
    return Future.wait(futures);
  }

  /// Debounce function calls
  static Timer? _debounceTimer;
  static void debounce(VoidCallback callback,
      {Duration duration = const Duration(milliseconds: 300)}) {
    _debounceTimer?.cancel();
    _debounceTimer = Timer(duration, callback);
  }

  /// Throttle function calls
  static DateTime? _lastThrottleCall;
  static bool throttle(VoidCallback callback,
      {Duration duration = const Duration(milliseconds: 100)}) {
    final now = DateTime.now();
    if (_lastThrottleCall == null ||
        now.difference(_lastThrottleCall!) >= duration) {
      callback();
      _lastThrottleCall = now;
      return true;
    }
    return false;
  }

  /// Get performance report
  static Map<String, dynamic> getPerformanceReport() {
    final report = <String, dynamic>{};

    _performanceData.forEach((key, values) {
      if (values.isNotEmpty) {
        final avg = values.reduce((a, b) => a + b) / values.length;
        final max = values.reduce((a, b) => a > b ? a : b);
        final min = values.reduce((a, b) => a < b ? a : b);

        report[key] = {
          'average': avg,
          'max': max,
          'min': min,
          'count': values.length,
        };
      }
    });

    return report;
  }

  /// Clear performance data
  static void clearPerformanceData() {
    _performanceData.clear();
    _timers.clear();
  }

  /// Log performance data
  static void _logPerformance(String name, int milliseconds) {
    if (!_performanceData.containsKey(name)) {
      _performanceData[name] = [];
    }
    _performanceData[name]!.add(milliseconds.toDouble());

    // Keep only last 100 measurements
    if (_performanceData[name]!.length > 100) {
      _performanceData[name] =
          _performanceData[name]!.sublist(_performanceData[name]!.length - 100);
    }

    // Log slow operations
    if (milliseconds > 100) {
      print('⚠️ Slow operation: $name took ${milliseconds}ms');
    }
  }

  /// Optimize ListView settings
  static ScrollPhysics getOptimizedScrollPhysics() {
    return const BouncingScrollPhysics();
  }

  /// Get optimized cache extent for ListView
  static double getOptimizedCacheExtent() {
    return 1000.0;
  }

  /// Check if device is low-end
  static bool isLowEndDevice() {
    // Simple heuristic - can be improved with device info
    final memory = WidgetsBinding.instance.window.physicalSize;
    return memory.width * memory.height < 1000000; // Less than 1M pixels
  }

  /// Get optimized settings based on device
  static Map<String, dynamic> getDeviceOptimizedSettings() {
    final isLowEnd = isLowEndDevice();

    return {
      'imageCacheSize': isLowEnd ? 50 : 100,
      'maxConcurrentRequests': isLowEnd ? 2 : 4,
      'listItemLimit': isLowEnd ? 10 : 20,
      'enableAnimations': !isLowEnd,
    };
  }
}

/// Performance-aware widget mixin
mixin PerformanceAwareWidget<T extends StatefulWidget> on State<T> {
  String get performanceId => runtimeType.toString();

  @override
  Widget build(BuildContext context) {
    return PerformanceUtils.monitorWidget(
        performanceId, () => buildOptimized(context));
  }

  Widget buildOptimized(BuildContext context);
}

/// Optimized ListView builder
class OptimizedListView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final ScrollPhysics? physics;
  final EdgeInsetsGeometry? padding;
  final double? cacheExtent;
  final int? maxItems;

  const OptimizedListView({
    Key? key,
    required this.itemCount,
    required this.itemBuilder,
    this.physics,
    this.padding,
    this.cacheExtent,
    this.maxItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final optimizedItemCount = PerformanceUtils.getOptimizedItemCount(itemCount,
        maxItems: maxItems ?? 20);

    return ListView.builder(
      itemCount: optimizedItemCount,
      itemBuilder: itemBuilder,
      physics: physics ?? PerformanceUtils.getOptimizedScrollPhysics(),
      padding: padding,
      cacheExtent: cacheExtent ?? PerformanceUtils.getOptimizedCacheExtent(),
    );
  }
}

/// Optimized GridView builder
class OptimizedGridView extends StatelessWidget {
  final int itemCount;
  final Widget Function(BuildContext, int) itemBuilder;
  final int crossAxisCount;
  final double childAspectRatio;
  final double crossAxisSpacing;
  final double mainAxisSpacing;
  final int? maxItems;

  const OptimizedGridView({
    Key? key,
    required this.itemCount,
    required this.itemBuilder,
    this.crossAxisCount = 2,
    this.childAspectRatio = 1.0,
    this.crossAxisSpacing = 0.0,
    this.mainAxisSpacing = 0.0,
    this.maxItems,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final optimizedItemCount = PerformanceUtils.getOptimizedItemCount(itemCount,
        maxItems: maxItems ?? 20);

    return GridView.builder(
      itemCount: optimizedItemCount,
      itemBuilder: itemBuilder,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        childAspectRatio: childAspectRatio,
        crossAxisSpacing: crossAxisSpacing,
        mainAxisSpacing: mainAxisSpacing,
      ),
      physics: PerformanceUtils.getOptimizedScrollPhysics(),
      cacheExtent: PerformanceUtils.getOptimizedCacheExtent(),
    );
  }
}
