import 'package:hive/hive.dart';

part 'category_model.g.dart';

@HiveType(typeId: 2)
class Category extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  /// IconData.codePoint — reconstruct with IconData(icon, fontFamily: 'MaterialIcons')
  @HiveField(2)
  final int icon;

  /// Color.value — reconstruct with Color(color)
  @HiveField(3)
  final int color;

  @HiveField(4)
  final bool isCustom;

  Category({
    required this.id,
    required this.name,
    required this.icon,
    required this.color,
    required this.isCustom,
  });
}
