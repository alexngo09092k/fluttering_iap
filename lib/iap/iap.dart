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

  Future<void> restore();
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
    List<IAPProduct> list = [];
    for (var items in _products.values) {
      list.addAll(items);
    }
    return list;
  }

  @override
  IAPConfig get config => _config;

  @override
  void initial(IAPConfig config) async {
    _config = config;

    if (!config.enable) return;

    _iaps.clear();
    for (var provider in _config.providers) {
      BaseIAP? iap;
      if (!_iaps.containsKey(provider)) {
        if (provider == IAPProvider.google) {
          iap = GoogleIAP(_config.products.where((element) => element.provider == provider).toList());
        } else if (provider == IAPProvider.huawei) {
          iap = HuaweiIAP(_config.products.where((element) => element.provider == provider).toList());
        }
      }
      if (iap != null) {
        final done = await iap.initial();
        if (done) {
          iap.listen(
            (products) {
              _products[provider] = products;
              notifyListeners();
            },
            (error) => Debug.log(error.toString()),
          );
          _iaps[provider] = iap;
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
      rethrow;
    }
  }

  @override
  Future<void> restore() async {
    for (final entry in _iaps.entries) {
      if (!entry.value.isSupported) continue;
      try {
        await entry.value.restore();
      } catch (e) {
        Debug.log('AwesomeIAP restore ${entry.key}: $e');
      }
    }
    notifyListeners();
  }
}
