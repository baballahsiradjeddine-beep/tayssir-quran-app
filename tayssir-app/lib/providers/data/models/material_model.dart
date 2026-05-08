import 'dart:ui';
import 'package:equatable/equatable.dart';
import 'package:tayssir/environment_config.dart';

//TODO:CAN make material chapter and material all  inherit from a parent class
class MaterialModel extends Equatable {
  final int id;
  final String title;
  final String gradiantColorStart;
  final String gradiantColorEnd;
  final String imageList;
  final String imageGrid;
  final bool isActive;
  final String? description;
  final double progress;
  final TextDirection direction;
  final String type;
  const MaterialModel({
    required this.id,
    required this.title,
    required this.gradiantColorStart,
    required this.gradiantColorEnd,
    required this.imageList,
    required this.imageGrid,
    required this.isActive,
    required this.progress,
    required this.direction,
    required this.type,
    this.description,
  });

  MaterialModel copyWith({
    int? id,
    String? title,
    String? gradiantColorStart,
    String? gradiantColorEnd,
    bool? isActive,
    String? description,
    double? progress,
    String? type,
  }) {
    return MaterialModel(
      id: id ?? this.id,
      title: title ?? this.title,
      gradiantColorStart: gradiantColorStart ?? this.gradiantColorStart,
      gradiantColorEnd: gradiantColorEnd ?? this.gradiantColorEnd,
      imageList: imageList,
      imageGrid: imageGrid,
      isActive: isActive ?? this.isActive,
      description: description ?? this.description,
      progress: progress ?? this.progress,
      direction: direction,
      type: type ?? this.type,
    );
  }

  MaterialModel setProgress(double progress) {
    return copyWith(progress: progress);
  }

  factory MaterialModel.fromMap(Map<String, dynamic> map) {
    return MaterialModel(
      id: map['id'] as int,
      title: map['name'] as String,
      gradiantColorStart: map['color'] as String? ?? '#2196F3',
      gradiantColorEnd: map['secondary_color'] as String? ?? '#2196F3',
      imageList: map['image'] == null ? '' : EnvironmentConfig.resolveImageUrl(map['image'] as String),
      imageGrid: map['image_grid'] == null
          ? map['image'] == null
               ? ''
               : EnvironmentConfig.resolveImageUrl(map['image'] as String)
          : EnvironmentConfig.resolveImageUrl(map['image_grid'] as String),
      isActive: map['isActive'] ?? true,
      progress: map['progress'] == null
          ? 0.0
          : map['progress'] is int
              ? (map['progress'] as int).toDouble()
              : map['progress'] as double,
      description:
          map['description'] == null ? '' : map['description'] as String,
      direction:
          map['direction'] == 'RTL' ? TextDirection.rtl : TextDirection.ltr,
      type: map['type'] as String? ?? 'ahkam',
    );
  }

  @override
  List<Object?> get props => [
        id,
        title,
        gradiantColorStart,
        gradiantColorEnd,
        imageList,
        isActive,
        description,
        progress,
        direction,
        imageGrid,
        type,
      ];

  @override
  bool get stringify => true;
}
