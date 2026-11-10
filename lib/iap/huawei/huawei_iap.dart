import 'package:flutter/material.dart';
import 'package:fluttering/fluttering.dart';
import 'package:fluttering_iap/iap/base_iap.dart';
import 'package:fluttering_iap/iap/models/iap_product.dart';
import 'package:fluttering_iap/iap/models/iap_product_info.dart';
import 'package:fluttering_iap/iap/models/iap_provider.dart';
import 'package:fluttering_iap/iap/models/iap_type.dart';
import 'package:huawei_iap/huawei_iap.dart';

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

  static const String _sigAlg = SignAlgorithmConstants.SIGNATURE_ALGORITHM_SHA256WITHRSA_PSS;

  int _priceTypeOf(IAPType type) {
    switch (type) {
      case IAPType.consumables:
        return IapClient.IN_APP_CONSUMABLE;
      case IAPType.nonConsumables:
        return IapClient.IN_APP_NONCONSUMABLE;
      case IAPType.subscriptions:
        return IapClient.IN_APP_SUBSCRIPTION;
      default:
        return IapClient.IN_APP_CONSUMABLE;
    }
  }

  @override
  Future<bool> initial() async {
    try {
      _isSupported = await CurrentPlatform.instance.isHmsAvailable;
      Debug.log("HUAWEI IAP IS SUPPORTED $_isSupported");
      if (_isSupported) {
        for (var type in IAPType.values) {
          await _loadProducts(type);
          await _loadPurchaseProducts(type);
        }
      }
      return true;
    } catch (error) {
      _error.value = error;
      Debug.log("HUAWEI IAP INITIAL ERROR $error");
    }
    return false;
  }

  @override
  Future<void> purchase(IAPProduct product) async {
    try {
      final info = await IapClient.createPurchaseIntent(PurchaseIntentReq(
        priceType: _priceTypeOf(product.type),
        productId: product.id,
        signatureAlgorithm: _sigAlg,
      ));

      if (info.returnCode == HmsIapResults.ORDER_STATE_SUCCESS.resultCode) {
        // Persist purchase data if present, then consume consumables.
        final purchaseData = info.inAppPurchaseData;
        if (purchaseData != null && purchaseData.productId != null) {
          _purchaseInfos.value = Map<String, InAppPurchaseData>.from(
            _purchaseInfos.value..[purchaseData.productId!] = purchaseData,
          );
          if (product.type == IAPType.consumables) {
            await _consumePurchase(purchaseData);
          }
        }
        await _loadProducts(product.type);
        await _loadPurchaseProducts(product.type);
      } else if (info.returnCode == HmsIapResults.ORDER_STATE_CANCEL.resultCode) {
        Debug.log("HUAWEI IAP PURCHASE CANCELLED");
      } else if (info.errMsg != null) {
        throw ErrorDescription(info.errMsg!);
      } else {
        throw ErrorDescription('Huawei IAP purchase failed code=${info.returnCode}');
      }
    } catch (error) {
      _error.value = error;
      Debug.log("HUAWEI IAP PURCHASE ERROR $error");
      rethrow;
    }
  }

  /// Required for consumables so the user can buy again.
  Future<void> _consumePurchase(InAppPurchaseData data) async {
    try {
      final token = data.purchaseToken;
      if (token == null || token.isEmpty) {
        Debug.log("HUAWEI IAP consume skipped — empty purchaseToken");
        return;
      }
      final result = await IapClient.consumeOwnedPurchase(ConsumeOwnedPurchaseReq(
        purchaseToken: token,
        signatureAlgorithm: _sigAlg,
      ));
      Debug.log("HUAWEI IAP consume result code=${result.returnCode} msg=${result.errMsg}");
    } catch (e) {
      Debug.log("HUAWEI IAP consume error $e");
    }
  }

  @override
  Future<void> restore() async {
    if (!_isSupported) return;
    try {
      for (final type in IAPType.values) {
        await _loadPurchaseProducts(type);
        // Also consume any leftover consumables that were not consumed.
        if (type == IAPType.consumables) {
          final owned = await IapClient.obtainOwnedPurchases(OwnedPurchasesReq(
            priceType: IapClient.IN_APP_CONSUMABLE,
            signatureAlgorithm: _sigAlg,
          ));
          for (final p in owned.inAppPurchaseDataList ?? <InAppPurchaseData>[]) {
            if (p.purchaseState == 0) {
              await _consumePurchase(p);
            }
          }
        }
      }
      Debug.log("HUAWEI IAP restore done");
    } catch (e) {
      _error.value = e;
      Debug.log("HUAWEI IAP restore error $e");
      rethrow;
    }
  }

  @override
  void listen(Function(List<IAPProduct>) onProductChanged, Function(Object?) onError) {
    _products.addListener(() {
      Debug.log("HUAWEI IAP PRODUCTS CHANGED ${_products.value.values}");
      onProductChanged(_products.value.values.toList());
    });

    _error.addListener(() {
      Debug.log("HUAWEI IAP HAS ERROR ${_error.value}");
      onError(_error.value);
    });
  }

  Future<void> _loadProducts(IAPType type) async {
    try {
      final List<ProductInfo> list = [];
      final List<String> skuIds = _products.value.values.where((e) => e.type == type).map((e) => e.id).toList();
      if (skuIds.isEmpty) return;

      final result = await IapClient.obtainProductInfo(ProductInfoReq(
        priceType: _priceTypeOf(type),
        skuIds: skuIds,
      ));
      list.addAll(result.productInfoList ?? []);

      _productInfos.value = Map<String, ProductInfo>.from(_productInfos.value
        ..addAll(list.asMap().map((_, e) => MapEntry(e.productId!, e))));
    } catch (error) {
      _error.value = error;
      Debug.log("HUAWEI IAP LOAD PRODUCTS ERROR $error");
    }
  }

  Future<void> _loadPurchaseProducts(IAPType type) async {
    try {
      final result = await IapClient.obtainOwnedPurchases(OwnedPurchasesReq(
        priceType: _priceTypeOf(type),
        signatureAlgorithm: _sigAlg,
      ));
      final list = result.inAppPurchaseDataList ?? <InAppPurchaseData>[];

      _purchaseInfos.value = Map<String, InAppPurchaseData>.from(_purchaseInfos.value
        ..addAll(list.asMap().map((_, e) {
          return MapEntry(e.productId!, e);
        })));
    } catch (error) {
      _error.value = error;
      Debug.log("HUAWEI IAP LOAD PURCHASE PRODUCTS ERROR $error");
    }
  }

  void _onPurchased() {
    for (var e in _purchaseInfos.value.values) {
      if (_products.value[e.productId] != null) {
        // purchaseState == 0 => purchased and not refunded
        _products.value[e.productId!] = _products.value[e.productId]!
          ..setPurchased(e.purchaseState == 0);
      }
    }
    _products.value = Map<String, IAPProduct>.from(_products.value);
  }

  void _onInfo() {
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
    _products.value = Map<String, IAPProduct>.from(_products.value);
  }

  void dispose() {
    _products.dispose();
    _productInfos.dispose();
    _purchaseInfos.dispose();
    _error.dispose();
  }
}
