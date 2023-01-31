// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class IAPProductInfo {
  final String price;
  final double rawPrice;
  final String name;
  final String description;
  final String currency;

  IAPProductInfo({
    required this.price,
    required this.name,
    required this.description,
    required this.rawPrice,
    required this.currency,
  });

  IAPProductInfo copyWith({
    String? price,
    String? name,
    String? description,
    double? rawPrice,
    String? currency,
  }) {
    return IAPProductInfo(
      price: price ?? this.price,
      name: name ?? this.name,
      description: description ?? this.description,
      rawPrice: rawPrice ?? this.rawPrice,
      currency: currency ?? this.currency,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'price': price,
      'name': name,
      'description': description,
      'rawPrice': rawPrice,
      'currency': currency,
    };
  }

  factory IAPProductInfo.fromMap(Map<String, dynamic> map) {
    return IAPProductInfo(
      price: map['price'] as String,
      name: map['name'] as String,
      description: map['description'] as String,
      rawPrice: double.parse(map['rawPrice'].toString()),
      currency: map['currency'] as String,
    );
  }

  String toJson() => json.encode(toMap());

  factory IAPProductInfo.fromJson(String source) => IAPProductInfo.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'IAPProductInfo(price: $price, name: $name, description: $description, rawPrice: $rawPrice, currency: $currency)';
  }

  @override
  bool operator ==(covariant IAPProductInfo other) {
    if (identical(this, other)) return true;

    return other.price == price && other.name == name && other.description == description && other.rawPrice == rawPrice && other.currency == currency;
  }

  @override
  int get hashCode {
    return price.hashCode ^ name.hashCode ^ description.hashCode ^ rawPrice.hashCode ^ currency.hashCode;
  }
}
