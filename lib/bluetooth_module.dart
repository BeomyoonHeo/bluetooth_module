library bluetooth_module;

export 'src/bluetooth_mapper.dart';
export 'src/bluetooth_manager.dart';
export 'setting_object/base_bluetooth_object.dart';
export 'package:flutter_bluetooth_serial/flutter_bluetooth_serial.dart'
    hide BluetoothState, BluetoothBondState;
export 'package:flutter_blue_plus/flutter_blue_plus.dart'
    hide BluetoothDevice
    show
        OnBondStateChangedEvent,
        BluetoothBondState,
        OnConnectionStateChangedEvent,
        OnCharacteristicReceivedEvent,
        OnCharacteristicWrittenEvent,
        OnDescriptorReadEvent,
        OnDescriptorWrittenEvent,
        OnDiscoveredServicesEvent,
        OnMtuChangedEvent,
        OnNameChangedEvent,
        OnReadRssiEvent,
        OnServicesResetEvent,
        BluetoothCharacteristic,
        BluetoothConnectionState,
        LogLevel;
