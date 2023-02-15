// ignore_for_file: depend_on_referenced_packages

import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fluttering/fluttering.dart';
import 'package:fluttering_iap/iap/models/iap_product.dart';
import 'package:fluttering_iap/iap/models/iap_product_info.dart';
import 'package:fluttering_iap/iap/models/iap_provider.dart';
import 'package:fluttering_iap/iap/models/iap_type.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:in_app_purchase_storekit/in_app_purchase_storekit.dart';
import 'package:in_app_purchase_storekit/store_kit_wrappers.dart';
import 'package:in_app_purchase_android/billing_client_wrappers.dart';
import 'package:in_app_purchase_android/in_app_purchase_android.dart';

import '../base_iap.dart';
import 'payment_queue_delegate.dart';

class GoogleIAP extends BaseIAP {
  GoogleIAP(List<IAPProduct> products) {
    /// ISNTANCE OF IN APP PURCHASE
    _inAppPurchase = InAppPurchase.instance;
    _products = ValueNotifier<Map<String, IAPProduct>>(products.asMap().map((_, e) => MapEntry(e.id, e)));
    _error = ValueNotifier<Object?>(null);
    _purchaseDetailsList = ValueNotifier({})..addListener(_onInfo);
    _productDetailsList = ValueNotifier({})..addListener(_onPurchased);
  }

  late final ValueNotifier<Map<String, IAPProduct>> _products;
  late final ValueNotifier<Object?> _error;
  late final InAppPurchase _inAppPurchase;
  late final StreamSubscription<List<PurchaseDetails>> _subscription;
  late final InAppPurchaseStoreKitPlatformAddition _iosPlatformAddition;

  late final ValueNotifier<Map<String, PurchaseDetails>> _purchaseDetailsList;
  late final ValueNotifier<Map<String, ProductDetails>> _productDetailsList;

  bool _isAvailable = false;
  bool get isAvailable => _isAvailable;

  @override
  bool get isSupported => CurrentPlatform.instance.isMobile;

  @override
  IAPProvider get provider => IAPProvider.google;

  @override
  Future<void> purchase(IAPProduct product) async {
    try {
      ProductDetails? productDetails = _productDetailsList.value[product.id];
      if (productDetails == null) return;
      await _skIOSPayment();
      switch (product.type) {
        case IAPType.consumables:
          _inAppPurchase.buyConsumable(
            purchaseParam: _createParams(productDetails: productDetails, subscription: false),
            autoConsume: true,
          );
          break;
        case IAPType.nonConsumables:
          _inAppPurchase.buyNonConsumable(
            purchaseParam: _createParams(productDetails: productDetails, subscription: false),
          );
          break;
        case IAPType.subscriptions:
          _inAppPurchase.buyConsumable(
            purchaseParam: _createParams(productDetails: productDetails, subscription: true),
          );
          break;
        default:
          _error.value = ErrorDescription('No support type ${product.type}');
          break;
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

  @override
  Future<bool> initial() async {
    /// LISTEN PURCHASE
    _subscription = _inAppPurchase.purchaseStream.listen(
      (purchaseDetails) => _purchaseDetailsList.value.addAll(purchaseDetails.asMap().map((_, e) {
        if (e.pendingCompletePurchase) _inAppPurchase.completePurchase(e);
        return MapEntry(e.productID, e);
      })),
      onDone: () => _subscription.cancel(),
      onError: (error) {
        _error.value = error;
        _subscription.cancel();
      },
    );

    /// CHECK IS AVAILIBALE
    try {
      _isAvailable = await _inAppPurchase.isAvailable();
      if (_isAvailable && CurrentPlatform.instance.isIos) {
        _iosPlatformAddition = _inAppPurchase.getPlatformAddition<InAppPurchaseStoreKitPlatformAddition>();
        await _iosPlatformAddition.setDelegate(PaymentQueueDelegate());
      }
    } catch (error) {
      _error.value = error;
    }

    /// LOAD PRODUCTS
    await _loadProducts();

    return true;
  }

  Future<void> _loadProducts() async {
    try {
      ProductDetailsResponse res = await _inAppPurchase.queryProductDetails(_products.value.keys.toSet());
      if (res.error != null) {
        _error.value = res.error;
      }
      _productDetailsList.value.clear();
      _productDetailsList.value.addAll(res.productDetails.asMap().map((_, e) {
        return MapEntry(e.id, e);
      }));
    } catch (error) {
      _error.value = error;
    }
  }

  Future<void> restorePurchase() async {
    try {
      _inAppPurchase.restorePurchases();
    } catch (error) {
      _error.value = error;
    }
  }

  Future<bool> _skIOSPayment() async {
    if (CurrentPlatform.instance.isIos) {
      var transactions = await SKPaymentQueueWrapper().transactions();
      for (var skPaymentTransactionWrapper in transactions) {
        SKPaymentQueueWrapper().finishTransaction(skPaymentTransactionWrapper);
      }
      return true;
    }
    return false;
  }

  _createParams({required ProductDetails productDetails, bool subscription = false}) {
    return CurrentPlatform.instance.isAndroid
        ? GooglePlayPurchaseParam(
            productDetails: productDetails,
            applicationUserName: null,
            changeSubscriptionParam: subscription && _purchaseDetailsList.value[productDetails.id] != null
                ? ChangeSubscriptionParam(
                    oldPurchaseDetails: _purchaseDetailsList.value[productDetails.id]! as GooglePlayPurchaseDetails,
                    prorationMode: ProrationMode.immediateWithTimeProration,
                  )
                : null,
          )
        : PurchaseParam(
            productDetails: productDetails,
          );
  }

  _onPurchased() {
    for (var e in _purchaseDetailsList.value.values) {
      if (_products.value[e.productID] != null) {
        _products.value[e.productID] = _products.value[e.productID]!..setPurchased(e.status == PurchaseStatus.purchased);
      }
    }
  }

  _onInfo() {
    for (var e in _productDetailsList.value.values) {
      if (_products.value[e.id] != null) {
        _products.value[e.id] = _products.value[e.id]!.copyWith(
          info: IAPProductInfo(
            price: e.price,
            name: e.title,
            description: e.description,
            rawPrice: e.rawPrice,
            currency: e.currencySymbol,
          ),
        );
      }
    }
  }

  dispose() {
    _iosPlatformAddition.setDelegate(null);
    _subscription.cancel();
    _products.dispose();
    _productDetailsList.dispose();
    _purchaseDetailsList.dispose();
    _error.dispose();
  }
}
