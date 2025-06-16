// lib/menu_page/profile/profile.dart
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:seedina/login_page/forgot_pass.dart';
import 'package:seedina/menu_page/overview/editplant.dart';
import 'package:seedina/menu_page/profile/settings/esp32conn.dart';
import 'package:seedina/provider/rtdb_handler.dart';
import 'package:seedina/services/auth_service.dart';
import 'package:seedina/utils/rewidgets/contentbox/for_profile/setting_box.dart';
import 'package:seedina/utils/rewidgets/contentbox/for_profile/setting_menu.dart';
import 'package:seedina/utils/style/gcolor.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  Timer? _phStabilizationTimer;
  int _stabilizationSecondsRemaining = 140; // 2 menit 20 detik = 140 detik
  bool _isPhDialogVisible = false;

  @override
  void dispose() {
    _phStabilizationTimer?.cancel();
    super.dispose();
  }

  String _formatDuration(int totalSeconds) {
    final duration = Duration(seconds: totalSeconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = duration.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  Future<void> _showPhRequestDialog(BuildContext context) async {
    final handlingProvider = Provider.of<HandlingProvider>(context, listen: false);
    
    if (handlingProvider.isPhMeasuring) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Pengukuran pH sebelumnya masih berlangsung."),
          backgroundColor: Colors.orangeAccent,
        ),
      );
      return;
    }

    await handlingProvider.requestPhMeasurement(context);

    if (!handlingProvider.isPhMeasuring && handlingProvider.phMeasurementError != null) {
      return;
    }
    
    setState(() {
      _isPhDialogVisible = true;
      _stabilizationSecondsRemaining = 140; 
    });

    _phStabilizationTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_stabilizationSecondsRemaining > 0) {
        if (mounted && _isPhDialogVisible) {
          setState(() {
            _stabilizationSecondsRemaining--;
          });
        }
      } else {
        timer.cancel();
        if (mounted && _isPhDialogVisible) {
          setState(() {}); 
        }
      }
    });

    return showDialog<void>(
      context: context,
      barrierDismissible: false, 
      builder: (BuildContext dialogContext) {
        return WillPopScope(
          onWillPop: () async => false, 
          child: Consumer<HandlingProvider>(
            builder: (context, provider, child) {
              String dialogTitle = "Mengukur pH Air";
              List<Widget> dialogActions = [];
              Widget content;

              if (provider.isPhMeasuring && _stabilizationSecondsRemaining > 0) {
                content = Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    Text(
                      "Stabilisasi Sensor",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: GColors.myBiru),
                    ),
                    Text(
                      _formatDuration(_stabilizationSecondsRemaining),
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: GColors.myBiru),
                    ),
                    const SizedBox(height: 10),
                    const Text("Mohon tunggu...", textAlign: TextAlign.center),
                  ],
                );
              } else if (provider.phMeasurementError != null) {
                dialogTitle = "Error Pengukuran pH";
                content = Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, color: Colors.red.shade300, size: 48),
                    const SizedBox(height: 16),
                    Text(
                      provider.phMeasurementError!,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.red.shade700, fontSize: 15),
                    ),
                  ],
                );
                dialogActions.add(
                  TextButton(
                    child: const Text("MENGERTI"),
                    onPressed: () {
                      setState(() => _isPhDialogVisible = false);
                      _phStabilizationTimer?.cancel();
                      provider.isPhMeasuring = false; 
                      provider.phMeasurementError = null;
                      Navigator.of(dialogContext).pop();
                    },
                  ),
                );
              } else if (provider.onDemandPhValue != null) {
                 dialogTitle = "Hasil Pengukuran pH";
                 content = Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.check_circle_outline, color: Colors.green.shade400, size: 48),
                    const SizedBox(height: 16),
                    const Text(
                      "Nilai pH Air Saat Ini:",
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.onDemandPhValue!.toStringAsFixed(2),
                      style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: GColors.myBiru),
                    ),
                  ],
                );
                dialogActions.add(
                  TextButton(
                    child: const Text("SELESAI"),
                    onPressed: () {
                      setState(() => _isPhDialogVisible = false);
                       _phStabilizationTimer?.cancel();
                       provider.isPhMeasuring = false; 
                       Navigator.of(dialogContext).pop();
                    },
                  ),
                );
              } else { 
                 dialogTitle = "Menunggu Hasil";
                 content = Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const CircularProgressIndicator(),
                    const SizedBox(height: 20),
                    const Text("Mengambil data pH terbaru..."),
                  ],
                );
                 dialogActions.add(
                  TextButton(
                    style: TextButton.styleFrom(foregroundColor: Colors.redAccent),
                    child: const Text("BATALKAN"),
                    onPressed: () {
                      setState(() => _isPhDialogVisible = false);
                       _phStabilizationTimer?.cancel();
                       provider.isPhMeasuring = false; 
                       provider.onDemandPhValue = null; // Reset juga nilainya jika dibatalkan
                       provider.phMeasurementError = null;
                       Navigator.of(dialogContext).pop();
                    },
                  ),
                );
              }

              return AlertDialog(
                title: Text(dialogTitle, textAlign: TextAlign.center, style: TextStyle(fontWeight: FontWeight.bold, color: GColors.myBiru)),
                content: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 20.0),
                  child: content,
                ),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15.0)),
                actionsAlignment: MainAxisAlignment.center,
                actions: dialogActions,
              );
            },
          ),
        );
      },
    ).then((_) {
      _phStabilizationTimer?.cancel();
      setState(() {
        _isPhDialogVisible = false;
      });
    });
  }


  @override
  Widget build(BuildContext context) {
    final User? user = FirebaseAuth.instance.currentUser;
    final String displayName = user?.displayName ?? 'Farms';
    final String emailUser = user?.email ?? 'Unknown';

    final handlingProvider = Provider.of<HandlingProvider>(context);
    final String? seedKey = handlingProvider.currentUserSeedKey;

    return Scaffold(
        backgroundColor: GColors.myHijau,
        body: SingleChildScrollView(
            child: Stack(children: [
          Column(
            children: [
              const SizedBox(
                height: 256,
              ),
              Container(
                width: MediaQuery.of(context).size.width,
                height: MediaQuery.of(context).size.height,
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20)),
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 16, right: 16, bottom: 32),
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: const EdgeInsets.only(top: 120),
                child: Column(
                  children: [
                    Container(
                      width: MediaQuery.of(context).size.width,
                      constraints: const BoxConstraints(minHeight: 296),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: [
                            BoxShadow(
                                color: Colors.black.withOpacity(0.25),
                                blurRadius: 4,
                                spreadRadius: 0,
                                offset: const Offset(0, 4))
                          ]),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Column(
                          children: [
                            CircleAvatar(
                              backgroundColor: Colors.black,
                              backgroundImage:
                                  const AssetImage('assets/myicon/profile.png'),
                              radius: 56,
                            ),
                            const SizedBox(
                              height: 24,
                            ),
                            Text(
                              displayName,
                              style: const TextStyle(
                                  fontSize: 24, fontWeight: FontWeight.w600),
                            ),
                            Text(
                              emailUser,
                              style: const TextStyle(
                                  fontSize: 10, fontWeight: FontWeight.w300),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  width: 288,
                                  height: 72,
                                  decoration: BoxDecoration(
                                      color: const Color(0xFFD9D9D9),
                                      borderRadius: BorderRadius.circular(12)),
                                  child: Padding(
                                    padding: const EdgeInsets.all(4.0),
                                    child: Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          width: 8,
                                        ),
                                        SizedBox(
                                          width: 56,
                                          height: 48,
                                          child: Image.asset(
                                              'assets/myicon/iconkey.png'),
                                        ),
                                        const SizedBox(
                                          width: 12,
                                        ),
                                        Flexible(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              const Text(
                                                'Seed Key',
                                                style: TextStyle(fontSize: 10),
                                              ),
                                              const SizedBox(
                                                height: 5,
                                              ),
                                              Text(
                                                seedKey ?? 'Belum diatur',
                                                style: const TextStyle(fontSize: 16),
                                              )
                                            ],
                                          ),
                                        )
                                      ],
                                    ),
                                  ),
                                ),
                                if (seedKey != null && seedKey.isNotEmpty)
                                  IconButton(
                                      padding: EdgeInsets.zero,
                                      constraints: const BoxConstraints(),
                                      onPressed: () {
                                        Clipboard.setData(ClipboardData(text: seedKey));
                                        ScaffoldMessenger.of(context).showSnackBar(
                                          const SnackBar(content: Text("Seedkey telah disalin ke clipboard")),
                                        );
                                      },
                                      icon: const Icon(Icons.copy)),
                              ],
                            )
                          ],
                        ),
                      ),
                    ),
                    SettingBox(title: 'Akun', menu: [
                      SettingMenu(
                          illustration: 'assets/myicon/ic_password.png',
                          title: 'Ubah Password',
                          customOnTap: () { 
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => ForgotPass()),
                            );
                          },
                          navigate: ForgotPass() 
                        )
                    ]),
                    SettingBox(title: 'Pengaturan Perangkat', menu: [
                       SettingMenu(
                          illustration: 'assets/myicon/ic_phsensor.png', 
                          title: 'Ukur pH Air Manual',
                           customOnTap: () => _showPhRequestDialog(context),
                          navigate: Container() 
                        ),
                       const Divider(color: Colors.grey, thickness: 0.5, indent: 16, endIndent: 16),
                       SettingMenu(
                          illustration: 'assets/myicon/ic_esp32conn.png',
                          title: 'Atur Koneksi ESP32',
                           customOnTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(builder: (context) => const WiFiConn()),
                            );
                          },
                          navigate: const WiFiConn()
                        ),
                    ]),
                    SettingBox(title: 'Tentang Seedina', menu: [
                      SettingMenu(
                          illustration: 'assets/myicon/ic_info.png',
                          title: 'Informasi Aplikasi Seedina',
                           customOnTap: () {
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Halaman Info Aplikasi belum tersedia.")));
                          },
                          navigate: EditPlants()), 
                      const Divider(
                        color: Colors.grey,
                        thickness: 0.5,
                        indent: 16,
                        endIndent: 16,
                      ),
                      SettingMenu(
                          illustration: 'assets/myicon/ic_contactdev.png',
                          title: 'Kontak Developer',
                          customOnTap: () {
                             ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Fitur Kontak Developer belum tersedia.")));
                          },
                          navigate: EditPlants()) 
                    ]),
                    const SizedBox(
                      height: 32,
                    ),
                    SizedBox(
                      height: 120,
                      width: MediaQuery.of(context).size.width,
                      child: ElevatedButton(
                          style: ElevatedButton.styleFrom(
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(16)),
                              backgroundColor: GColors.myBiru,
                              foregroundColor: Colors.white),
                          onPressed: () async {
                            await AuthService.signOut(context);
                          },
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Image.asset(
                                  'assets/illustration/ill_signout.png', height: 80,), 
                              const SizedBox(
                                width: 20,
                              ),
                              const Text('Sign Out', style: TextStyle(fontSize: 32))
                            ],
                          )),
                    ),
                     const SizedBox(height: 20), 
                  ],
                ),
              ),
            ),
          )
        ])));
  }
}