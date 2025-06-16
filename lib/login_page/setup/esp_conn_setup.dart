import 'package:flutter/material.dart';
import 'package:seedina/utils/style/gcolor.dart';
import 'package:esp_smartconfig/esp_smartconfig.dart';
import 'package:seedina/services/auth_service.dart';

class WiFiConnSetup extends StatefulWidget {
  const WiFiConnSetup({super.key});

  @override
  State<WiFiConnSetup> createState() => _WiFiConnSetupState();
}

class _WiFiConnSetupState extends State<WiFiConnSetup> {
  final ssidController = TextEditingController();
  final passwordController = TextEditingController();
  bool _isCompletingSetup = false;
  bool _isProvisioning = false;

  Future<void> _markSetupAsCompleteAndNavigate() async {
    setState(() {
      _isCompletingSetup = true;
    });

    final String? uid = AuthService.currentUser?.uid;
    if (uid == null) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar( const SnackBar(content: Text("User tidak terautentikasi.")));
      }
      setState(() => _isCompletingSetup = false);
      return;
    }

    bool updateSuccess = await AuthService.updateUserDocument(uid, {'setupComplete': true}, context);

    if (updateSuccess && mounted) {
      Navigator.pushNamedAndRemoveUntil(context, '/authcheck', (route) => false);
    }

    if (mounted && !updateSuccess) {
      setState(() {
        _isCompletingSetup = false;
      });
    }
  }

  Future<void> _startProvisioning() async {
    if (ssidController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("SSID dan Password WiFi tidak boleh kosong.")));
      return;
    }

    setState(() {
      _isProvisioning = true;
    });

    final provisioner = Provisioner.espTouch();

    provisioner.listen((response) {
      if (mounted) Navigator.of(context).pop(response);
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
          title: const Text('Provisioning ESP32'),
          content: const Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(),
              SizedBox(height: 16,),
              Text('Menghubungkan ESP32 ke WiFi... Mohon tunggu.'),
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                if (provisioner.running) {
                  provisioner.stop();
                }
                Navigator.of(dialogContext).pop(null);
              },
              child: const Text("HENTIKAN", style: TextStyle(color: Colors.red),)
            )
          ],
        );
      }
    );

    if (mounted) {
      setState(() {
        _isProvisioning = false;
      });
    }

    if (provisioner.running) {
      provisioner.stop();
    }

    if (response != null) {
      _onDeviceProvisioned(response);
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Proses provisioning ESP32 dibatalkan atau tidak mendapatkan respons.")));
      }
    }
  }

  _onDeviceProvisioned(ProvisioningResponse response) {
    final String? bssid = response.bssidText;
    final String? ipAddress = response.ipAddressText;

    final bool provisioningSuccessful =
        (bssid != null && bssid.isNotEmpty) &&
        (ipAddress != null && ipAddress.isNotEmpty);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) {
        return AlertDialog(
          title: Text(provisioningSuccessful ? 'ESP32 Terhubung!' : 'Gagal Terhubung'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(provisioningSuccessful
                  ? 'Sistem ESP32 berhasil terhubung ke jaringan "${ssidController.text}".'
                  : 'Gagal menghubungkan ESP32. Pastikan ESP32 dalam mode provisioning (biasanya ditandai dengan pola kedip LED tertentu), kredensial WiFi benar, dan ponsel Anda terhubung ke jaringan WiFi 2.4GHz (jika ESP32 hanya mendukung 2.4GHz).'),
              if (provisioningSuccessful) ...[
                const SizedBox(height: 20),
                const Text('Detail Koneksi:', style: TextStyle(fontWeight: FontWeight.bold)),
                Text('Alamat IP: $ipAddress'),
              ]
            ],
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () async {
                Navigator.pop(dialogContext);
                if (provisioningSuccessful) {
                  await _markSetupAsCompleteAndNavigate();
                } else {
                  if (mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text("Silakan periksa pengaturan ESP32 dan coba lagi.")));
                  }
                }
              },
              child: Text(provisioningSuccessful ? 'LANJUTKAN' : 'MENGERTI'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration:  const BoxDecoration(
        gradient: LinearGradient(
          colors: [GColors.myBiru, GColors.myHijau],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter)
        ),
      child: Scaffold(
          backgroundColor: Colors.transparent,
          appBar: AppBar(
              backgroundColor: Colors.transparent,
              title: const Text("Hubungkan ESP32 ke WiFi", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
              centerTitle: true,
              automaticallyImplyLeading: false,
          ),
          body: SingleChildScrollView(
            child: Padding(
              padding:  const EdgeInsets.all(24.0),
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(
                        width: 220,
                        height: 220,
                        child: Image.asset('assets/illustration/ill_esp32conn.png')),
                        const SizedBox(height: 24),
                    Container(
                      decoration: BoxDecoration(
                        color: GColors.myBiru.withOpacity(0.85),
                        borderRadius: BorderRadius.circular(16)
                      ),
                      padding: const EdgeInsets.all(16.0),
                      child: const Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.info_outline_rounded,
                            color: Colors.white,
                            size: 36,
                          ),
                          SizedBox(height: 8),
                          Text(
                            'Pastikan ESP32 Anda dalam mode SmartConfig/Provisioning. Masukkan nama dan kata sandi WiFi yang sama dengan yang digunakan ponsel Anda saat ini.',
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 14
                            ),
                          ),
                        ],
                      )
                    ),
                    const SizedBox(height: 24),
                    TextFormField(
                      style:  const TextStyle(fontSize: 14, color: Colors.black87),
                      controller: ssidController,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.95),
                        hintText: 'Nama SSID WiFi',
                        hintStyle:  TextStyle(fontSize: 14, color: Colors.grey.shade700),
                        prefixIcon: const Icon(Icons.wifi, color: GColors.myBiru),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GColors.myKuning, width: 2)),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextFormField(
                      style:  const TextStyle(fontSize: 14, color: Colors.black87),
                      controller: passwordController,
                      obscureText: true,
                      decoration: InputDecoration(
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.95),
                        hintText: 'Kata Sandi WiFi',
                        hintStyle:  TextStyle(fontSize: 14, color: Colors.grey.shade700),
                        prefixIcon: const Icon(Icons.lock_outline_rounded, color: GColors.myBiru),
                        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide.none),
                        focusedBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: const BorderSide(color: GColors.myKuning, width: 2)),
                      ),
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: GColors.myKuning,
                          foregroundColor: GColors.myBiru,
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12))
                        ),
                        onPressed: _isProvisioning ? null : _startProvisioning,
                        child: _isProvisioning
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(width: 24, height: 24, child: CircularProgressIndicator(color: GColors.myBiru, strokeWidth: 3)),
                              SizedBox(width: 12),
                              Text('MENGHUBUNGKAN...', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))
                            ],
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.wifi_tethering_rounded),
                              SizedBox(width: 12),
                              Text('Hubungkan ESP32 ke WiFi', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15))
                            ],
                          )
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: TextButton(
                        style: TextButton.styleFrom(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                            side: BorderSide(color: Colors.white.withOpacity(0.7))
                          )
                        ),
                        onPressed: (_isCompletingSetup || _isProvisioning) ? null : _markSetupAsCompleteAndNavigate,
                        child: _isCompletingSetup
                          ? const CircularProgressIndicator(color: Colors.white)
                          : const Text('Selesaikan Setup (Tanpa ESP)', style: TextStyle(color: Colors.white, fontSize: 14)),
                      ),
                    ),
                  ],
                ),
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