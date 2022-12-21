import 'package:plugin_platform_interface/plugin_platform_interface.dart';

import 'fluttering_iap_method_channel.dart';

abstract class FlutteringIapPlatform extends PlatformInterface {
  /// Constructs a FlutteringIapPlatform.
  FlutteringIapPlatform() : super(token: _token);

  static final Object _token = Object();

  static FlutteringIapPlatform _instance = MethodChannelFlutteringIap();

  /// The default instance of [FlutteringIapPlatform] to use.
  ///
  /// Defaults to [MethodChannelFlutteringIap].
  static FlutteringIapPlatform get instance => _instance;

  /// Platform-specific implementations should set this with their own
  /// platform-specific class that extends [FlutteringIapPlatform] when
  /// they register themselves.
  static set instance(FlutteringIapPlatform instance) {
    PlatformInterface.verifyToken(instance, _token);
    _instance = instance;
  }

  Future<String?> getPlatformVersion() {
    throw UnimplementedError('platformVersion() has not been implemented.');
  }
}
