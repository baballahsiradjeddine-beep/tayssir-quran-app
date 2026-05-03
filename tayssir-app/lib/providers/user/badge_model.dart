import 'package:equatable/equatable.dart';
import 'package:tayssir/environment_config.dart';

class BadgeModel extends Equatable {
  final String name;
  final String? color;
  final String? iconUrl;

  const BadgeModel({
    required this.name,
    this.color,
    this.iconUrl,
  });

  String? get completeIconUrl {
    if (iconUrl == null || iconUrl!.isEmpty) return null;
    return EnvironmentConfig.resolveImageUrl(iconUrl);
  }

  factory BadgeModel.fromMap(Map<String, dynamic> map) {
    return BadgeModel(
      name: map['name'] ?? '',
      color: map['color'],
      iconUrl: map['icon_url'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'color': color,
      'icon_url': iconUrl,
    };
  }

  @override
  List<Object?> get props => [name, color, iconUrl];
}
