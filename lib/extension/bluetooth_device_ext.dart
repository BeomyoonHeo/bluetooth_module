import 'package:bluetooth_module/bluetooth_module.dart';

extension BluetoothDeviceExt on BluetoothDevice {
  ClassicDevice toClassicDevice() =>
      ClassicDevice(address: address, name: name, type: type, bondState: bondState, isConnected: isConnected);
}
