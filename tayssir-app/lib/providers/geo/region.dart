import 'package:equatable/equatable.dart';
import 'package:tayssir/providers/user/wilaya_dropdown_item.dart';

class Region extends Equatable implements TaysirDropdownItem {
  final int id;
  @override
  final String name;
  final String? code;

  Region({
    required this.id,
    required this.name,
    this.code,
  });

  @override
  int get number => id;

  factory Region.fromJson(Map<String, dynamic> json) {
    return Region(
      id: json['id'],
      name: json['name'],
      code: json['code'],
    );
  }

  factory Region.fromMap(Map<String, dynamic> map) => Region.fromJson(map);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
    };
  }

  Map<String, dynamic> toMap() => toJson();

  @override
  List<Object?> get props => [id, name, code];
}
