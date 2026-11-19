# fluttering_iap

**Unified in-app purchase module for the [Fluttering](https://pub.dev/packages/fluttering) toolkit.**

Supports **Google Play Billing / StoreKit** (`in_app_purchase`) and **Huawei IAP** with one product catalog and purchase flow.

---

## Features

- Single entry point around `IAPConfig` + providers
- Providers: Google/Apple (`in_app_purchase`) + Huawei (`huawei_iap`)
- Product types via `IAPType` / `IAPProduct`
- Query products, purchase, restore
- Integrates with Fluttering (`Provider` ecosystem)

---

## Getting started

```yaml
dependencies:
  fluttering: ^3.0.0
  fluttering_iap: ^3.0.4
```

### Platform setup

- [in_app_purchase](https://pub.dev/packages/in_app_purchase) – Google Play Console / App Store Connect products
- [Huawei IAP](https://developer.huawei.com/consumer/en/doc/development/HMSCore-Guides/introduction-0000001050033062) – AppGallery Connect

---

## Usage

```dart
import 'package:fluttering_iap/fluttering_iap.dart';

final config = IAPConfig(
  enable: true,
  providers: [IAPProvider.google, IAPProvider.huawei],
  products: [
    IAPProduct(
      id: 'premium_monthly',
      // type, title, etc. as defined in your models
    ),
  ],
);

// Initialize your IAP manager (see lib/iap/iap.dart)
// then query products and call purchase / restore.
```

See `lib/iap/` for `AwesomeIAP`-style entry points and provider implementations.

---

## Additional information

- Depends on the core **fluttering** package.
- Author: Brennan Ngo / ThemePlace
- License: MIT
