// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:fluttering_iap/iap/models/iap_product.dart';
import 'package:fluttering_iap/iap/models/iap_provider.dart';

class IAPConfig {
  final List<IAPProduct> products;
  final IAPProvider provider;
  final bool enable;

  const IAPConfig({
    this.products = const [],
    this.provider = IAPProvider.google,
    this.enable = true,
  });

  IAPConfig copyWith({
    List<IAPProduct>? products,
    IAPProvider? provider,
    bool? enable,
  }) {
    return IAPConfig(
      products: products ?? this.products,
      provider: provider ?? this.provider,
      enable: enable ?? this.enable,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'products': products.map((x) => x.toMap()).toList(),
      'provider': provider.name,
      'enable': enable,
    };
  }

  factory IAPConfig.fromMap(Map<String, dynamic> map) {
    return IAPConfig(
      products: map['products'].map<IAPProduct>((x) => IAPProduct.fromMap(x)).toList(),
      provider: IAPProvider.values.firstWhere((e) => e.name == map['provider']),
      enable: map['enable'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory IAPConfig.fromJson(String source) => IAPConfig.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'IAPConfig(products: $products, provider: $provider, enable: $enable)';

  @override
  bool operator ==(covariant IAPConfig other) {
    if (identical(this, other)) return true;

    return listEquals(other.products, products) && other.provider == provider && other.enable == enable;
  }

  @override
  int get hashCode => products.hashCode ^ provider.hashCode ^ enable.hashCode;
}
