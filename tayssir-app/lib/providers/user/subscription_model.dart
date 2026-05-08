import 'dart:convert';
import 'dart:ui';
import 'package:equatable/equatable.dart';
import 'package:tayssir/utils/extensions/strings.dart';

class SubscriptionModel extends Equatable {
  final int id;
  final String name;
  final String description;
  final int price;
  final DateTime? endingDate;
  final Color gradiantStart;
  final Color gradiantEnd;
  final Color innterColor;
  //discounts
  final List<DiscountModel> discounts;
  const SubscriptionModel({
    required this.id,
    required this.name,
    required this.description,
    required this.price,
    required this.endingDate,
    this.gradiantStart = const Color(0XFF175DC7),
    this.gradiantEnd = const Color(0XFF00C4F6),
    this.innterColor = const Color(0XFF175DC7),
    this.discounts = const [],
  });

  List<Color> get gradientColors => [gradiantStart, gradiantEnd];

  int get realPrice {
    if (discounts.isEmpty) {
      return price;
    } else {
      final discount = discounts.first;
      final discountedPrice =
          price - (price * discount.percentage / 100).round();
      return discountedPrice;
    }
  }

  int get fullPrice => price;
  double get percentage =>
      discounts.isNotEmpty ? discounts.first.percentage : 0;

  SubscriptionModel copyWith({
    int? id,
    String? name,
    String? description,
    DateTime? endingDate,
    int? price,
    List<Color>? gradientColors,
    Color? innterColor,
    List<DiscountModel>? discounts,
  }) {
    return SubscriptionModel(
      id: id ?? this.id,
      name: name ?? this.name,
      price: price ?? this.price,
      description: description ?? this.description,
      endingDate: endingDate ?? this.endingDate,
      gradiantStart: gradientColors?[0] ?? gradiantStart,
      gradiantEnd: gradientColors?[1] ?? gradiantEnd,
      innterColor: innterColor ?? this.innterColor,
      discounts: discounts ?? this.discounts,
    );
  }

  factory SubscriptionModel.fromMap(Map<String, dynamic> map) {
    return SubscriptionModel(
      id: (map['id'] as int?) ?? 0,
      name: (map['name'] as String?) ?? '',
      description: (map['description'] as String?) ?? ' ',
      price: map['price'] == null 
          ? 0 
          : map['price'] is int
              ? map['price'] as int
              : int.tryParse(map['price'].toString()) ?? 0,
      endingDate: map['ending_date'] == null
          ? null
          : DateTime.tryParse(map['ending_date'].toString()),
      gradiantStart: map['gradiant_start'] != null
          ? Color((map['gradiant_start'] as String).toHexColor)
          : const Color(0XFF175DC7),
      gradiantEnd: map['gradiant_end'] != null
          ? Color((map['gradiant_end'] as String).toHexColor)
          : const Color(0XFF00C4F6),
      innterColor: map['bottom_color_at_start'] == 1
          ? (map['gradiant_start'] != null
              ? Color((map['gradiant_start'] as String).toHexColor)
              : const Color(0XFF175DC7))
          : (map['gradiant_end'] != null
              ? Color((map['gradiant_end'] as String).toHexColor)
              : const Color(0XFF00C4F6)),
      discounts: map['discounts'] != null
          ? List<DiscountModel>.from((map['discounts'] as List<dynamic>)
              .map((e) => DiscountModel.fromMap(e as Map<String, dynamic>)))
          : [],
    );
  }

  factory SubscriptionModel.fromJson(String source) =>
      SubscriptionModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  bool get stringify => true;

  @override
  List<Object> get props => [
        id,
        name,
        description,
        price,
        innterColor,
        gradiantStart,
        gradiantEnd,
        discounts
      ];
}

class DiscountModel extends Equatable {
  final int id;
  final String name;
  final String? description;
  final int amount;
  final double percentage;
  final DateTime? from;
  final DateTime? to;

  const DiscountModel({
    required this.id,
    required this.name,
    this.description,
    required this.amount,
    required this.percentage,
    required this.from,
    required this.to,
  });

  factory DiscountModel.fromMap(Map<String, dynamic> map) {
    return DiscountModel(
      id: (map['id'] as int?) ?? 0,
      name: (map['name'] as String?) ?? '',
      description: map['description'] as String?,
      amount: (map['amount'] as int?) ?? 0,
      percentage: (map['percentage'] as num?)?.toDouble() ?? 0.0,
      from: map['from'] == null ? null : DateTime.tryParse(map['from'].toString()),
      to: map['to'] == null ? null : DateTime.tryParse(map['to'].toString()),
    );
  }

  factory DiscountModel.fromJson(String source) =>
      DiscountModel.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  List<Object?> get props =>
      [id, name, description, amount, percentage, from, to];
}
