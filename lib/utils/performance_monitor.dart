import 'dart:async';
import 'dart:developer' as developer;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:get_storage/get_storage.dart';

class PerformanceMonitor {
  static final GetStorage _storage = GetStorage('performance_data');
  static final Map<String, Stopwatch> _timers = {};
  static final Map<String, List<double>> _metrics = {};

  // Performance thresholds
  static const double _slowOperationThreshold = 1000.0; // 1 second
  static const double _verySlowOperationThreshold = 3000.0; // 3 seconds

  /// Start timing an operation
  static void startTimer(String operationName) {
    _timers[operationName] = Stopwatch()..start();
  }

  /// End timing an operation and log the result
  static void endTimer(String operationName) {
    final timer = _timers[operationName];
    if (timer != null) {
      timer.stop();
      final duration = timer.elapsedMilliseconds.toDouble();

      // Log performance data
      _logPerformance(operationName, duration);

      // Store metric for analysis
      _storeMetric(operationName, duration);

      // Clear timer
      _timers.remove(operationName);
    }
  }

  /// Log performance data with appropriate level
  static void _logPerformance(String operationName, double duration) {
    if (duration > _verySlowOperationThreshold) {
      developer.log(
        '🚨 VERY SLOW: $operationName took ${duration}ms',
        name: 'PerformanceMonitor',
        level: 900, // Error level
      );
    } else if (duration > _slowOperationThreshold) {
      developer.log(
        '⚠️ SLOW: $operationName took ${duration}ms',
        name: 'PerformanceMonitor',
        level: 800, // Warning level
      );
    } else {
      developer.log(
        '✅ GOOD: $operationName took ${duration}ms',
        name: 'PerformanceMonitor',
        level: 500, // Info level
      );
    }
  }

  /// Store metric for analysis
  static void _storeMetric(String operationName, double duration) {
    if (!_metrics.containsKey(operationName)) {
      _metrics[operationName] = [];
    }
    _metrics[operationName]!.add(duration);

    // Keep only last 100 measurements
    if (_metrics[operationName]!.length > 100) {
      _metrics[operationName]!.removeAt(0);
    }
  }

  /// Get performance statistics for an operation
  static Map<String, dynamic> getOperationStats(String operationName) {
    final measurements = _metrics[operationName] ?? [];
    if (measurements.isEmpty) {
      return {
        'count': 0,
        'average': 0.0,
        'min': 0.0,
        'max': 0.0,
        'median': 0.0,
      };
    }

    measurements.sort();
    final count = measurements.length;
    final average = measurements.reduce((a, b) => a + b) / count;
    final min = measurements.first;
    final max = measurements.last;
    final median = measurements[count ~/ 2];

    return {
      'count': count,
      'average': average,
      'min': min,
      'max': max,
      'median': median,
    };
  }

  /// Get all performance statistics
  static Map<String, Map<String, dynamic>> getAllStats() {
    final stats = <String, Map<String, dynamic>>{};
    for (final operation in _metrics.keys) {
      stats[operation] = getOperationStats(operation);
    }
    return stats;
  }

  /// Clear all performance data
  static void clearAllData() {
    _metrics.clear();
    _timers.clear();
    _storage.erase();
  }

  /// Save performance data to persistent storage
  static Future<void> savePerformanceData() async {
    await _storage.write('performance_metrics', _metrics);
  }

  /// Load performance data from persistent storage
  static Future<void> loadPerformanceData() async {
    final data = _storage.read('performance_metrics');
    if (data != null) {
      _metrics.clear();
      _metrics.addAll(Map<String, List<double>>.from(data));
    }
  }

  /// Monitor widget build performance
  static Widget monitorWidget(String widgetName, Widget Function() builder) {
    return PerformanceWidget(
      name: widgetName,
      builder: builder,
    );
  }

  /// Monitor async operation performance
  static Future<T> monitorAsync<T>(
      String operationName, Future<T> Function() operation) async {
    startTimer(operationName);
    try {
      final result = await operation();
      return result;
    } finally {
      endTimer(operationName);
    }
  }

  /// Get performance report
  static Map<String, dynamic> getPerformanceReport() {
    final stats = getAllStats();
    final report = <String, dynamic>{
      'timestamp': DateTime.now().toIso8601String(),
      'operations': stats,
      'summary': _generateSummary(stats),
    };
    return report;
  }

  /// Generate performance summary
  static Map<String, dynamic> _generateSummary(
      Map<String, Map<String, dynamic>> stats) {
    int totalOperations = 0;
    double totalTime = 0.0;
    int slowOperations = 0;
    int verySlowOperations = 0;

    for (final operation in stats.values) {
      final count = operation['count'] as int;
      final average = operation['average'] as double;

      totalOperations += count;
      totalTime += average * count;

      if (average > _verySlowOperationThreshold) {
        verySlowOperations += count;
      } else if (average > _slowOperationThreshold) {
        slowOperations += count;
      }
    }

    return {
      'totalOperations': totalOperations,
      'totalTime': totalTime,
      'slowOperations': slowOperations,
      'verySlowOperations': verySlowOperations,
      'averageOperationTime':
          totalOperations > 0 ? totalTime / totalOperations : 0.0,
    };
  }
}

/// Widget wrapper for performance monitoring
class PerformanceWidget extends StatefulWidget {
  final String name;
  final Widget Function() builder;

  const PerformanceWidget({
    Key? key,
    required this.name,
    required this.builder,
  }) : super(key: key);

  @override
  State<PerformanceWidget> createState() => _PerformanceWidgetState();
}

class _PerformanceWidgetState extends State<PerformanceWidget> {
  @override
  Widget build(BuildContext context) {
    PerformanceMonitor.startTimer('widget_build_${widget.name}');

    final builtWidget = widget.builder();

    // Use post-frame callback to end timer after build
    WidgetsBinding.instance.addPostFrameCallback((_) {
      PerformanceMonitor.endTimer('widget_build_${widget.name}');
    });

    return builtWidget;
  }
}

/// Extension for easy performance monitoring
extension PerformanceMonitorExtension on Future {
  Future<T> monitor<T>(String operationName) async {
    return await PerformanceMonitor.monitorAsync(
        operationName, () => this as Future<T>);
  }
}
