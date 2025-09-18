import 'package:logger/logger.dart';

import 'app/data/app_constants.dart';

class AppLogger {
  static final Logger _logger = Logger();

  static void info(String message) {
    if (!AppConstants.showInfoLogs) return;
    _logger.i(message);
  }

  static void warning(
    String message,
    String name, {
    Map<String, Object>? params,
  }) {
    if (!AppConstants.showWarningLogs) return;
    _logger.w(message);
  }

  static void error({
    required Object error,
    required StackTrace stack,
    String reason = 'An unnamed error occurred.',
  }) {
    if (!AppConstants.showErrorLogs) return;
    _logger.e(reason, error: error, stackTrace: stack);
  }
}
