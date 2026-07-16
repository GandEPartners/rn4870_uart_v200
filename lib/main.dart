//====================================================
// RN4870 BLE UART Monitor
// File : main.dart
// Ver 1.00
//====================================================

import 'package:flutter/material.dart';
import 'screens/home_page.dart';

void main() {
  runApp(const BleUartApp());
}

class BleUartApp extends StatelessWidget {
  const BleUartApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'RN4870 BLE UART Monitor',
      debugShowCheckedModeBanner: false,

      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.blue,
      ),

      home: HomePage(),
    );
  }
}