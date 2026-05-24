# Где Деньги? — Учёт личных финансов

Мобильное приложение на Flutter для учёта доходов и расходов. Работает офлайн, данные хранятся локально через Hive.

**Стек:** Flutter · Dart · Provider · Hive · fl_chart · GoRouter

**Экраны:** Главная (баланс) · Транзакции · Отчёты (графики) · Настройки

---

## Запуск

**Требования:** Flutter SDK 3.41.6 (через FVM), Dart >=3.0.0, Android Studio или VS Code с плагином Flutter

```bash
git clone https://github.com/mariurmm/expense_tracker.git
cd expense_tracker

# Установить версию Flutter через FVM
fvm install
fvm flutter pub get

# Генерация Hive-адаптеров (если отсутствуют .g.dart файлы)
fvm dart run build_runner build --delete-conflicting-outputs

# Запуск
fvm flutter run
```

> Без FVM заменить `fvm flutter` → `flutter` и `fvm dart` → `dart`

**Полезные команды:**
```bash
# Проверить подключённые устройства
flutter devices

# Запуск на конкретном устройстве
flutter run -d <device_id>

# Горячая перезагрузка (в терминале с запущенным flutter run)
r   # hot reload
R   # hot restart

# Очистить сборку
flutter clean

# Сборка релизного APK
flutter build apk --release

# Сборка App Bundle (для Google Play)
flutter build appbundle --release
```