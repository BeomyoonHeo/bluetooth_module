class BluetoothMapper {
  const BluetoothMapper({
    required this.name,
    required this.address,
    required this.type,
    required this.bondState,
  });

  final String name;
  final String address;
  final int type;
  final int bondState;
}
