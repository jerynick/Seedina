import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:seedina/utils/rewidgets/global/myappbar.dart';
import 'package:seedina/utils/style/gcolor.dart';
import 'package:esp_smartconfig/esp_smartconfig.dart';
import 'package:shared_preferences/shared_preferences.dart';

class WiFiConn extends StatefulWidget {

  const WiFiConn({
    super.key,
  });

  @override
  State<WiFiConn> createState() => _WiFiConnState();
}

class _WiFiConnState extends State<WiFiConn> {
  final ssidController = TextEditingController();
  final passwordController = TextEditingController();

  Future<void> _startProvisioning() async {
    final provisioner = Provisioner.espTouch();

    provisioner.listen((response) {
      Navigator.of(context).pop(response);
    });

    provisioner.start(ProvisioningRequest.fromStrings(
      ssid: ssidController.text,
      bssid: '00:00:00:00:00:00',
      password: passwordController.text
    ));

    ProvisioningResponse? response = await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Provisiong'),
          content: const Text('Memulai Provisioning. Tunggu..'),
          actions: <Widget>[
            TextButton(
              onPressed: (){
                if(provisioner.running) {
                  provisioner.stop();
                }
                Navigator.of(dialogContext).pop();
              },
              child: Text("Hentikan")
            )
          ],
        );
      }
    );

    if(provisioner.running) {
      provisioner.stop();
    }

    if (response != null) {
      _onDeviceProvisioned(response);
    }
  }

    _onDeviceProvisioned(ProvisioningResponse response) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: const Text('Perangkat ESP32 Tehubung'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text('Sistem ESP32 berhasil terhubung ke jaringan ${ssidController.text}'),
              SizedBox.fromSize(size: const Size.fromHeight(20)),
              const Text('Detail:'),
              Text('IP: ${response.ipAddressText}'),
              Text('BSSID: ${response.bssidText}'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                try {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isSetupComplete', true);
                } catch (e) {
                  if(kDebugMode) {
                    print('Error SharedPreferences: $e');
                  }
                }

                if (mounted) {
                  Navigator.pop(dialogContext);
                }
              },
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.white,
        appBar: CustomAppBar(
            title: Text(
              'Koneksi ESP32',
              style: TextStyle(
                  fontWeight: FontWeight.w900,
                  fontFamily: 'Quicksand',
                  color: GColors.myKuning),
            ),
            actions: [],
            showBackButton: true
          ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                      width: 256,
                      height: 256,
                      child: Image.asset('assets/illustration/ill_esp32conn.png')),
                      SizedBox(height: 20,),
                  Container(
                    decoration: BoxDecoration(
                      color: GColors.myBiru,
                      borderRadius: BorderRadius.circular(16)
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.warning,
                            color: Colors.amber,
                            size: 40,
                          ),
                          Text(
                            'Masukkan SSID dan Kata Sandi WiFi yang terhubung dengan ponsel anda',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white
                            ),
                          ),
                        ],
                      ),
                    )
                  ),
                  SizedBox(height: 20,),
                  TextFormField(
                    style: const TextStyle(fontSize: 12),
                    controller: ssidController,
                    decoration: InputDecoration(
                      hintText: 'Nama SSID WiFi',
                      hintStyle: const TextStyle(fontSize: 12),
                      border:
                          OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  SizedBox(height: 16,),
                  TextFormField(
                    style: const TextStyle(fontSize: 12),
                    controller: passwordController,
                    decoration: InputDecoration(
                      hintText: 'Kata Sandi WiFi',
                      hintStyle: const TextStyle(fontSize: 12),
                      border:
                          OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    ),
                  ),
                  SizedBox(height: 20,),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: GColors.myBiru,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))
                    ),
                    onPressed: _startProvisioning,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_tethering),
                        SizedBox(width: 12,),
                        Text('Hubungkan ESP32 ke WiFi')
                      ],
                    )
                  )
                ],
              ),
            ),
          ),
        ),
    );
  }
    @override
  void dispose() {
    ssidController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}


