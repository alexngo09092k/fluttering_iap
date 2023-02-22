import 'package:flutter/material.dart';
import 'package:fluttering/fluttering.dart';
import 'package:fluttering_iap/iap/base_iap.dart';
import 'package:fluttering_iap/iap/models/iap_product.dart';
import 'package:fluttering_iap/iap/models/iap_product_info.dart';
import 'package:fluttering_iap/iap/models/iap_provider.dart';
import 'package:fluttering_iap/iap/models/iap_type.dart';
import 'package:huawei_iap/HmsIapLibrary.dart';

class HuaweiIAP extends BaseIAP {
  HuaweiIAP(List<IAPProduct> products) {
    _products = ValueNotifier<Map<String, IAPProduct>>(products.asMap().map((_, e) => MapEntry(e.id, e)));
    _productInfos = ValueNotifier({})..addListener(_onInfo);
    _purchaseInfos = ValueNotifier({})..addListener(_onPurchased);
    _error = ValueNotifier<Object?>(null);
  }

  late final ValueNotifier<Map<String, IAPProduct>> _products;
  late final ValueNotifier<Object?> _error;

  late final ValueNotifier<Map<String, ProductInfo>> _productInfos;
  late final ValueNotifier<Map<String, InAppPurchaseData>> _purchaseInfos;


  bool _isSupported = CurrentPlatform.instance.isHuawei;
  @override
  bool get isSupported => _isSupported;

  @override
  IAPProvider get provider => IAPProvider.huawei;

  @override
  Future<bool> initial() async {
    try {
      _isSupported = await CurrentPlatform.instance.isHmsAvailable;
      Debug.log("HuaweiIAP is supported $_isSupported");
      if(_isSupported) {
        for (var type in IAPType.values) {
          _loadProducts(type);
          _loadPurchaseProducts(type);
        }
      }
      return true;
    }catch(error) {
      _error.value = error;
      Debug.log("HuaweiIAP initial error $error");
    }
    return false;
  }

  @override
  Future<void> purchase(IAPProduct product) async {
    try {
      late PurchaseResultInfo info;
      switch (product.type) {
        case IAPType.consumables:
          info = await IapClient.createPurchaseIntent(PurchaseIntentReq(
            priceType: IapClient.IN_APP_CONSUMABLE,
            productId: product.id,
            signatureAlgorithm: SignAlgorithmConstants.SIGNATURE_ALGORITHM_SHA256WITHRSA_PSS,
          ));
          break;
        case IAPType.nonConsumables:
          info = await IapClient.createPurchaseIntent(PurchaseIntentReq(
            priceType: IapClient.IN_APP_NONCONSUMABLE,
            productId: product.id,
            signatureAlgorithm: SignAlgorithmConstants.SIGNATURE_ALGORITHM_SHA256WITHRSA_PSS,
          ));
          break;
        case IAPType.subscriptions:
          info = await IapClient.createPurchaseIntent(PurchaseIntentReq(
            priceType: IapClient.IN_APP_SUBSCRIPTION,
            productId: product.id,
            signatureAlgorithm: SignAlgorithmConstants.SIGNATURE_ALGORITHM_SHA256WITHRSA_PSS,
          ));
          break;
        default:
          _error.value = ErrorDescription('No support type ${product.type}');
          break;
      }
      if (info.returnCode == HmsIapResults.ORDER_STATE_SUCCESS.resultCode) {
        _loadProducts(product.type);
        _loadPurchaseProducts(product.type);
      } else if (info.errMsg != null) {
        throw ErrorDescription(info.errMsg!);
      }
    } catch (error) {
      _error.value = error;
    }
  }

  @override
  void listen(Function(List<IAPProduct>) onProductChanged, Function(Object?) onError) {
    _products.addListener(() => onProductChanged(_products.value.values.toList()));
    _error.addListener(() => onError(_error.value));
  }

