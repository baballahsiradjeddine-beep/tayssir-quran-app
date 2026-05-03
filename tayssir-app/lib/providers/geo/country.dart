import 'package:equatable/equatable.dart';
import 'package:tayssir/providers/user/wilaya_dropdown_item.dart';

class Country extends Equatable implements TaysirDropdownItem {
  final int id;
  @override
  final String name;
  final String code;
  final String? phoneCode;

  Country({
    required this.id,
    required this.name,
    required this.code,
    this.phoneCode,
  });

  @override
  int get number => id;

  factory Country.fromJson(Map<String, dynamic> json) {
    return Country(
      id: json['id'],
      name: json['name'],
      code: json['code'],
      phoneCode: json['phone_code'],
    );
  }

  factory Country.fromMap(Map<String, dynamic> map) => Country.fromJson(map);

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'code': code,
      'phone_code': phoneCode,
    };
  }

  Map<String, dynamic> toMap() => toJson();

  @override
  List<Object?> get props => [id, name, code, phoneCode];
}
