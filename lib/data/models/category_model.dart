import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:hive_ce/hive.dart';

part 'category_model.freezed.dart';
part 'category_model.g.dart';

@freezed
@HiveType(typeId: 2)
abstract class Category with _$Category {
  const factory Category({
    @HiveField(0) required String id,
    @HiveField(1) required String name,
    /// IconData.codePoint — reconstruct with IconData(icon, fontFamily: 'MaterialIcons')
    @HiveField(2) required int icon,
    /// Color.value — reconstruct with Color(color)
    @HiveField(3) required int color,
    @HiveField(4) required bool isCustom,
  }) = _Category;

  factory Category.fromJson(Map<String, dynamic> json) =>
      _$CategoryFromJson(json);
}
