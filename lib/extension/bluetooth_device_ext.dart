import 'package:bluetooth_module/bluetooth_module.dart';
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart';

extension BluetoothDeviceExt on BluetoothDevice {
  ClassicDevice toClassicDevice() =>
      ClassicDevice(address: address, name: name, type: type, bondState: bondState, isConnected: isConnected);
}
