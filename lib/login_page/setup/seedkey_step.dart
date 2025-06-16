import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:seedina/provider/rtdb_handler.dart';
import 'package:seedina/services/auth_service.dart';
import 'package:seedina/utils/style/gcolor.dart';
import 'package:seedina/utils/style/gtextfield.dart';

class SeedKey extends StatefulWidget {
  const SeedKey({super.key});

  @override
  State<SeedKey> createState() => _SeedKeyState();
}

class _SeedKeyState extends State<SeedKey> {
  final _seedKeyController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _seedKeyController.dispose();
    super.dispose();
  }

  Future<void> _submitAndClaimSeedKey(String seedKey) async {
    if (seedKey.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('SeedKey tidak boleh kosong!')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    final String? uid = AuthService.currentUser?.uid;
    if (uid == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('User tidak terautentikasi! Harap login ulang.')),
      );

      setState(() {
        _isLoading = false;
      });
      return;
    }

    try {
      final dbRef = FirebaseDatabase.instance.ref(seedKey);
      final snapshot = await dbRef.once().timeout(const Duration(seconds: 10));

      if (snapshot.snapshot.exists) {
        bool claimSuccess = await AuthService.claimSeedKey(uid, seedKey, context);

        if (claimSuccess) {
          if (mounted) {
            await Provider.of<HandlingProvider>(context, listen: false).updateUserSeedKey(seedKey);
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('SeedKey berhasil diatur!')),
            );
            Navigator.of(context).pushNamedAndRemoveUntil('/authcheck', (route) => false);
          }
        }
        // Jika claimSuccess false, AuthService sudah menampilkan error
      } else {
        // SeedKey tidak ditemukan di RTDB
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('SeedKey tidak ditemukan di sistem. Pastikan seedKey sesuai dengan yang tertera di kemasan')),
          );
        }
      }
    } on FirebaseException catch (e) {
        if (mounted) {
            AuthService.claimSeedKey(uid, seedKey, context);
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Error Firebase Database: ${e.message ?? "Tidak diketahui"}'))
            );
            if (kDebugMode) print("Firebase DB error in SeedKeyStep: ${e.message}");
        }
    } catch (e) {
        if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Terjadi kesalahan: ${e.toString()}'))
            );
            if (kDebugMode) print("General error in SeedKeyStep: $e");
        }
    } finally {
        if (mounted) {
            setState(() => _isLoading = false);
        }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [GColors.myBiru, GColors.myHijau],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter)),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                    height: 288,
                    width: 288,
                    child: Image.asset('assets/illustration/ill_dbconn.png')),
                Text(
                  'Keren! Kamu telah bergabung',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w700),
                ),
                SizedBox(
                  height: 20,
                ),
                Text(
                  'Untuk memulai menjalankan sistem otomatisasi penjadwalan penyiraman, pemberian nutrisi, dan lainnya, masukkan “SeedKey” yang diberikan Admin untuk sistem aeroponikmu ya',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white, fontSize: 12),
                ),
                SizedBox(
                  height: 20,
                ),
                TextFormField(
                    controller: _seedKeyController,
                    enabled: !_isLoading,
                    style: const TextStyle(fontSize: 12),
                    decoration: GFieldStyle(
                        filled: true, hintText: 'Masukkan Seedkey')),
                SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: MediaQuery.of(context).size.width,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: GColors.myBiru,
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12))),
                    onPressed: () {
                      final seedKey = _seedKeyController.text;
                      _submitAndClaimSeedKey(seedKey);
                    },
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.0,
                            ),
                          )
                        : const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.key),
                              SizedBox(
                                width: 12,
                              ),
                              Text('Hubungkan')
                            ],
                          ),
                  ),
                )
              ],
            ),
          ),
        ),
      ),
    );
  }
}
