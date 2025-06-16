import 'package:flutter/material.dart';
import 'package:seedina/services/auth_service.dart';
import 'package:seedina/utils/style/gcolor.dart';

class ForgotPass extends StatefulWidget {
  final bool _isSetup = true;

  ForgotPass({super.key});

  @override
  State<ForgotPass> createState() => _ForgotPassState();
}

class _ForgotPassState extends State<ForgotPass> {
  final TextEditingController _passwordResetControlller =
      TextEditingController();

  bool _isLoading = false;

  void _processPasswordReset() async {
    if (_passwordResetControlller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Email tidak boleh kosong'),
        backgroundColor: Colors.redAccent,
      ));
      return;
    }

    setState(() {
      _isLoading = true;
    });

    await AuthService.sendPasswordResetEmail(
        _passwordResetControlller.text.trim(), context);

    if (mounted) {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
          gradient: LinearGradient(
              colors: [GColors.myBiru, GColors.myHijau],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter)),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 12),
              child: IconButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  icon: Icon(Icons.close)),
            ),
          ],
          actionsIconTheme: IconThemeData(color: GColors.myKuning, size: 36),
        ),
        backgroundColor: Colors.transparent,
        body: SingleChildScrollView(
            child: Padding(
          padding: EdgeInsets.only(top: 144),
          child: Align(
            alignment: Alignment.topCenter,
            child: Column(
              children: [
                SizedBox(
                  width: 124,
                  height: 192,
                  child: Image.asset('assets/illustration/ill_forpass.png'),
                ),
                SizedBox(
                  height: 36,
                ),
                widget._isSetup 
                ? Text(
                  'Lupa Kata Sandi Akun-mu?',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                  )
                : Text(
                  'Mau ganti kata sandi akunmu?',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.w700),
                  ),
                Text(
                  'Masukkan emailmu, kemudian cek Gmail setelah klik “Kirim”',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 12,
                      fontWeight: FontWeight.w400),
                ),
                SizedBox(
                  height: 60,
                ),
                Container(
                  width: MediaQuery.of(context).size.width,
                  height: 452,
                  decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                          topLeft: Radius.circular(16),
                          topRight: Radius.circular(16))),
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: 16, right: 16, top: 40, bottom: 40),
                    child: Column(
                      children: [
                        Text(
                          'Masukkan email akun Seedina-mu',
                          style: TextStyle(
                              fontWeight: FontWeight.w500, fontSize: 16),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        SizedBox(
                          width: 382,
                          child: TextFormField(
                            controller: _passwordResetControlller,
                            style: TextStyle(fontSize: 12),
                            decoration: InputDecoration(
                              hintText: 'Email Akun',
                              hintStyle: TextStyle(fontSize: 12),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(16)),
                            ),
                            keyboardType: TextInputType.emailAddress,
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                    return 'Email tidak boleh kosong.';
                                }
                                if (!value.contains('@') || !value.contains('.')) {
                                    return 'Format email tidak valid.';
                                }
                                return null;
                            },
                          ),
                        ),
                        SizedBox(
                          height: 12,
                        ),
                        SizedBox(
                          width: MediaQuery.of(context).size.width,
                          child: _isLoading 
                          ? Center(child: CircularProgressIndicator())
                          : ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: GColors.myBiru,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12))),
                            onPressed: _processPasswordReset,
                            child: Text(
                              'Kirim',
                              style: TextStyle(
                                  fontSize: 16, fontWeight: FontWeight.w600),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
        )),
      ),
    );
  }
}
