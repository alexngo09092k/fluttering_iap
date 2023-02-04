import 'package:fluttering/fluttering.dart';
import 'package:fluttering_iap/iap/base_iap.dart';
import 'package:fluttering_iap/iap/google/google_iap.dart';
import 'package:fluttering_iap/iap/huawei/huawei_iap.dart';
import 'package:fluttering_iap/iap/models/iap_config.dart';
import 'package:fluttering_iap/iap/models/iap_product.dart';
import 'package:fluttering_iap/iap/models/iap_provider.dart';

abstract class IAwesomeIAP extends Provider with ProviderDelegate {
  IAPConfig get config;

  IAPProvider get provider => config.provider;

  List<IAPProduct> get products;

  void initial(IAPConfig config);

  Future<void> purchase(IAPProduct product);
}

class AwesomeIAP extends IAwesomeIAP {
  static final IAwesomeIAP _instance = AwesomeIAP._internal();
  static IAwesomeIAP get instance => _instance;

  factory AwesomeIAP() => _instance as AwesomeIAP;

  AwesomeIAP._internal();

  IAPConfig _config = const IAPConfig();

  BaseIAP? _iap;

  List<IAPProduct> _products = [];
  @override
  List<IAPProduct> get products => _products;

  @override
  IAPConfig get config => _config;

  @override
  void initial(IAPConfig config) {
    _config = config;

    /// CHECK ENABLED
    if(!config.enable) return;

    /// CREATE INSTANCE IAP
    if (_config.provider == IAPProvider.google) {
      _iap = GoogleIAP(config.products.where((e) => e.provider == IAPProvider.google).toList());
    } else if (_config.provider == IAPProvider.huawei) {
      _iap = HuaweiIAP(config.products.where((e) => e.provider == IAPProvider.huawei).toList());
    }

    _iap?.listen((products) {
      _products = products;
      if (_products != products) notifyListeners();
    }, (error) => Debug.log(error.toString()));
  }

  @override
  Future<void> purchase(IAPProduct product) async {
    try {
      if (_iap != null && _iap!.isSupported) {
        return _iap!.purchase(product);
      }
    } catch (error) {
      Debug.log(error);
    }
  }
}
