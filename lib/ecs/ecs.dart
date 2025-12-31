@MappableLib(generateInitializerForScope: InitializerScope.package, discriminatorKey: "__type")

library;

import 'package:dart_mappable/dart_mappable.dart';

extension HumanReadableDuration on Duration {
  String toHumanReadableString() {
    final micros = inMicroseconds;

    if (micros < 1000) {
      // < 1ms: show in microseconds (e.g., "123µs", "45.6µs", "1.23µs")
      if (micros >= 100) return '$microsµs';
      if (micros >= 10) return '${micros.toStringAsFixed(1)}µs';
      return '${micros.toStringAsFixed(2)}µs';
    } else if (micros < 1000000) {
      // < 1s: show in milliseconds (e.g., "123ms", "45.6ms", "1.23ms")
      final ms = micros / 1000;
      if (ms >= 100) return '${ms.toStringAsFixed(0)}ms';
      if (ms >= 10) return '${ms.toStringAsFixed(1)}ms';
      return '${ms.toStringAsFixed(2)}ms';
    } else {
      // >= 1s: show in seconds (e.g., "12.3s", "1.23s")
      final s = micros / 1000000;
      if (s >= 100) return '${s.toStringAsFixed(1)}s';
      if (s >= 10) return '${s.toStringAsFixed(2)}s';
      return '${s.toStringAsFixed(3)}s';
    }
  }
}