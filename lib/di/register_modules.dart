import 'package:injectable/injectable.dart';
import 'package:logger/logger.dart';

import '../core/utils/app_logger.dart';

@module
abstract class RegisterModule {
  @lazySingleton
  Logger get logger => appLogger;
}
