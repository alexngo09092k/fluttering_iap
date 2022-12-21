import 'package:flutter/material.dart';
import 'package:fluttering/fluttering.dart';
import 'package:fluttering_iap/iap/base_iap.dart';
import 'package:fluttering_iap/iap/google/google_iap.dart';
import 'package:fluttering_iap/iap/huawei/huawei_iap.dart';
import 'package:fluttering_iap/iap/models/iap_config.dart';
import 'package:fluttering_iap/iap/models/iap_item.dart';
import 'package:fluttering_iap/iap/models/iap_provider.dart';

abstract class IAwesomeIAP extends Provider with ProviderDelegate {
  IAPConfig get config;

  IAPProvider get provider => config.provider;

  List<IAPItem> get products;

  void initial(IAPConfig config);

  Future<void> purchase(IAPItem product);
}

class AwesomeIAP extends IAwesomeIAP {
  IAPConfig _config = const IAPConfig();

  late final BaseIAP _iap;

  List<IAPItem> _products = [];
  @override
  List<IAPItem> get products => _products;

  @override
  IAPConfig get config => _config;

  @override
  void initial(IAPConfig config) {
    _config = config;
    if (_config.provider == IAPProvider.google) {
      _iap = GoogleIAP(config.products.where((e) => e.provider == IAPProvider.google).toList());
    } else if (_config.provider == IAPProvider.huawei) {
      _iap = HuaweiIAP(config.products.where((e) => e.provider == IAPProvider.huawei).toList());
    } else {
      throw ErrorDescription('No support InAppPuchase');
    }

    _iap.listen((products) {
      _products = products;
      if (_products != products) notifyListeners();
    }, (error) => Debug.log(error.toString()));
  }

  @override
  Future<void> purchase(IAPItem product) async {
    try {
      if (_iap.isSupported) {
        return _iap.purchase(product);
      } else {
        throw ErrorDescription('No support InAppPuchase');
      }
    } catch (error) {
      Debug.log(error);
    }
  }
}
