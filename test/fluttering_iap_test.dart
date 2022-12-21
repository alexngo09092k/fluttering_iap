import 'package:flutter_test/flutter_test.dart';
import 'package:fluttering_iap/fluttering_iap_platform_interface.dart';
import 'package:fluttering_iap/fluttering_iap_method_channel.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

class MockFlutteringIapPlatform with MockPlatformInterfaceMixin implements FlutteringIapPlatform {
  @override
  Future<String?> getPlatformVersion() => Future.value('42');
}

void main() {
  final FlutteringIapPlatform initialPlatform = FlutteringIapPlatform.instance;

  test('$MethodChannelFlutteringIap is the default instance', () {
    expect(initialPlatform, isInstanceOf<MethodChannelFlutteringIap>());
  });

  test('getPlatformVersion', () async {
    // FlutteringIap flutteringIapPlugin = FlutteringIap();
    // MockFlutteringIapPlatform fakePlatform = MockFlutteringIapPlatform();
    // FlutteringIapPlatform.instance = fakePlatform;

    // expect(await flutteringIapPlugin.getPlatformVersion(), '42');
  });
}
