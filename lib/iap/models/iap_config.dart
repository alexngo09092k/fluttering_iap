// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/foundation.dart';

import 'package:fluttering_iap/iap/models/iap_product.dart';
import 'package:fluttering_iap/iap/models/iap_provider.dart';

class IAPConfig {
  final List<IAPProduct> products;
  final List<IAPProvider> providers;
  final bool enable;

  const IAPConfig({
    this.products = const [],
    this.providers = const [],
    this.enable = true,
  });

  IAPConfig copyWith({
    List<IAPProduct>? products,
    List<IAPProvider>? providers,
    bool? enable,
  }) {
    return IAPConfig(
      products: products ?? this.products,
      providers: providers ?? this.providers,
      enable: enable ?? this.enable,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'products': products.map((x) => x.toMap()).toList(),
      'providers': providers.map((x) => x.name),
      'enable': enable,
    };
  }

  factory IAPConfig.fromMap(Map<String, dynamic> map) {
    return IAPConfig(
      products: (map['products']?? []).map<IAPProduct>((x) => IAPProduct.fromMap(x)).toList(),
      providers: (map['providers'] ?? []).map<IAPProvider>((x) => IAPProvider.values.firstWhere((e) => e.name == x)).toList(),
      enable: map['enable'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory IAPConfig.fromJson(String source) => IAPConfig.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'IAPConfig(products: $products, providers: $providers, enable: $enable)';

  @override
  bool operator ==(covariant IAPConfig other) {
    if (identical(this, other)) return true;

    return listEquals(other.products, products) && listEquals(other.providers, providers) && other.enable == enable;
  }

  @override
  int get hashCode => products.hashCode ^ providers.hashCode ^ enable.hashCode;
}
