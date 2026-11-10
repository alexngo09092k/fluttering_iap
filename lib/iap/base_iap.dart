import 'package:fluttering_iap/iap/models/iap_product.dart';
import 'package:fluttering_iap/iap/models/iap_provider.dart';

abstract class BaseIAP {
  IAPProvider get provider;

  bool get isSupported;

  Future<void> purchase(IAPProduct product);

  Future<bool> initial();

  void listen(Function(List<IAPProduct>) onProductChanged, Function(Object?) onError);

  /// Restore owned purchases from the store (Google / Huawei / Apple).
  Future<void> restore() async {}
}
