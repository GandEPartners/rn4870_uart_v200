//====================================================
// RN4870 BLE UART Monitor
// File : ble_service.dart
// Ver 1.40
//
// Rev History
// 1.00 新規作成
// 1.10 Android14対応
// 1.20 BLE Scan
// 1.30 Device一覧表示
// 1.40 Connect対応
//====================================================

import 'package:flutter/foundation.dart';
import 'package:flutter_blue_plus/flutter_blue_plus.dart';
import 'package:permission_handler/permission_handler.dart';

import '../models/ble_device.dart';

//--------------------------------------------------
// RN4870 UART UUID
//--------------------------------------------------
const String uartServiceUuid = "49535343-FE7D-4AE5-8FA9-9FAFD205E455";
const String txCharacteristicUuid = "49535343-8841-43F4-A8D4-ECBE34729BB3";
const String rxCharacteristicUuid = "49535343-1E4D-4BD9-BA61-23C647249616";

class BleService {

  BluetoothDevice? connectedDevice;

  BluetoothCharacteristic? txCharacteristic;
  BluetoothCharacteristic? rxCharacteristic;

  //--------------------------------------------------
  // Receive Callback
  //--------------------------------------------------
  Function(String)? onReceive;

  //--------------------------------------------------
  // Scan
  //--------------------------------------------------
  Future<List<BleDeviceInfo>> scan() async {

    List<BleDeviceInfo> devices = [];

    debugPrint("========== BLE Scan Start ==========");

    //----------------------------------------
    // Permission
    //----------------------------------------
    await Permission.bluetoothScan.request();
    await Permission.bluetoothConnect.request();
    await Permission.location.request();

    //----------------------------------------
    // Bluetooth Supported ?
    //----------------------------------------
    if (!await FlutterBluePlus.isSupported) {
      debugPrint("Bluetooth NOT Supported");
      return devices;
    }

    //----------------------------------------
    // Stop Scan
    //----------------------------------------
    await FlutterBluePlus.stopScan();

    //----------------------------------------
    // Scan Result
    //----------------------------------------
    FlutterBluePlus.scanResults.listen((results) {

      devices.clear();

      for (ScanResult r in results) {

        String name = r.device.platformName;

        if (name.isEmpty) {
          name = "(No Name)";
        }

        devices.add(
          BleDeviceInfo(
            device: r.device,
            name: name,
            rssi: r.rssi,
          ),
        );

        debugPrint("$name   RSSI ${r.rssi}");

      }

    });

    //----------------------------------------
    // Start Scan
    //----------------------------------------
    await FlutterBluePlus.startScan(
      timeout: const Duration(seconds: 5),
    );

    //----------------------------------------
    // Wait
    //----------------------------------------
    await Future.delayed(const Duration(seconds: 5));

    debugPrint("========== Scan Finished ==========");

    return devices;
  }

  //--------------------------------------------------
  // Connect
  //--------------------------------------------------
  Future<bool> connect(BluetoothDevice device) async {

    try {

      debugPrint("Connect : ${device.platformName}");

      await device.connect();

      connectedDevice = device;

      await discoverUartService();

      debugPrint("Connected");

      return true;

    } catch (e) {

      debugPrint("Connect Error : $e");

      return false;

    }

  }

  //--------------------------------------------------
  // Disconnect
  //--------------------------------------------------
  Future<void> disconnect() async {

    if (connectedDevice == null) {
      return;
    }

    await connectedDevice!.disconnect();

    connectedDevice = null;

    debugPrint("Disconnected");

  }

  //--------------------------------------------------
  // Discover UART Service
  //--------------------------------------------------
  Future<bool> discoverUartService() async {

    if (connectedDevice == null) {
     debugPrint("No Connected Device");
     return false;
   }

    debugPrint("========== Discover Services ==========");

   List<BluetoothService> services =
       await connectedDevice!.discoverServices();

    for (BluetoothService service in services) {

      debugPrint("Service : ${service.uuid}");

      if (service.uuid.toString().toUpperCase() ==
          uartServiceUuid.toUpperCase()) {
        
        debugPrint("UART Service Found");

        for (BluetoothCharacteristic c in service.characteristics) {

          debugPrint("Characteristic : ${c.uuid}");

          if (c.uuid.toString().toUpperCase() ==
              txCharacteristicUuid.toUpperCase()) {

            txCharacteristic = c;
            debugPrint("TX Characteristic Found");
          }

          if (c.uuid.toString().toUpperCase() ==
              rxCharacteristicUuid.toUpperCase()) {
              
            rxCharacteristic = c;
            debugPrint("RX Characteristic Found");
          }
        }
        await startNotify();

        return (txCharacteristic != null &&
                rxCharacteristic != null);
        }
      }

      debugPrint("UART Service NOT Found");

      return false;
    }
    //--------------------------------------------------
    // Start Notify
    //-------------------------------------------------- 
    Future<void> startNotify() async {

      if (rxCharacteristic == null) {
       debugPrint("RX Characteristic NULL");
        return;
      }

      await rxCharacteristic!.setNotifyValue(true);

      rxCharacteristic!.lastValueStream.listen((value) {

        String text = String.fromCharCodes(value);

        debugPrint("RX : $text");

        if (onReceive != null) {
          onReceive!(text);
        }

      });

      debugPrint("Notify Started");
    }

    //--------------------------------------------------
    // UART Write
    //--------------------------------------------------
    Future<bool> write(String text) async {

      if (txCharacteristic == null) {
        debugPrint("TX Characteristic NULL");
        return false;
      }

      try {

        final data = <int>[
          ...text.codeUnits,
          0x00,
        ];

        await txCharacteristic!.write(
            data,
            withoutResponse: false,
        );

        debugPrint("TX : $text");

        return true;

      } catch (e) {

        debugPrint("Write Error : $e");

        return false;

      }

  }


}