///timeout: seconds
///branchOutEvent: 블루투스 클래식과 ble 이벤트를 동시에 받을지 아니면 따로 받을지 결정하는 옵션
class SettingObject {
  final int timeout;
  final List<String> filteringDeviceNameList;
  final List<String> filteringBleDeviceNameList;
  final String? filteringDeviceAddress;
  final bool branchOutEvent;

  const SettingObject({
    this.timeout = 5,
    this.filteringDeviceNameList = const [],
    this.filteringBleDeviceNameList = const [],
    this.filteringDeviceAddress,
    this.branchOutEvent = false,
  });

  SettingObject copyWith({
    int? timeout,
    List<String>? filteringDeviceNameList,
    List<String>? filteringBleDeviceNameList,
    String? filteringDeviceAddress,
    bool? branchOutEvent,
  }) =>
      SettingObject(
        timeout: timeout ?? this.timeout,
        filteringDeviceNameList: filteringDeviceNameList ?? this.filteringDeviceNameList,
        filteringDeviceAddress: filteringDeviceAddress ?? this.filteringDeviceAddress,
        filteringBleDeviceNameList: filteringBleDeviceNameList ?? this.filteringBleDeviceNameList,
        branchOutEvent: branchOutEvent ?? this.branchOutEvent,
      );

  bool get isFilteringEnabled =>
      filteringDeviceNameList.isNotEmpty ||
      filteringBleDeviceNameList.isNotEmpty ||
      filteringDeviceAddress != null;
}
