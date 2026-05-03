import 'dart:ui';
import 'package:equatable/equatable.dart';
import 'package:tayssir/environment_config.dart';

// enum of chapter visivility
enum ChapterVisibility { locked, done, current, fresh, premium }

class ChapterModel extends Equatable {
  final int id;
  final String title;
  final int unitId;
  final double progress;
  final String? image;
  final String? description;
  final TextDirection direction;
  final int bonusPoints;
  final String type;
  final List<dynamic>? content;
  final ChapterVisibility visibility;
  const ChapterModel({
    required this.id,
    required this.title,
    required this.unitId,
    required this.progress,
    this.type = 'exercise',
    this.content,
    this.visibility = ChapterVisibility.fresh,
    this.description,
    this.direction = TextDirection.rtl,
    this.image,
    this.bonusPoints = 0,
  });

  bool get isSubmitted => progress >= 50.0;

  ChapterModel copyWith({
    int? id,
    String? title,
    int? unitId,
    double? progress,
    String? image,
    TextDirection? direction,
    String? description,
    int? bonusPoints,
    ChapterVisibility? visibility,
  }) {
    return ChapterModel(
      id: id ?? this.id,
      title: title ?? this.title,
      unitId: unitId ?? this.unitId,
      progress: progress ?? this.progress,
      image: image ?? this.image,
      direction: direction ?? this.direction,
      description: description ?? this.description,
      bonusPoints: bonusPoints ?? this.bonusPoints,
      visibility: visibility ?? this.visibility,
    );
  }

  ChapterModel setProgress(double progress) {
    return copyWith(progress: progress);
  }

  factory ChapterModel.fromMap(Map<String, dynamic> map) {
    return ChapterModel(
      id: map['id'] as int,
      title: map['name'] as String,
      unitId: map['unit_id'] as int,
      progress: map['progress'] == null
          ? 0.0
          : map['progress'] is int
              ? (map['progress'] as int).toDouble()
              : map['progress'] as double,
      image: map['image'] == null ? null : EnvironmentConfig.resolveImageUrl(map['image'] as String),
      direction:
          map['direction'] == 'RTL' ? TextDirection.rtl : TextDirection.ltr,
      bonusPoints: map['bonus_points'] as int,
      description: map['description'] as String?,
      type: map['type'] as String? ?? 'exercise',
      content: map['content'] as List<dynamic>?,
      visibility: ChapterVisibility.values.firstWhere(
        (e) => e.name.toLowerCase() == (map['visibility'] as String?)?.toLowerCase(),
        orElse: () => ChapterVisibility.fresh,
      ),
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        unitId,
        progress,
        image,
        direction,
        description,
        bonusPoints,
        type,
        content,
      ];

  @override
  bool get stringify => true;
}
