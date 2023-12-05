import 'dart:async';

import 'package:bluetooth_module/extension/future_wrap.dart';
import 'package:bluetooth_module/utils/transformer.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';

final class BluetoothManager extends FlutterBluePlus {
  BluetoothManager._(
    this._classic,
    this._isBluetoothEnabledController,
  );

  static BluetoothManager? _instance;

  final FlutterBluetoothSerial _classic;
  final Stream<bool> _isBluetoothEnabledController;
  final List<BluetoothDiscoveryResult> _lastDiscoveryResults = [];

  factory BluetoothManager() => _instance ??= BluetoothManager._(
        FlutterBluetoothSerial.instance,
        FlutterBluePlus.adapterState.transform(BluetoothStateTransformer()),
      );

  Stream<bool> get currentOnOffState => _isBluetoothEnabledController;

  Future<void> enableBluetooth() async {
    await FlutterBluePlus.turnOn(timeout: 5).callWithCustomError(continueFunction: openSettings);
  }

  /// Android SDK 31+ only
  Future<void> disableBluetooth() async {
    await FlutterBluePlus.turnOff(timeout: 5).callWithCustomError(continueFunction: openSettings);
  }

  void startScan() {
    _classic.startDiscovery();
  }

  void stopScan() {
    _classic.cancelDiscovery();
  }

  Future<void> openSettings() async {
    await _classic.openSettings();
  }

  static invalidateInstance() {
    _instance = null;
  }
}
