import 'package:fluttering_iap/iap/models/iap_item.dart';
import 'package:fluttering_iap/iap/models/iap_provider.dart';

abstract class BaseIAP {
  IAPProvider get provider;

  bool get isSupported;

  Future<void> purchase(IAPItem product);

  void listen(Function(List<IAPItem>) onProductChanged, Function(Object?) onError);
}
