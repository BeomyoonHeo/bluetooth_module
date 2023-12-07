import 'dart:async';

import 'package:bluetooth_module/extension/bluetooth_device_ext.dart';
import 'package:bluetooth_module/extension/future_wrap.dart';
import 'package:bluetooth_module/setting_object/base_bluetooth_object.dart';
import 'package:bluetooth_module/setting_object/setting_object.dart';
import 'package:bluetooth_module/utils/transformer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' hide BluetoothDevice;

final class BluetoothManager extends FlutterBluePlus {
  BluetoothManager._({
    required FlutterBluetoothSerial classic,
    required Stream<bool> isBluetoothEnabledController,
    required SettingObject settingObject,
    required StreamController<bool> isScanningController,
  })  : _classic = classic,
        _isBluetoothEnabledController = isBluetoothEnabledController,
        _settingObject = settingObject,
        _isScanningController = isScanningController;

  factory BluetoothManager() => _instance ??= BluetoothManager._(
        classic: FlutterBluetoothSerial.instance,
        isBluetoothEnabledController: FlutterBluePlus.adapterState.transform(BluetoothStateTransformer()),
        settingObject: const SettingObject(),
        isScanningController: StreamController<bool>.broadcast(),
      ).._init();

  static BluetoothManager? _instance;

  final FlutterBluetoothSerial _classic;
  final Stream<bool> _isBluetoothEnabledController;
  final List<ClassicDevice> _lastDiscoveryResults = [];
  final List<BleDevice> _lastBleResults = [];
  final StreamController<bool> _isScanningController;
  SettingObject _settingObject;

  StreamSubscription<BluetoothDiscoveryResult>? _discoveryResultSubscription;
  StreamSubscription<bool>? _isScanningSubscription;

  void _init() {
    FlutterBluePlus.setLogLevel(LogLevel.verbose);

    _isScanningSubscription = FlutterBluePlus.isScanning.listen((isScanning) {
      debugPrint('isScanning: $isScanning');
      if (isScanning) {
        _isScanningController.add(true);
        _lastBleResults.clear();
      } else {
        _lastBleResults.addAll(FlutterBluePlus.lastScanResults.map((e) => BleDevice(remoteId: e.device.remoteId)));
        _isScanningController.add(false);
      }
    });

    FlutterBluePlus.events.onConnectionStateChanged.listen((event) async {
      debugPrint('connection state changed: ${event.device.isConnected}');
      debugPrint('connection state changed: ${event.device.servicesList}');
    });
  }

  /// SettingObject 내부에 있는 fiilter 를 통해 필터링을 진행
  Stream<BluetoothDiscoveryResult> _startDiscovery() {
    return _classic.startDiscovery().where((event) {
      if (!_settingObject.isFilteringEnabled) {
        return true;
      }

      final bool isNameMatched = _settingObject.filteringDeviceNameList.any((name) => name == event.device.name);

      if (_settingObject.filteringDeviceAddress != null) {
        final bool isAddressMatched = event.device.address == _settingObject.filteringDeviceAddress;

        return isAddressMatched || isNameMatched;
      } else {
        return isNameMatched;
      }
    });
  }

  Future<void> enableBluetooth() async {
    await FlutterBluePlus.turnOn(timeout: _settingObject.timeout).callWithCustomError(continueFunction: openSettings);
  }

  /// Android SDK 31+ only
  Future<void> disableBluetooth() async {
    await FlutterBluePlus.turnOff(timeout: _settingObject.timeout).callWithCustomError(continueFunction: openSettings);
  }

  void startScan() async {
    if (_discoveryResultSubscription != null) {
      return;
    }

    _lastDiscoveryResults.clear();

    _isScanningController.add(true);

    debugPrint('scanFilter Name List: ${_settingObject.filteringBleDeviceNameList}');

    FlutterBluePlus.startScan(withNames: _settingObject.filteringBleDeviceNameList, androidUsesFineLocation: true);

    _discoveryResultSubscription ??= _startDiscovery().listen((event) {
      _lastDiscoveryResults.add(event.device.toClassicDevice());
    }, onDone: () {
      FlutterBluePlus.stopScan();
      _discoveryResultSubscription?.cancel();
      _discoveryResultSubscription = null;
    });
  }

  Future<void> stopScan() async {
    await _classic.cancelDiscovery();
  }

  Future<void> openSettings() async {
    await _classic.openSettings();
  }

  Future<void> removeDevice(String address) async {
    await _classic.removeDeviceBondWithAddress(address);
  }

  Future<void> bondDevice(String address) async {
    await _classic.bondDeviceAtAddress(address);
  }

  Future<bool> connectDevice({
    BleDevice? bleDevice,
    ClassicDevice? classicDevice,
    Function? handleException,
  }) async {
    assert(bleDevice != null || classicDevice != null);
    assert(!(bleDevice != null && classicDevice != null));
    if (bleDevice != null) {
      return await bleDevice.tryConnection(handleException: handleException);
    } else {
      return await classicDevice?.tryConnection(handleException: handleException) ?? false;
    }
  }

  Future<bool> disConnectDevice({
    BleDevice? bleDevice,
    ClassicDevice? classicDevice,
    Function? handleException,
  }) async {
    assert(bleDevice != null || classicDevice != null);
    assert(!(bleDevice != null && classicDevice != null));
    if (bleDevice != null) {
      return await bleDevice.tryDisConnection(handleException: handleException);
    } else {
      return await classicDevice?.tryDisConnection(handleException: handleException) ?? false;
    }
  }

  void connectedDevices() async {
    final result = await _classic.getBondedDevices();

    for (final device in result) {
      debugPrint(device.isConnected.toString());
    }
  }

  void _cancelAllSubscription() {
    _discoveryResultSubscription?.cancel();
    _isScanningSubscription?.cancel();

    _discoveryResultSubscription = null;
    _isScanningSubscription = null;
  }

  static invalidateInstance() {
    if (_instance == null) {
      return;
    }
    _instance?._cancelAllSubscription();
    _instance?._isScanningController.close();
    _instance = null;
  }

  set timeout(int value) {
    _settingObject = _settingObject.copyWith(timeout: value);
  }

  set filteringDeviceName(List<String>? value) {
    _settingObject = _settingObject.copyWith(filteringDeviceNameList: value);
  }

  set filteringBleDeviceName(List<String>? value) {
    _settingObject = _settingObject.copyWith(filteringBleDeviceNameList: value);
  }

  set filteringDeviceAddress(String? value) {
    _settingObject = _settingObject.copyWith(filteringDeviceAddress: value);
  }

  static BluetoothEvents get bleEvents => FlutterBluePlus.events;

  Stream<bool> get currentOnOffState => _isBluetoothEnabledController;

  Stream<bool> get isDiscovering => _isScanningController.stream;

  List<ClassicDevice> get lastDiscoveryResults => _lastDiscoveryResults;

  List<BleDevice> get lastBleResults => _lastBleResults;
}
