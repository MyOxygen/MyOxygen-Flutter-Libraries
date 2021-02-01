import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:action_log/action_log.dart';

void main() {
  const MethodChannel channel = MethodChannel('action_log');

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
    expect(await ActionLog.platformVersion, '42');
  });
}
