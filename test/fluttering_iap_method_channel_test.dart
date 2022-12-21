import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fluttering_iap/fluttering_iap_method_channel.dart';

void main() {
  MethodChannelFlutteringIap platform = MethodChannelFlutteringIap();
  const MethodChannel channel = MethodChannel('fluttering_iap');

  TestWidgetsFlutterBinding.ensureInitialized();

  setUp(() {
    channel.setMockMethodCallHandler((MethodCall methodCall) async {
      return '42';
    });
  });

  tearDown(() {
    channel.setMockMethodCallHandler(null);
  });

  test('getPlatformVersion', () async {
    expect(await platform.getPlatformVersion(), '42');
  });
}
