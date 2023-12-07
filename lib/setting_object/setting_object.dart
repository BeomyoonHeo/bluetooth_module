///timeout: seconds
class SettingObject {
  final int timeout;
  final List<String> filteringDeviceNameList;
  final List<String> filteringBleDeviceNameList;
  final String? filteringDeviceAddress;

  const SettingObject({
    this.timeout = 5,
    this.filteringDeviceNameList = const [],
    this.filteringBleDeviceNameList = const [],
    this.filteringDeviceAddress,
  });

  SettingObject copyWith({
    int? timeout,
    List<String>? filteringDeviceNameList,
    List<String>? filteringBleDeviceNameList,
    String? filteringDeviceAddress,
  }) =>
      SettingObject(
        timeout: timeout ?? this.timeout,
        filteringDeviceNameList: filteringDeviceNameList ?? this.filteringDeviceNameList,
        filteringDeviceAddress: filteringDeviceAddress ?? this.filteringDeviceAddress,
        filteringBleDeviceNameList: filteringBleDeviceNameList ?? this.filteringBleDeviceNameList,
      );

  bool get isFilteringEnabled =>
      filteringDeviceNameList.isNotEmpty || filteringBleDeviceNameList.isNotEmpty || filteringDeviceAddress != null;
}
