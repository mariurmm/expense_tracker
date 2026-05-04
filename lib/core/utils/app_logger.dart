import 'package:flutter/foundation.dart';
import 'package:logger/logger.dart';

final appLogger = Logger(
  level: kReleaseMode ? Level.warning : Level.trace,
  printer: kReleaseMode ? SimplePrinter() : PrettyPrinter(),
);
