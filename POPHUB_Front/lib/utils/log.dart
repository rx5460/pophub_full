import 'dart:developer' as developer;

enum LogLevel { debug, info, warning, error }

class Logger {
  static LogLevel logLevel = LogLevel.debug; // 설정된 로그 레벨

  static void log(String message, {LogLevel level = LogLevel.debug}) {
    if (level.index >= logLevel.index) {
      String prefix;
      switch (level) {
        case LogLevel.debug:
          prefix = '[DEBUG]';
          break;
        case LogLevel.info:
          prefix = '[INFO]';
          break;
        case LogLevel.warning:
          prefix = '[WARNING]';
          break;
        case LogLevel.error:
          prefix = '[ERROR]';
          break;
      }
      developer.log('$prefix $message', name: 'MyApp');
    }
  }

  static void setLogLevel(LogLevel level) {
    logLevel = level;
  }

  static void debug(String message) {
    log(message, level: LogLevel.debug);
  }

  static void info(String message) {
    log(message, level: LogLevel.info);
  }

  static void warning(String message) {
    log(message, level: LogLevel.warning);
  }

  static void error(String message) {
    log(message, level: LogLevel.error);
  }
}
