import 'package:flutter_blue_plus/flutter_blue_plus.dart' as ble;
import 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart' as classic;

mixin BaseBluetoothObject {
  Future<bool> tryConnection({Function? handleException});
  Future<bool> tryDisConnection({Function? handleException});
}

class BleDevice extends ble.BluetoothDevice with BaseBluetoothObject {
  BleDevice({required super.remoteId});

  @override
  Future<bool> tryConnection({
    bool isGetDiscoveryServices = true,
    Function? handleException,
  }) async {
    try {
      await connect();
      if (isGetDiscoveryServices) await discoverServices();
      return true;
    } catch (e) {
      if (handleException == null) rethrow;
      handleException.call();
      return false;
    }
  }

  @override
  Future<bool> tryDisConnection({
    Function? handleException,
  }) async {
    try {
      await disconnect();
      return true;
    } catch (e) {
      if (handleException == null) rethrow;
      handleException.call();
      return false;
    }
  }
}

class ClassicDevice extends classic.BluetoothDevice with BaseBluetoothObject {
  ClassicDevice({
    required super.address,
    super.name,
    super.type,
    super.bondState,
    super.isConnected,
  });

  classic.BluetoothConnection? _connection;

  @override
  Future<bool> tryConnection({Function? handleException}) async {
    try {
      if (_connection != null) return true;
      _connection ??= await classic.BluetoothConnection.toAddress(address);
      return true;
    } catch (e) {
      if (handleException == null) rethrow;
      handleException.call();
      return false;
    }
  }

  @override
  Future<bool> tryDisConnection({Function? handleException}) async {
    try {
      if (_connection == null) return true;
      await _connection?.finish();
      _connection = null;
      return true;
    } catch (e) {
      if (handleException != null) handleException(e);
      if (handleException == null) rethrow;
      handleException.call();
      return false;
    }
  }
}
