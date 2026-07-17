//====================================================
// RN4870 BLE UART Monitor
// File : home_page.dart
// Ver 2.00
//
// Rev History
// 1.00 新規作成
// 1.10 BLE画面作成
// 1.20 Scanボタン追加
// 1.30 BLE一覧表示対応
// 2.00 BleDeviceInfo対応
//====================================================

import 'package:flutter/material.dart';

import '../models/ble_device.dart';
import '../services/ble_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  final BleService ble = BleService();
  final TextEditingController txController = TextEditingController();

  List<BleDeviceInfo> deviceList = [];

  String connectStatus = "未接続";

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      appBar: AppBar(
        title: const Text("RN4870 BLE UART Monitor"),
      ),

      body: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.stretch,

          children: [

            ElevatedButton(

              onPressed: () async {

                final list = await ble.scan();

                setState(() {
                  deviceList = list;
                });

              },

              child: const Text("Scan"),

            ),

            const SizedBox(height: 20),

            Text(
              "接続状態：$connectStatus",
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const Divider(),

            const SizedBox(height: 20),

            const Text(
              "送信データ",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            const SizedBox(height: 10),

            TextField(
              controller: txController,
              decoration: const InputDecoration(
                border: OutlineInputBorder(),
                hintText: "送信文字列を入力",
              ),
            ),

            const SizedBox(height: 10),

            ElevatedButton(
              onPressed: () async {

                if (txController.text.isEmpty) {
                  return;
                }

                await ble.write(txController.text);

              },
              child: const Text("Send"),
            ),

            const SizedBox(height: 20),

            const Text(
              "デバイス一覧",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),

            Expanded(

              child: ListView.builder(

                itemCount: deviceList.length,

                itemBuilder: (context, index) {

                  final dev = deviceList[index];

                  return Card(

                    child: ListTile(

                      leading: const Icon(Icons.bluetooth),

                      title: Text(dev.name),

                      subtitle: Text("RSSI : ${dev.rssi}"),

                      onTap: () async {

                        setState(() {
                          connectStatus = "接続中...";
                        });

                        bool ok = await ble.connect(dev.device);

                        setState(() {

                          if (ok) {
                            connectStatus = "接続済み";
                          } else {
                            connectStatus = "接続失敗";
                          }
                        });

                          if (ok) {
                            debugPrint("Wait before Handshake");

                            await Future.delayed(
                                const Duration(seconds: 2)
                            );
                          
                            await ble.write("Communication Started.");

                            debugPrint("Handshake Sent");
                            
                          }                    

                      },

                    ),

                  );

                },

              ),

            ),

          ],

        ),

      ),

    );

  }

}