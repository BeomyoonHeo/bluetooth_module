import 'dart:async';

import 'package:bluetooth_module/exception/bluetooth_module_exception.dart';
import 'package:bluetooth_module/extension/bluetooth_device_ext.dart';
import 'package:bluetooth_module/extension/future_wrap.dart';
import 'package:bluetooth_module/setting_object/base_bluetooth_object.dart';
import 'package:bluetooth_module/setting_object/setting_object.dart';
import 'package:bluetooth_module/utils/transformer/ble_model_transformer.dart';
import 'package:bluetooth_module/utils/transformer/bluetooth_discovery_transformer.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart' hide BluetoothDevice;

part '../extension/bluetooth_manager_ext.dart';

/// flutterbluetoothserial을 통해서 ble도 함께 가지고 올 수 있지만 flutterblueplus를 통해서 가지고 오는 이유는
/// flutterblueplus를 통해서 가지고 올 경우 service, characteristic, descriptor 등을 dart객체로 맵핑되어 가지고 올 수 있기 때문
/// 반대로 flutterbluetoothserial를 사용하는 이유는 flutterblueplus는 ble만 가지고 올 수 있기 때문에 classic을 가지고 오기 위해서 사용
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
        isBluetoothEnabledController:
            FlutterBluePlus.adapterState.transform(BluetoothStateTransformer()).asBroadcastStream(),
        settingObject: const SettingObject(),
        isScanningController: StreamController<bool>.broadcast(),
      ).._init();

  static BluetoothManager? _instance;

  final FlutterBluetoothSerial _classic;
  final Stream<bool> _isBluetoothEnabledController;
  final List<ClassicDevice> _lastClassicResults = [];
  final List<BleDevice> _lastBleResults = [];
  final StreamController<bool> _isScanningController;
  final Stream<List<BleDevice>> _liveBleResults =
      FlutterBluePlus.scanResults.transform(BleModelTransformer()).asBroadcastStream();
  final StreamController<List<ClassicDevice>> _liveClassicResults = StreamController<List<ClassicDevice>>.broadcast();
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

  /// 블루투스 활성화가 안될경우 설정 페이지로 이동
  Future<void> enableBluetooth() async {
    await FlutterBluePlus.turnOn(timeout: _settingObject.timeout).callWithCustomError(continueFunction: openSettings);
  }

  /// Android SDK 31+ only
  Future<void> disableBluetooth() async {
    await FlutterBluePlus.turnOff(timeout: _settingObject.timeout).callWithCustomError(continueFunction: openSettings);
  }

  /// flutterblueplus + flutterbluetoothserial 스캔을 동시 진행
  /// 각 호출은 stream으로 값을 받아온다
  /// flutterblueplus는 [FlutterBluePlus.lastScanResults]에 스캔이 끝날 경우 결과를 담아둔다
  /// classic의 discovery가 끝날경우 해당 stream이 close되기 때문에 동기성을 위해서 onDone 상태 진입시 flutterblueplus의 스캔을 중지한다
  /// 위 스캔이 끝나고 결과는 [lastBleResults],[lastClassicResults]에 담아둔다
  void startScan() async {
    if (_discoveryResultSubscription != null) {
      return;
    }

    _lastClassicResults.clear();

    _isScanningController.add(true);

    debugPrint('scanFilter Name List: ${_settingObject.filteringBleDeviceNameList}');

    FlutterBluePlus.startScan(withNames: _settingObject.filteringBleDeviceNameList, androidUsesFineLocation: true);

    _discoveryResultSubscription ??= _startDiscovery().listen((event) {
      _lastClassicResults.add(event.device.toClassicDevice());
      _liveClassicResults.add(_lastClassicResults);
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

  Future<void> removeBondDevice(String address) async {
    await BluetoothConnection.toAddress(address).then((value) => value.isConnected ? value.finish() : null);
    await _classic.removeDeviceBondWithAddress(address);
  }

  Future<void> bondDevice(String address, {bool isReBond = false}) async {
    try {
      final bondState = await _classic.getBondStateForAddress(address);

      final processRecord = (bondState.isBonded, isReBond);

      // 차라리 if - else가 더 나은듯? 가독성 우웩
      switch (processRecord) {
        case (true, true):
          await removeBondDevice(address);
          await valueOrException<bool?>(_classic.bondDeviceAtAddress(address));
          return;
        case (true, false):
          return;
        case (false, true):
        case (false, false):
          await valueOrException<bool?>(_classic.bondDeviceAtAddress(address));
          return;
      }
    } on BluetoothModuleException catch (e) {
      if (e is DeviceAlreadyBondedException) {}
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

  static void invalidateInstance() {
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

  FlutterBluetoothSerial get classic => _classic;

  List<BleDevice> get connectedDeviceList =>
      FlutterBluePlus.connectedDevices.map((e) => BleDevice(remoteId: e.remoteId)).toList();

  Stream<bool> get currentOnOffState => _isBluetoothEnabledController;

  Stream<bool> get isScan => _isScanningController.stream;

  List<ClassicDevice> get lastClassicResults => _lastClassicResults;

  List<BleDevice> get lastBleResults => _lastBleResults;

  Stream<List<BleDevice>> get liveBleResults => _liveBleResults;

  Stream<List<ClassicDevice>> get liveClassicResults => _liveClassicResults.stream;
}
