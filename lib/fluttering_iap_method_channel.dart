import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

import 'fluttering_iap_platform_interface.dart';

/// An implementation of [FlutteringIapPlatform] that uses method channels.
class MethodChannelFlutteringIap extends FlutteringIapPlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('fluttering_iap');

  @override
  Future<String?> getPlatformVersion() async {
    final version = await methodChannel.invokeMethod<String>('getPlatformVersion');
    return version;
  }
}
