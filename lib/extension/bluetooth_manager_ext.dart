part of '../src/bluetooth_manager.dart';

extension BluetoothManagerExt on BluetoothManager {
  Future<T> valueOrException<T>(Future<T> value) async {
    try {
      return await value;
    } catch (e) {
      if (e is! PlatformException) {
        rethrow;
      }
      final exceptionResult = exceptionMap[(e).code];
      if (exceptionResult == null) {
        rethrow;
      }
      throw exceptionResult;
    }
  }
}
