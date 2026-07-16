//====================================================
// RN4870 BLE UART Monitor
// File : ble_device.dart
// Ver 1.40
//
// Rev History
// 1.40 新規作成
//====================================================

import 'package:flutter_blue_plus/flutter_blue_plus.dart';

class BleDeviceInfo {

  /// BLEデバイス本体
  final BluetoothDevice device;

  /// デバイス名
  final String name;

  /// RSSI
  final int rssi;

  const BleDeviceInfo({
    required this.device,
    required this.name,
    required this.rssi,
  });

}