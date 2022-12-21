import 'package:fluttering_iap/iap/models/iap_item.dart';
import 'package:fluttering_iap/iap/models/iap_provider.dart';

class IAPConfig {
  final List<IAPItem> products;
  final IAPProvider provider;
  final bool enable;

  const IAPConfig({this.products = const [], this.enable = false, this.provider = IAPProvider.google});
}
