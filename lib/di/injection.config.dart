// GENERATED CODE - DO NOT MODIFY BY HAND
// dart format width=80

// **************************************************************************
// InjectableConfigGenerator
// **************************************************************************

// ignore_for_file: type=lint
// coverage:ignore-file

// ignore_for_file: no_leading_underscores_for_library_prefixes
import 'package:expense_tracker/core/services/export_service.dart' as _i415;
import 'package:expense_tracker/data/datasources/category_local_datasource.dart'
    as _i832;
import 'package:expense_tracker/data/datasources/settings_local_datasource.dart'
    as _i336;
import 'package:expense_tracker/data/datasources/transaction_local_datasource.dart'
    as _i875;
import 'package:expense_tracker/data/repositories/category_repository.dart'
    as _i679;
import 'package:expense_tracker/data/repositories/settings_repository.dart'
    as _i304;
import 'package:expense_tracker/data/repositories/transaction_repository.dart'
    as _i706;
import 'package:expense_tracker/di/register_modules.dart' as _i564;
import 'package:get_it/get_it.dart' as _i174;
import 'package:injectable/injectable.dart' as _i526;
import 'package:logger/logger.dart' as _i974;

extension GetItInjectableX on _i174.GetIt {
  // initializes the registration of main-scope dependencies inside of GetIt
  _i174.GetIt init({
    String? environment,
    _i526.EnvironmentFilter? environmentFilter,
  }) {
    final gh = _i526.GetItHelper(this, environment, environmentFilter);
    final registerModule = _$RegisterModule();
    gh.lazySingleton<_i832.CategoryLocalDatasource>(
      () => _i832.CategoryLocalDatasource(),
    );
    gh.lazySingleton<_i336.SettingsLocalDatasource>(
      () => _i336.SettingsLocalDatasource(),
    );
    gh.lazySingleton<_i875.TransactionLocalDatasource>(
      () => _i875.TransactionLocalDatasource(),
    );
    gh.lazySingleton<_i974.Logger>(() => registerModule.logger);
    gh.lazySingleton<_i706.TransactionRepository>(
      () => _i706.TransactionRepository(
        datasource: gh<_i875.TransactionLocalDatasource>(),
      ),
    );
    gh.lazySingleton<_i304.SettingsRepository>(
      () => _i304.SettingsRepository(
        datasource: gh<_i336.SettingsLocalDatasource>(),
      ),
    );
    gh.lazySingleton<_i679.CategoryRepository>(
      () => _i679.CategoryRepository(
        datasource: gh<_i832.CategoryLocalDatasource>(),
      ),
    );
    gh.lazySingleton<_i415.ExportService>(
      () => _i415.ExportService(gh<_i679.CategoryRepository>()),
    );
    return this;
  }
}

class _$RegisterModule extends _i564.RegisterModule {}
