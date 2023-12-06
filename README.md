## Flutter Bluetooth Module

reference Repository: https://github.com/boskokg/flutter_blue_plus, https://github.com/edufolly/flutter_bluetooth_serial

블루투스 클래식과 블루투스 LE를 모두 지원하는 플러터 블루투스 모듈

## Todo
    -> discovering 진입 시 CustomClass에 맞는 transformer 구현
    -> Classic, LE 지원 객체 통합
    -> Platform별 유연한 예외처리 구현
    -> 추가적인 이벤트 발생에 대한 Stream 지원


## Using Dependencies
    flutter_bluetooth_serial: ^0.4.0
    flutter_blue_plus: ^1.30.2

## Using Platform
    Android
    IOS

Android: AndroidManifest.xml
```xml
    <uses-feature android:name="android.hardware.bluetooth_le" android:required="true" />

    <!-- New Bluetooth permissions in Android 12
    https://developer.android.com/about/versions/12/features/bluetooth-permissions -->
    <uses-permission android:name="android.permission.BLUETOOTH_SCAN" />
    <uses-permission android:name="android.permission.BLUETOOTH_CONNECT" />

    <!-- legacy for Android 11 or lower -->
    <uses-permission android:name="android.permission.BLUETOOTH" />
    <uses-permission android:name="android.permission.BLUETOOTH_ADMIN"/>
    <uses-permission android:name="android.permission.ACCESS_FINE_LOCATION"/>


    <!-- legacy for Android 9 or lower -->
    <uses-permission android:name="android.permission.ACCESS_COARSE_LOCATION"/>
```