  _loadProducts(IAPType type) async {
    try {
      List<ProductInfo> list = [];

      switch (type) {
        case IAPType.consumables:
          list.addAll((await IapClient.obtainProductInfo(
                ProductInfoReq(
                  priceType: IapClient.IN_APP_CONSUMABLE,
                  skuIds: _products.value.values.where((e) => e.type == IAPType.consumables).map((e) => e.id).toList(),
                ),
              ))
                  .productInfoList ??
              []);

          break;
        case IAPType.nonConsumables:
          list.addAll((await IapClient.obtainProductInfo(
                ProductInfoReq(
                  priceType: IapClient.IN_APP_NONCONSUMABLE,
                  skuIds: _products.value.values.where((e) => e.type == IAPType.nonConsumables).map((e) => e.id).toList(),
                ),
              ))
                  .productInfoList ??
              []);
          break;
        case IAPType.subscriptions:
          list.addAll((await IapClient.obtainProductInfo(
                ProductInfoReq(
                  priceType: IapClient.IN_APP_SUBSCRIPTION,
                  skuIds: _products.value.values.where((e) => e.type == IAPType.subscriptions).map((e) => e.id).toList(),
                ),
              ))
                  .productInfoList ??
              []);

          break;
        default:
          break;
      }

      _productInfos.value.addAll(list.asMap().map((_, e) {
        return MapEntry(e.productId!, e);
      }));
    } catch (error) {
      _error.value = error;
    }
  }

  _loadPurchaseProducts(IAPType type) async {
    try {
      List<InAppPurchaseData> list = [];
      switch (type) {
        case IAPType.consumables:
          list.addAll((await IapClient.obtainOwnedPurchases(OwnedPurchasesReq(
                priceType: IapClient.IN_APP_CONSUMABLE,
                signatureAlgorithm: SignAlgorithmConstants.SIGNATURE_ALGORITHM_SHA256WITHRSA_PSS,
              )))
                  .inAppPurchaseDataList ??
              []);
          break;
        case IAPType.nonConsumables:
          list.addAll((await IapClient.obtainOwnedPurchases(OwnedPurchasesReq(
                priceType: IapClient.IN_APP_NONCONSUMABLE,
                signatureAlgorithm: SignAlgorithmConstants.SIGNATURE_ALGORITHM_SHA256WITHRSA_PSS,
              )))
                  .inAppPurchaseDataList ??
              []);
          break;
        case IAPType.subscriptions:
          list.addAll((await IapClient.obtainOwnedPurchases(OwnedPurchasesReq(
                priceType: IapClient.IN_APP_SUBSCRIPTION,
                signatureAlgorithm: SignAlgorithmConstants.SIGNATURE_ALGORITHM_SHA256WITHRSA_PSS,
              )))
                  .inAppPurchaseDataList ??
              []);
          break;
        default:
      }

      _purchaseInfos.value.addAll(list.asMap().map((_, e) {
        return MapEntry(e.productId!, e);
      }));
    } catch (error) {
      _error.value = error;
    }
  }

  _onPurchased() {
    for (var e in _purchaseInfos.value.values) {
      if (_products.value[e.productId] != null) {
        _products.value[e.productId!] = _products.value[e.productId]!..setPurchased(e.purchaseState == 0);
      }
    }
  }

  _onInfo() {
    for (var e in _productInfos.value.values) {
      if (_products.value[e.productId] != null) {
        _products.value[e.productId!] = _products.value[e.productId]!.copyWith(
          info: IAPProductInfo(
            price: e.price ?? '',
            name: e.productName ?? '',
            description: e.productDesc ?? '',
            rawPrice: e.microsPrice?.toDouble() ?? 0,
            currency: e.currency ?? '',
          ),
        );
      }
    }
  }

  dispose() {
    _products.dispose();
    _productInfos.dispose();
    _purchaseInfos.dispose();
    _error.dispose();
  }
}
