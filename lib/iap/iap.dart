import 'package:fluttering/fluttering.dart';
import 'package:fluttering_iap/iap/base_iap.dart';
import 'package:fluttering_iap/iap/google/google_iap.dart';
import 'package:fluttering_iap/iap/huawei/huawei_iap.dart';
import 'package:fluttering_iap/iap/models/iap_config.dart';
import 'package:fluttering_iap/iap/models/iap_product.dart';
import 'package:fluttering_iap/iap/models/iap_provider.dart';

abstract class IAwesomeIAP extends Provider with ProviderDelegate {
  IAPConfig get config;

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

  final Map<IAPProvider, BaseIAP> _iaps = {};

  final Map<IAPProvider, List<IAPProduct>> _products = {};

  @override
  List<IAPProduct> get products {
    List<IAPProduct> _ = [];
    for (var list in _products.values) {
      _.addAll(list);
    }
    return _;
  }

  @override
  IAPConfig get config => _config;

  @override
  void initial(IAPConfig config) async {
    _config = config;

    /// CHECK ENABLED
    if(!config.enable) return;

    /// CREATE INSTANCE IAP
    _iaps.clear();
    for (var provider in _config.providers) {
      if(!_iaps.containsKey(provider)) {
        if(provider == IAPProvider.google) {
          _iaps[provider] = GoogleIAP(products.where((element) => element.provider == provider).toList());
        }else if(provider == IAPProvider.huawei) {
          _iaps[provider] = HuaweiIAP(products.where((element) => element.provider == provider).toList());
        }
        if(_iaps[provider] != null && _iaps[provider]!.isSupported) {
          final bool done = await _iaps[provider]!.initial();
          if(done) {
            _iaps[provider]!.listen((products) {
              _products[provider] = products;
              notifyListeners();
            }, (error) => Debug.log(error.toString()));
           }
        }
      }
    }
  }

  @override
  Future<void> purchase(IAPProduct product) async {
    try {
      if (_iaps[product.provider] != null && _iaps[product.provider]!.isSupported) {
        return _iaps[product.provider]!.purchase(product);
      }
    } catch (error) {
      Debug.log(error);
    }
  }
}
