// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:fluttering_iap/iap/models/iap_product_info.dart';

import 'package:fluttering_iap/iap/models/iap_provider.dart';
import 'package:fluttering_iap/iap/models/iap_type.dart';

class IAPProduct extends ChangeNotifier {
  IAPProduct({
    required this.type,
    required this.provider,
    required this.id,
    this.info,
  });

  final IAPType type;
  final IAPProvider provider;
  final String id;
  final IAPProductInfo? info;

  bool _isPurchased = false;
  bool get status => _isPurchased;
  setPurchased(bool isPurchased) {
    _isPurchased = isPurchased;
    if (_isPurchased != isPurchased) notifyListeners();
  }

  IAPProduct copyWith({
    IAPType? type,
    IAPProvider? provider,
    String? id,
    IAPProductInfo? info,
  }) {
    return IAPProduct(
      type: type ?? this.type,
      provider: provider ?? this.provider,
      id: id ?? this.id,
      info: info ?? this.info,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': type.name,
      'provider': provider.name,
      'id': id,
      'info': info?.toMap(),
    };
  }

  factory IAPProduct.fromMap(Map<String, dynamic> map) {
    return IAPProduct(
      type: IAPType.values.firstWhere((e) => e.name == map['type']),
      provider: IAPProvider.values.firstWhere((e) => e.name == map['provider']),
      id: (map['id'] ?? "").toString(),
      info: map['info'] ? IAPProductInfo.fromMap(map['info']) : null,
    );
  }

  String toJson() => json.encode(toMap());

  factory IAPProduct.fromJson(String source) => IAPProduct.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'IAPProduct(type: $type, provider: $provider, id: $id, info: $info)';

  @override
  bool operator ==(covariant IAPProduct other) {
    if (identical(this, other)) return true;

    return other.type == type && other.provider == provider && other.id == id && other.info == info;
  }

  @override
  int get hashCode => type.hashCode ^ provider.hashCode ^ id.hashCode ^ info.hashCode;
}
