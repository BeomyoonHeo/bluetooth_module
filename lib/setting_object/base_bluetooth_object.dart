import 'package:flutter_blue_plus/flutter_blue_plus.dart' as ble;
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart' as classic;

mixin BaseBluetoothObject {
  Future<void> tryConnection();
  Future<void> tryDisConnection();
}

class BleDevice extends ble.BluetoothDevice with BaseBluetoothObject {
  BleDevice({required super.remoteId});

  @override
  Future<void> tryConnection() async {
    try {
      await connect();
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> tryDisConnection() async {
    try {
      await disconnect();
    } catch (e) {
      rethrow;
    }
  }
}

class ClassicDevice extends classic.BluetoothDevice with BaseBluetoothObject {
  ClassicDevice({required super.address});
  classic.BluetoothConnection? _connection;

  @override
  Future<void> tryConnection() async {
    try {
      if (_connection != null) return;

      _connection ??= await classic.BluetoothConnection.toAddress(address);
    } catch (e) {
      rethrow;
    }
  }

  @override
  Future<void> tryDisConnection() async {
    try {
      await _connection?.finish();
      _connection = null;
    } catch (e) {
      rethrow;
    }
  }
}
