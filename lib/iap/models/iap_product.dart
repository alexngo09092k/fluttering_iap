// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:flutter/cupertino.dart';

import 'package:fluttering_iap/iap/models/iap_provider.dart';
import 'package:fluttering_iap/iap/models/iap_type.dart';

class IAPProduct extends ChangeNotifier {
  IAPProduct({
    required this.type,
    required this.provider,
    required this.id,
  });

  final IAPType type;
  final IAPProvider provider;
  final String id;

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
  }) {
    return IAPProduct(
      type: type ?? this.type,
      provider: provider ?? this.provider,
      id: id ?? this.id,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'type': type.name,
      'provider': provider.name,
      'id': id,
    };
  }

  factory IAPProduct.fromMap(Map<String, dynamic> map) {
    return IAPProduct(
      type: IAPType.values.firstWhere((e) => e.name == map['type']),
      provider: IAPProvider.values.firstWhere((e) => e.name == map['provider']),
      id: (map['id'] ?? "").toString(),
    );
  }

  String toJson() => json.encode(toMap());

  factory IAPProduct.fromJson(String source) => IAPProduct.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'IAPProduct(type: $type, provider: $provider, id: $id)';

  @override
  bool operator ==(covariant IAPProduct other) {
    if (identical(this, other)) return true;

    return other.type == type && other.provider == provider && other.id == id;
  }

  @override
  int get hashCode => type.hashCode ^ provider.hashCode ^ id.hashCode;
}
